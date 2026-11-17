import 'dart:async';

import 'package:glicotrack_dev/domain/repositories.dart';
import 'package:glicotrack_dev/domain/sync_document.dart';

class MemoryRepository implements LocalRepository {
  final docs = <String, SyncDocument>{};
  final _changes = StreamController<void>.broadcast();
  bool failSave = false;
  bool failErrorLog = false;
  bool deleting = false;
  int _version = 0;
  @override
  Stream<void> get changes => _changes.stream;
  @override
  Future<List<SyncDocument>> all({
    String? kind,
    bool pendingOnly = false,
  }) async => docs.values
      .where(
        (d) => (kind == null || d.kind == kind) && (!pendingOnly || d.pending),
      )
      .toList();
  @override
  Future<SyncDocument?> get(String id) async => docs[id];
  @override
  Future<SyncDocument> save(
    String id,
    String kind,
    Map<String, dynamic> payload,
  ) async {
    if (failSave || deleting) throw StateError('disk failure');
    final d = SyncDocument(
      id: id,
      uid: 'alice',
      kind: kind,
      revision:
          '${(++_version).toString().padLeft(16, '0')}-11111111-1111-4111-8111-111111111111',
      updatedAt: _version,
      payload: payload,
      pending: true,
    );
    d.validate('alice');
    docs[id] = d;
    _changes.add(null);
    return d;
  }

  @override
  Future<void> delete(String id) async {
    docs[id] = docs[id]!.copyWith(deleted: true, pending: true);
    _changes.add(null);
  }

  @override
  Future<void> merge(SyncDocument remote) async {
    docs[remote.id] = remote;
    _changes.add(null);
  }

  @override
  Future<void> acknowledge(SyncDocument sent, SyncDocument accepted) async {
    docs[sent.id] = accepted.copyWith(pending: false);
  }

  @override
  Future<int> pendingCount() async =>
      docs.values.where((d) => d.pending).length;
  @override
  Future<bool> deletionPending() async => deleting;
  @override
  Future<void> markDeletionPending() async {
    deleting = true;
  }

  @override
  Future<void> purge() async {
    docs.clear();
  }

  @override
  Future<void> recordSyncError(String code) async {
    if (failErrorLog) throw StateError('disk unavailable');
  }

  @override
  Future<void> close() => _changes.close();
}
