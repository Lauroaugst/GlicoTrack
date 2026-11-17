import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'package:uuid/uuid.dart';

import '../domain/repositories.dart';
import '../domain/sync_document.dart';

class LocalDatabase implements LocalRepository {
  LocalDatabase(this.db, this.uid);
  final Database db;
  final String uid;
  final _changes = StreamController<void>.broadcast();
  bool _closed = false;
  static const schemaVersion = 1;
  static Future<String>? _key;

  static Future<String> _loadKey() async {
    const storage = FlutterSecureStorage();
    var key = await storage.read(key: 'glicotrack.sqlcipher.v1');
    if (key == null) {
      key = base64Url.encode(
        List.generate(32, (_) => Random.secure().nextInt(256)),
      );
      await storage.write(key: 'glicotrack.sqlcipher.v1', value: key);
    }
    return key;
  }

  static Future<LocalDatabase> open(String uid) async {
    // Serialize key creation across rapid login/logout transitions.
    String key;
    try {
      key = await (_key ??= _loadKey());
    } catch (_) {
      _key = null;
      rethrow;
    }
    final db = await cipher.openDatabase(
      p.join(await cipher.getDatabasesPath(), 'glicotrack.db'),
      password: key,
      singleInstance: false,
      version: schemaVersion,
      onConfigure: configure,
      onCreate: createSchema,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Future migrations must be incremental; never drop user tables.
        throw StateError(
          'Migração não implementada: $oldVersion -> $newVersion',
        );
      },
    );
    final result = await db.rawQuery('PRAGMA cipher_version');
    if (result.isEmpty) {
      await db.close();
      throw StateError('SQLite sem criptografia não é permitido.');
    }
    await db.insert('accounts', {
      'uid': uid,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return LocalDatabase(db, uid);
  }

  static Future<void> configure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('PRAGMA secure_delete = ON');
  }

  static Future<void> createSchema(Database db, int version) async {
    await db.execute(
      'CREATE TABLE accounts (uid TEXT PRIMARY KEY, deletion_pending INTEGER NOT NULL DEFAULT 0, sync_error TEXT)',
    );
    await db.execute('CREATE TABLE categories (id TEXT PRIMARY KEY)');
    for (final id in ['fasting', 'beforeMeal', 'afterMeal', 'bedtime']) {
      await db.insert('categories', {'id': id});
    }
    await db.execute('''CREATE TABLE documents (
      uid TEXT NOT NULL REFERENCES accounts(uid) ON DELETE CASCADE,
      id TEXT NOT NULL, kind TEXT NOT NULL CHECK(kind IN ('record','settings','profile')),
      revision TEXT NOT NULL, base_revision TEXT, updated_at INTEGER NOT NULL,
      payload TEXT NOT NULL, deleted INTEGER NOT NULL DEFAULT 0,
      pending INTEGER NOT NULL DEFAULT 1, measured_at INTEGER,
      category TEXT REFERENCES categories(id), PRIMARY KEY(uid,id))''');
    await db.execute(
      'CREATE INDEX records_period ON documents(uid,kind,deleted,measured_at DESC)',
    );
    await db.execute(
      'CREATE INDEX records_category ON documents(uid,category,measured_at DESC)',
    );
    await db.execute('CREATE INDEX sync_queue ON documents(uid,pending)');
    await db.execute(
      '''CREATE TABLE conflicts (uid TEXT NOT NULL REFERENCES accounts(uid) ON DELETE CASCADE,
      id TEXT NOT NULL, revision TEXT NOT NULL, document TEXT NOT NULL, PRIMARY KEY(uid,id,revision))''',
    );
  }

  @override
  Stream<void> get changes => _changes.stream;
  void _notify() {
    if (!_closed) _changes.add(null);
  }

  SyncDocument _decode(Map<String, Object?> row) => SyncDocument(
    id: row['id'] as String,
    uid: uid,
    kind: row['kind'] as String,
    revision: row['revision'] as String,
    baseRevision: row['base_revision'] as String?,
    updatedAt: row['updated_at'] as int,
    payload: jsonDecode(row['payload'] as String) as Map<String, dynamic>,
    deleted: row['deleted'] == 1,
    pending: row['pending'] == 1,
  );
  Map<String, Object?> _encode(SyncDocument doc) => {
    'uid': uid,
    'id': doc.id,
    'kind': doc.kind,
    'revision': doc.revision,
    'base_revision': doc.baseRevision,
    'updated_at': doc.updatedAt,
    'payload': jsonEncode(doc.payload),
    'deleted': doc.deleted ? 1 : 0,
    'pending': doc.pending ? 1 : 0,
    'measured_at': doc.kind == 'record' ? doc.payload['measuredAt'] : null,
    'category': doc.kind == 'record' ? doc.payload['category'] : null,
  };
  Future<SyncDocument?> _get(DatabaseExecutor db, String id) async {
    final rows = await db.query(
      'documents',
      where: 'uid = ? AND id = ?',
      whereArgs: [uid, id],
    );
    return rows.isEmpty ? null : _decode(rows.single);
  }

  Future<void> _checkWritable(DatabaseExecutor db) async {
    final rows = await db.query('accounts', where: 'uid = ?', whereArgs: [uid]);
    if (rows.isEmpty || rows.single['deletion_pending'] == 1) {
      throw StateError('Exclusão da conta em andamento.');
    }
  }

