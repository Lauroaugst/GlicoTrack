import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:glicotrack_dev/data/local_database.dart';
import 'package:glicotrack_dev/domain/models.dart';

import 'support/fixtures.dart';

Future<LocalDatabase> openTestDatabase({
  String path = inMemoryDatabasePath,
}) async {
  final db = await databaseFactoryFfi.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: LocalDatabase.schemaVersion,
      onConfigure: LocalDatabase.configure,
      onCreate: LocalDatabase.createSchema,
    ),
  );
  await db.insert('accounts', {'uid': uid});
  return LocalDatabase(db, uid);
}

void main() {
  sqfliteFfiInit();
  late LocalDatabase local;
  setUp(() async {
    local = await openTestDatabase();
  });
  tearDown(() async {
    await local.close();
  });

  test(
    'CRUD agregado persiste glicemia, insulina, carboidratos e observações',
    () async {
      final created = await local.save(
        recordId,
        'record',
        record(notes: 'teste').toJson(),
      );
      final restored = HealthRecord.fromJson(
        recordId,
        uid,
        (await local.get(recordId))!.payload,
      );
      expect(restored.glucose, 120);
      expect(restored.insulin, 2);
      expect(restored.carbs, 30);
      expect(restored.notes, 'teste');
      final edited = await local.save(
        recordId,
        'record',
        record(glucose: 130).toJson(),
      );
      expect(edited.revision, isNot(created.revision));
      expect((await local.all()).length, 1);
      await local.delete(recordId);
      expect((await local.get(recordId))!.deleted, isTrue);
      expect(await local.pendingCount(), 1);
      await expectLater(
        local.save(recordId, 'record', record().toJson()),
        throwsStateError,
      );
    },
  );
  test('transação rejeita payload inválido sem sucesso falso', () async {
    await expectLater(
      local.save(recordId, 'record', record(glucose: 0).toJson()),
      throwsFormatException,
    );
    expect(await local.all(), isEmpty);
  });
  test(
    'isolamento por UID em todas as leituras, atualizações e exclusões',
    () async {
      await local.db.insert('accounts', {'uid': 'bob'});
      final bob = LocalDatabase(local.db, 'bob');
      await local.save(recordId, 'record', record().toJson());
      expect(await bob.get(recordId), isNull);
      expect(await bob.all(), isEmpty);
      await bob.delete(recordId);
      expect((await local.get(recordId))!.deleted, isFalse);
      await expectLater(bob.merge(document()), throwsFormatException);
    },
  );
  test('restauração idempotente e configuração persistida', () async {
    await local.merge(document());
    await local.merge(document());
    expect((await local.all()).length, 1);
    expect(await local.pendingCount(), 0);
    await local.save(
      'settings',
      'settings',
      const GlucoseSettings(lower: 80, upper: 160).toJson(),
    );
    expect(
      GlucoseSettings.fromJson((await local.get('settings'))!.payload).lower,
      80,
    );
  });
  test('conflito conserva versão perdedora e impede duplicidade', () async {
    final pending = await local.save(
      recordId,
      'record',
      record(glucose: 125).toJson(),
    );
    final remote = document(clock: 9999999999999999, glucose: 200);
    await local.merge(remote);
    await local.merge(remote);
    expect((await local.get(recordId))!.payload['glucose'], 200);
    final conflicts = await local.db.query('conflicts');
    expect(conflicts.length, 1);
    expect(conflicts.single['revision'], pending.revision);
  });
  test('edição durante envio continua pendente até nova confirmação', () async {
    final sent = await local.save(recordId, 'record', record().toJson());
    final edited = await local.save(
      recordId,
      'record',
      record(glucose: 150).toJson(),
    );
    await local.acknowledge(sent, sent.copyWith(pending: false));
    final current = (await local.get(recordId))!;
    expect(current.revision, edited.revision);
    expect(current.pending, isTrue);
    expect(current.baseRevision, sent.revision);
  });
  test(
    'marcador de exclusão bloqueia novos envios, importações e salvamentos',
    () async {
      await local.save(recordId, 'record', record().toJson());
      await local.markDeletionPending();
      await expectLater(
        local.save(recordId, 'record', record().toJson()),
        throwsStateError,
      );
      await expectLater(local.merge(document()), throwsStateError);
      await local.purge();
      expect(await local.all(), isEmpty);
      expect(await local.deletionPending(), isTrue);
    },
  );
  test('exclusão aceita durante upload preserva a edição intermediária no arquivo de conflitos', () async {
    final sent = await local.save(recordId, 'record', record().toJson());
    final edited = await local.save(
      recordId,
      'record',
      record(glucose: 160).toJson(),
    );
    final deleted = document(clock: 9999999999999999, deleted: true);
    await local.acknowledge(sent, deleted);
    expect((await local.get(recordId))!.deleted, isTrue);
    expect((await local.get(recordId))!.pending, isFalse);
    final archived = await local.db.query('conflicts');
    expect(archived.any((row) => row['revision'] == edited.revision), isTrue);
  });
  test('cinco gravações consecutivas não perdem registros', () async {
    for (var i = 1; i <= 5; i++) {
      final id = '00000000-0000-4000-8000-${i.toString().padLeft(12, '0')}';
      await local.save(id, 'record', record(id: id, glucose: 100 + i).toJson());
    }
    expect((await local.all(kind: 'record')).length, 5);
    expect(await local.pendingCount(), 5);
  });
}
