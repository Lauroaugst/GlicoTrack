import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../domain/repositories.dart';
import 'firebase_repository.dart';

class SyncService extends ChangeNotifier {
  SyncService(this.local, this.remote);
  final LocalRepository local;
  final RemoteRepository remote;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Future<void>? _running;
  Timer? _retry;
  bool _stopped = false;
  bool _requested = false;
  int _failures = 0;
  String? error;
  bool get syncing => _running != null;

  void start() {
    _subscriptions.add(local.changes.listen((_) => request()));
    _subscriptions.add(
      remote.changes.listen((_) => request(), onError: (Object _) => request()),
    );
    _subscriptions.add(
      Connectivity().onConnectivityChanged.listen((_) => request()),
    );
    request();
  }

  void request() {
    if (_stopped) return;
    _requested = true;
    if (_running != null) return;
    _retry?.cancel();
    final operation = _drain();
    _running = operation;
    notifyListeners();
    unawaited(
      operation.then((_) {
        _running = null;
        if (_stopped) return;
        notifyListeners();
        if (error == null && _requested) request();
      }),
    );
  }

  Future<void> syncNow({bool restore = false}) async {
    if (_stopped) throw StateError('Sincronização suspensa para exclusão.');
    if (restore && remote is FirebaseRepository) {
      (remote as FirebaseRepository).resetCursor();
    }
    request();
    await _running;
    if (error != null) throw StateError(error!);
  }

  Future<void> _drain() async {
    try {
      do {
        _requested = false;
        if (_stopped || await local.deletionPending()) return;
        final pending = await local.all(pendingOnly: true);
        for (final doc in pending) {
          if (_stopped) return;
          final accepted = await remote.push(doc);
          if (_stopped) return;
          await local.acknowledge(doc, accepted);
        }
        if (_stopped) return;
        final pulled = await remote.pull();
        for (final doc in pulled) {
          if (_stopped) return;
          await local.merge(doc);
        }
        if (remote is FirebaseRepository) {
          (remote as FirebaseRepository).confirmPull();
        }
      } while (_requested && !_stopped);
      error = null;
      _failures = 0;
      await local.recordSyncError('');
    } catch (_) {
      // Never log medical data, credentials or raw plugin messages.
      error = 'Não foi possível sincronizar. Seus registros continuam salvos neste aparelho.';
      try {
        await local.recordSyncError('sync-unavailable');
      } catch (_) {
        // A full/unavailable disk must not turn diagnostic logging into an
        // unhandled background failure. Keep the error visible in memory.
      }
      if (!_stopped) {
        _failures++;
        _retry = Timer(
          Duration(seconds: min(300, 5 * pow(2, min(_failures, 6)).toInt())),
          request,
        );
      }
    }
  }

  Future<void> stop() async {
    _stopped = true;
    _retry?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _running;
  }
}