  @override
  Future<List<SyncDocument>> all({
    String? kind,
    bool pendingOnly = false,
  }) async => (await db.query(
    'documents',
    where:
        'uid = ?${kind == null ? '' : ' AND kind = ?'}${pendingOnly ? ' AND pending = 1' : ''}',
    whereArgs: [uid, ?kind],
    orderBy: 'measured_at DESC, id',
  )).map(_decode).toList();
  @override
  Future<SyncDocument?> get(String id) => _get(db, id);

  @override
  Future<SyncDocument> save(
    String id,
    String kind,
    Map<String, dynamic> payload,
  ) async {
    final saved = await db.transaction((txn) async {
      await _checkWritable(txn);
      final old = await _get(txn, id);
      if (old?.deleted == true) {
        throw StateError('Registro excluído não pode ser alterado.');
      }
      final nextClock = max(
        DateTime.now().microsecondsSinceEpoch,
        old == null ? 0 : int.parse(old.revision.split('-').first) + 1,
      );
      final doc = SyncDocument(
        id: id,
        uid: uid,
        kind: kind,
        revision:
            '${nextClock.toString().padLeft(16, '0')}-${const Uuid().v4()}',
        baseRevision: old == null
            ? null
            : old.pending
            ? old.baseRevision
            : old.revision,
        updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        payload: payload,
        pending: true,
      );
      doc.validate(uid);
      await txn.insert(
        'documents',
        _encode(doc),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return doc;
    });
    _notify();
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    await db.transaction((txn) async {
      await _checkWritable(txn);
      final old = await _get(txn, id);
      if (old == null || old.deleted) return;
      final clock = max(
        DateTime.now().microsecondsSinceEpoch,
        int.parse(old.revision.split('-').first) + 1,
      );
      final doc = SyncDocument(
        id: old.id,
        uid: uid,
        kind: old.kind,
        revision: '${clock.toString().padLeft(16, '0')}-${const Uuid().v4()}',
        baseRevision: old.pending ? old.baseRevision : old.revision,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        payload: old.payload,
        deleted: true,
        pending: true,
      );
      await txn.update(
        'documents',
        _encode(doc),
        where: 'uid = ? AND id = ?',
        whereArgs: [uid, id],
      );
    });
    _notify();
  }

  Future<void> _archive(DatabaseExecutor txn, SyncDocument doc) => txn
      .insert('conflicts', {
        'uid': uid,
        'id': doc.id,
        'revision': doc.revision,
        'document': jsonEncode(doc.toJson()),
      }, conflictAlgorithm: ConflictAlgorithm.ignore)
      .then((_) {});

  @override
  Future<void> merge(SyncDocument remote) async {
    remote.validate(uid);
    var changed = false;
    await db.transaction((txn) async {
      await _checkWritable(txn);
      final local = await _get(txn, remote.id);
      if (local?.revision == remote.revision) return;
      var winner = remote;
      if (local != null && local.pending) {
        winner = resolveConflict(local, remote);
        if (isConcurrent(local, remote)) {
          await _archive(txn, winner == local ? remote : local);
        }
      }
      // A clean local document is a cache; the server transaction is authoritative.
      await txn.insert(
        'documents',
        _encode(winner),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      changed = true;
    });
    if (changed) _notify();
  }

  @override
  Future<void> acknowledge(SyncDocument sent, SyncDocument accepted) async {
    accepted.validate(uid);
    await db.transaction((txn) async {
      await _checkWritable(txn);
      final current = await _get(txn, sent.id);
      if (current == null) return;
      if (accepted.deleted &&
          !current.deleted &&
          current.revision != sent.revision) {
        await _archive(txn, current);
        await txn.update(
          'documents',
          _encode(accepted.copyWith(pending: false)),
          where: 'uid = ? AND id = ?',
          whereArgs: [uid, sent.id],
        );
        return;
      }
      if (isConcurrent(sent, accepted)) {
        await _archive(
          txn,
          accepted.revision == sent.revision ? accepted : sent,
        );
      }
      if (current.revision == sent.revision) {
        await txn.update(
          'documents',
          _encode(accepted.copyWith(pending: false)),
          where: 'uid = ? AND id = ? AND revision = ?',
          whereArgs: [uid, sent.id, sent.revision],
        );
      } else {
        // Local edit during upload: keep it queued, but attach it to the accepted parent.
        await txn.update(
          'documents',
          {'base_revision': accepted.revision},
          where: 'uid = ? AND id = ?',
          whereArgs: [uid, sent.id],
        );
      }
    });
    _notify();
  }

  @override
  Future<int> pendingCount() async =>
      (await db.rawQuery(
            'SELECT COUNT(*) AS n FROM documents WHERE uid = ? AND pending = 1',
            [uid],
          )).single['n']
          as int;
  @override
  Future<bool> deletionPending() async =>
      (await db.query(
        'accounts',
        where: 'uid = ?',
        whereArgs: [uid],
      )).single['deletion_pending'] ==
      1;
  @override
  Future<void> markDeletionPending() async {
    await db.update(
      'accounts',
      {'deletion_pending': 1},
      where: 'uid = ?',
      whereArgs: [uid],
    );
    _notify();
  }

  @override
  Future<void> purge() async {
    await db.transaction((txn) async {
      await txn.delete('documents', where: 'uid = ?', whereArgs: [uid]);
      await txn.delete('conflicts', where: 'uid = ?', whereArgs: [uid]);
    });
    // Keep the deletion marker: old pending data must never reappear on this installation.
    _notify();
  }

  @override
  Future<void> recordSyncError(String code) async {
    await db.update(
      'accounts',
      {'sync_error': code},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  @override
  Future<void> close() async {
    _closed = true;
    await _changes.close();
    await db.close();
  }
}
