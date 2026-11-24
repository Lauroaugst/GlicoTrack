import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../domain/repositories.dart';
import '../domain/sync_document.dart';

class FirebaseRepository implements RemoteRepository {
  FirebaseRepository(this.firestore, this.uid);
  final FirebaseFirestore firestore;
  final String uid;
  Timestamp? _watermark;
  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('users').doc(uid).collection('documents');
  @override
  Stream<void> get changes => _collection
      .orderBy('changedAt', descending: true)
      .limit(1)
      .snapshots()
      .map((_) {});

  @override
  Future<SyncDocument> push(SyncDocument document) async {
    document.validate(uid);
    final ref = _collection.doc(document.id);
    return firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final existing = snapshot.exists
          ? SyncDocument.fromJson(snapshot.data()!)
          : null;
      existing?.validate(uid);
      if (existing?.revision == document.revision) return existing!;
      final winner = existing == null
          ? document
          : resolveConflict(document, existing);
      if (existing != null && isConcurrent(document, existing)) {
        final loser = winner.revision == document.revision
            ? existing
            : document;
        final conflictRef = firestore
            .collection('users')
            .doc(uid)
            .collection('conflicts')
            .doc('${loser.id}_${loser.revision}');
        transaction.set(conflictRef, loser.toJson());
      }
      if (winner.revision == document.revision) {
        transaction.set(ref, {
          ...winner.toJson(),
          'changedAt': FieldValue.serverTimestamp(),
        });
      }
      return winner.copyWith(pending: false);
    }, timeout: const Duration(seconds: 15));
  }

  @override
  Future<List<SyncDocument>> pull() async {
    // Inclusive watermark prevents losing documents with the same server time.
    final fullRestore = _watermark == null;
    Query<Map<String, dynamic>> query = fullRestore
        ? _collection.orderBy(FieldPath.documentId)
        : _collection
              .orderBy('changedAt')
              .orderBy(FieldPath.documentId)
              .where('changedAt', isGreaterThanOrEqualTo: _watermark);
    final result = <SyncDocument>[];
    DocumentSnapshot<Map<String, dynamic>>? last;
    Timestamp? nextWatermark;
    while (true) {
      final pageQuery = last == null
          ? query.limit(200)
          : query.startAfterDocument(last).limit(200);
      final page = await pageQuery
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 15));
      for (final doc in page.docs) {
        final data = doc.data();
        final parsed = SyncDocument.fromJson(data);
        parsed.validate(uid);
        if (parsed.id != doc.id) {
          throw const FormatException('Identificador remoto inválido.');
        }
        result.add(parsed);
        final changedAt = data['changedAt'];
        if (changedAt is Timestamp &&
            (nextWatermark == null || changedAt.compareTo(nextWatermark) > 0)) {
          nextWatermark = changedAt;
        }
      }
      if (page.docs.length < 200) break;
      last = page.docs.last;
    }
    // A failed merge must not advance this cursor: callers confirm after import.
    _pendingWatermark = nextWatermark;
    return result;
  }

  Timestamp? _pendingWatermark;
  void confirmPull() {
    _watermark = _pendingWatermark ?? _watermark;
  }

  void resetCursor() {
    _watermark = null;
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable(
            'deleteMyAccount',
            options: HttpsCallableOptions(timeout: const Duration(minutes: 2)),
          )
          .call<void>();
    } on FirebaseFunctionsException {
      try {
        final snapshot = await _collection
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 15));
        for (final doc in snapshot.docs) {
          try {
            await doc.reference.delete();
          } on FirebaseException {
            final data = doc.data();
            if (data['deleted'] != true) {
              await doc.reference.update({
                'deleted': true,
                'changedAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }
        final conflicts = await firestore
            .collection('users')
            .doc(uid)
            .collection('conflicts')
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 15));
        for (final doc in conflicts.docs) {
          try {
            await doc.reference.delete();
          } on FirebaseException {
            // Ignore if rules restrict physical conflict deletion.
          }
        }
      } on FirebaseException {
        // Proceed with Auth user deletion if remote collection is already empty or restricted.
      }
    }
  }
}
