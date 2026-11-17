import 'dart:async';

import 'package:glicotrack_dev/domain/models.dart';
import 'package:glicotrack_dev/domain/repositories.dart';
import 'package:glicotrack_dev/domain/sync_document.dart';

const uid = 'alice';
const recordId = '11111111-1111-4111-8111-111111111111';
final now = DateTime(2026, 11, 16, 12);
final profile = PatientProfile(
  name: 'Paciente teste',
  email: 'teste@example.com',
  createdAt: now,
);

HealthRecord record({
  String id = recordId,
  String owner = uid,
  int glucose = 120,
  double? insulin = 2,
  double? carbs = 30,
  String notes = '',
  DateTime? at,
  MeasurementCategory category = MeasurementCategory.fasting,
}) => HealthRecord(
  id: id,
  uid: owner,
  glucose: glucose,
  measuredAt: at ?? now,
  category: category,
  meal: 'breakfast',
  createdAt: now,
  insulin: insulin,
  carbs: carbs,
  notes: notes,
);

SyncDocument document({
  int clock = 100,
  String? base,
  bool deleted = false,
  int glucose = 120,
  String owner = uid,
}) => SyncDocument(
  id: recordId,
  uid: owner,
  kind: 'record',
  revision: '${clock.toString().padLeft(16, '0')}-$recordId',
  baseRevision: base,
  updatedAt: clock,
  payload: record(glucose: glucose).toJson(),
  deleted: deleted,
);

class FakeRemote implements RemoteRepository {
  final documents = <String, SyncDocument>{};
  bool offline = false;
  int pushes = 0;
  Future<void> Function(SyncDocument)? duringPush;
  @override
  Stream<void> get changes => const Stream.empty();
  @override
  Future<SyncDocument> push(SyncDocument doc) async {
    if (offline) throw StateError('offline');
    pushes++;
    await duringPush?.call(doc);
    final current = documents[doc.id];
    final winner = current == null ? doc : resolveConflict(doc, current);
    documents[doc.id] = winner.copyWith(pending: false);
    return documents[doc.id]!;
  }

  @override
  Future<List<SyncDocument>> pull() async {
    if (offline) throw StateError('offline');
    return documents.values.toList();
  }

  @override
  Future<void> deleteAccount() async {
    documents.clear();
  }
}
