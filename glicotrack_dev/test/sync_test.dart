import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:glicotrack_dev/data/local_database.dart';
import 'package:glicotrack_dev/data/sync_service.dart';
import 'package:glicotrack_dev/presentation/app_store.dart';

import 'local_database_test.dart' show openTestDatabase;
import 'support/fixtures.dart';
import 'support/memory_repository.dart';

void main() {
  sqfliteFfiInit();
  late LocalDatabase local;
  late FakeRemote remote;
  late SyncService sync;
  setUp(() async {
    local = await openTestDatabase();
    remote = FakeRemote();
    sync = SyncService(local, remote);
  });
  tearDown(() async {
    await sync.stop();
    sync.dispose();
    await local.close();
  });
  test(
    'salvamento offline não depende do Firebase e é enviado após reconexão',
    () async {
      remote.offline = true;
      await local.save(recordId, 'record', record().toJson());
      await expectLater(sync.syncNow(), throwsStateError);
      expect(await local.pendingCount(), 1);
      expect((await local.get(recordId))!.payload['glucose'], 120);
      remote.offline = false;
      await sync.syncNow();
      expect(remote.documents.length, 1);
      expect(await local.pendingCount(), 0);
      await sync.syncNow();
      expect(remote.pushes, 1);
    },
  );
  test('restaura documentos remotos sem duplicar', () async {
    remote.documents[recordId] = document();
    await sync.syncNow();
    await sync.syncNow();
    expect((await local.all()).length, 1);
    expect(await local.pendingCount(), 0);
  });
  test('exclusões são sincronizadas como tombstones', () async {
    await local.save(recordId, 'record', record().toJson());
    await sync.syncNow();
    await local.delete(recordId);
    await sync.syncNow();
    expect(remote.documents[recordId]!.deleted, isTrue);
    expect(await local.pendingCount(), 0);
  });
  test('gravação durante upload não é sobrescrita pelo ACK anterior', () async {
    await local.save(recordId, 'record', record().toJson());
    remote.duringPush = (_) async {
      remote.duringPush = null;
      await local.save(recordId, 'record', record(glucose: 160).toJson());
    };
    await sync.syncNow();
    expect((await local.get(recordId))!.payload['glucose'], 160);
    await sync.syncNow();
    expect(remote.documents[recordId]!.payload['glucose'], 160);
    expect(await local.pendingCount(), 0);
  });
  test(
    'falha no log local não causa exceção em segundo plano nem perde a fila',
    () async {
      final memory = MemoryRepository()..failErrorLog = true;
      final unavailable = FakeRemote()..offline = true;
      final service = SyncService(memory, unavailable);
      try {
        await memory.save(recordId, 'record', record().toJson());
        await expectLater(service.syncNow(), throwsStateError);
        expect(await memory.pendingCount(), 1);
        expect(service.error, isNotNull);
      } finally {
        await service.stop();
        service.dispose();
        await memory.close();
      }
    },
  );
  test('exclusão de conta impede reenviar fila antiga', () async {
    await local.save(recordId, 'record', record().toJson());
    await local.markDeletionPending();
    await sync.syncNow();
    expect(remote.pushes, 0);
  });
  test(
    'restaurar dados recupera registros excluídos na linha do tempo sem duplicar',
    () async {
      final store = AppStore(
        uid: uid,
        local: local,
        sync: sync,
        initialProfile: profile,
      );
      await store.initialize(startSync: false);
      await store.saveRecord(record(glucose: 145));
      await sync.syncNow();
      expect(store.records.length, 1);

      // Exclui na linha do tempo e sincroniza (tombstone na nuvem)
      await store.clearRecords();
      await sync.syncNow();
      expect(store.records, isEmpty);
      expect(remote.documents[recordId]!.deleted, isTrue);

      // Restaurar dados da nuvem recupera o registro no dispositivo
      final firstRestore = await store.restoreFromCloud();
      expect(firstRestore, 1);
      expect(store.records.length, 1);
      expect(store.records.single.glucose, 145);

      // Nova restauração não duplica o registro já recuperado
      await sync.syncNow();
      final secondRestore = await store.restoreFromCloud();
      expect(secondRestore, 0);
      expect(store.records.length, 1);
    },
  );
}
