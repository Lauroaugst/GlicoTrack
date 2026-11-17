import 'sync_document.dart';

abstract interface class LocalRepository {
  Stream<void> get changes;
  Future<List<SyncDocument>> all({String? kind, bool pendingOnly = false});
  Future<SyncDocument?> get(String id);
  Future<SyncDocument> save(
    String id,
    String kind,
    Map<String, dynamic> payload,
  );
  Future<void> delete(String id);
  Future<void> merge(SyncDocument remote);
  Future<void> acknowledge(SyncDocument sent, SyncDocument accepted);
  Future<int> pendingCount();
  Future<bool> deletionPending();
  Future<void> markDeletionPending();
  Future<void> purge();
  Future<void> recordSyncError(String code);
  Future<void> close();
}

abstract interface class RemoteRepository {
  Stream<void> get changes;
  Future<SyncDocument> push(SyncDocument document);
  Future<List<SyncDocument>> pull();
  Future<void> deleteAccount();
}
