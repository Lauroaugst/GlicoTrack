import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/local_database.dart';
import '../data/firebase_repository.dart';
import '../data/sync_service.dart';

class AppBootstrap {
  AppBootstrap._({
    required this.uid,
    required this.local,
    required this.remote,
    required this.sync,
  });

  final String uid;
  final LocalDatabase local;
  final FirebaseRepository remote;
  final SyncService sync;

  static Future<User> restoreSession({FirebaseAuth? auth}) async {
    final client = auth ?? FirebaseAuth.instance;
    final existing = client.currentUser;
    if (existing != null) return existing;
    final credential = await client.signInAnonymously();
    final user = credential.user;
    if (user == null) throw StateError('Não foi possível iniciar a sessão.');
    return user;
  }

  static Future<AppBootstrap> initialize({bool startSync = true}) async {
    // Recupera o usuário autenticado.
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    // Obtém o identificador do usuário.
    final uid = user.uid;

    // Inicializa o banco SQLite criptografado.
    final local = await LocalDatabase.open(uid);

    SyncService? sync;
    try {
      if (FirebaseAuth.instance.currentUser?.uid != uid) {
        throw StateError('Sessão encerrada durante a inicialização.');
      }
      final remote = FirebaseRepository(FirebaseFirestore.instance, uid);
      sync = SyncService(local, remote);
      // AppStore controls startup when Provider owns the session. Other callers
      // retain the existing factory behavior, respecting a pending deletion.
      if (startSync && !await local.deletionPending()) sync.start();
      return AppBootstrap._(uid: uid, local: local, remote: remote, sync: sync);
    } catch (_) {
      await sync?.stop();
      sync?.dispose();
      await local.close();
      rethrow;
    }
  }

  Future<void> dispose() async {
    await sync.stop();
    sync.dispose();
    await local.close();
  }
}
