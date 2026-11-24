import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import '../domain/repositories.dart';
import '../data/sync_service.dart';

class AppStore extends ChangeNotifier {
  AppStore({
    required this.uid,
    required this.local,
    required this.sync,
    required this.initialProfile,
    this.passwordRequiredForDeletion = false,
  });
  final String uid;
  final LocalRepository local;
  final SyncService sync;
  PatientProfile initialProfile;
  final bool passwordRequiredForDeletion;

  void updateAuthProfile(PatientProfile value) {
    initialProfile = value;
    if (!_disposed) notifyListeners();
  }

  PatientProfile? _profile;
  PatientProfile get profile => _profile ?? initialProfile;
  GlucoseSettings settings = const GlucoseSettings();
  List<HealthRecord> records = const [];
  int pending = 0;
  bool deleting = false;
  bool _disposed = false;
  Future<void>? _refreshing;
  bool _refreshAgain = false;
  StreamSubscription<void>? _subscription;
  String? loadError;

  Future<void> initialize({bool startSync = true}) async {
    deleting = await local.deletionPending();
    await refresh();
    _subscription = local.changes.listen((_) => unawaited(refresh()));
    sync.addListener(_syncChanged);
    if (!deleting && startSync) sync.start();
  }

  void _syncChanged() {
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh() {
    _refreshAgain = true;
    final current = _refreshing;
    if (current != null) return current;
    final operation = _runRefresh();
    _refreshing = operation;
    return operation;
  }

  Future<void> _runRefresh() async {
    try {
      while (_refreshAgain && !_disposed) {
        _refreshAgain = false;
        try {
          final docs = await local.all();
          final nextRecords = <HealthRecord>[];
          var nextSettings = const GlucoseSettings();
          PatientProfile? nextProfile;
          for (final doc in docs) {
            if (doc.deleted) continue;
            doc.validate(uid);
            switch (doc.kind) {
              case 'record':
                nextRecords.add(
                  HealthRecord.fromJson(doc.id, uid, doc.payload),
                );
              case 'settings':
                nextSettings = GlucoseSettings.fromJson(doc.payload);
              case 'profile':
                nextProfile = PatientProfile.fromJson(doc.payload);
            }
          }
          final count = await local.pendingCount();
          if (_disposed) return;
          records = List.unmodifiable(nextRecords);
          settings = nextSettings;
          _profile = nextProfile;
          pending = count;
          loadError = null;
          notifyListeners();
        } catch (_) {
          if (_disposed) return;
          loadError =
              'Não foi possível ler todos os dados locais. Tente novamente.';
          notifyListeners();
        }
      }
    } finally {
      _refreshing = null;
    }
  }

  List<HealthRecord> select({
    DateTime? start,
    DateTime? end,
    MeasurementCategory? category,
  }) => records
      .where(
        (r) =>
            (start == null || !r.measuredAt.isBefore(start)) &&
            (end == null || r.measuredAt.isBefore(end)) &&
            (category == null || r.category == category),
      )
      .toList();

  Future<void> saveRecord(HealthRecord record) async {
    record.validate();
    if (record.uid != uid) {
      throw const FormatException('Registro de outra conta.');
    }
    await local.save(record.id, 'record', record.toJson());
    await refresh();
  }

  String newId() => const Uuid().v4();
  Future<void> deleteRecord(String id) async {
    await local.delete(id);
    await refresh();
  }

  Future<void> clearRecords() async {
    for (final record in [...records]) {
      await local.delete(record.id);
    }
    await refresh();
  }

  String _recordRestoreKey(Map<String, dynamic> payload) =>
      '${payload['createdAt']}|${payload['measuredAt']}';

  /// Restaura registros da nuvem para o aparelho.
  /// Incorpora documentos ativos remotos e também recupera medições que
  /// haviam sido excluídas na Linha do Tempo (tombstones) quando não há
  /// uma cópia ativa correspondente no dispositivo, sem duplicar registros.
  Future<int> restoreFromCloud() async {
    final beforeIds = records.map((r) => r.id).toSet();
    final pulled = await sync.restoreRemote();
    await refresh();

    var restored = records.where((r) => !beforeIds.contains(r.id)).length;
    final activeKeys = records
        .map((r) => _recordRestoreKey(r.toJson()))
        .toSet();

    final remoteRecords =
        pulled.where((d) => d.kind == 'record').toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    var recreatedAny = false;
    for (final doc in remoteRecords) {
      final key = _recordRestoreKey(doc.payload);
      if (activeKeys.contains(key)) continue;
      await local.save(newId(), 'record', doc.payload);
      activeKeys.add(key);
      restored++;
      recreatedAny = true;
    }

    await refresh();
    if (recreatedAny) {
      sync.request();
    }
    return restored;
  }

  Future<void> saveSettings(GlucoseSettings value) async {
    value.validate();
    await local.save('settings', 'settings', value.toJson());
    await refresh();
  }

  Future<void> saveProfile(PatientProfile value) async {
    value.validate();
    await local.save('profile', 'profile', value.toJson());
    await refresh();
  }

  Future<void> deleteAccount([String password = '']) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != uid) {
      throw StateError('Não foi possível verificar a sessão.');
    }
    // Anonymous sessions have no password. Preserve any existing password account.
    if (!user.isAnonymous) {
      if (user.email == null) {
        throw StateError('Não foi possível confirmar a conta.');
      }
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );
    }
    await local.markDeletionPending();
    deleting = true;
    notifyListeners();
    await sync.stop();
    await sync.remote.deleteAccount();
    await local.purge();
    records = const [];
    _profile = null;
    notifyListeners();
    try {
      await user.delete();
    } on FirebaseAuthException {
      await FirebaseAuth.instance.signOut();
    }
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<void> shutdown() async {
    await _subscription?.cancel();
    sync.removeListener(_syncChanged);
    await sync.stop();
    sync.dispose();
    await local.close();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(shutdown());
    super.dispose();
  }
}
