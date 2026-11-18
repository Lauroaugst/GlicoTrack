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

  static Future<AppBootstrap> initialize() async {
    // Recupera o usuário autenticado.
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    // Obtém o identificador do usuário.
    final uid = user.uid;

    // Inicializa o banco SQLite criptografado.
    final local = await LocalDatabase.open(uid);

    // Inicializa o repositório remoto do Firestore.
    final remote = FirebaseRepository(FirebaseFirestore.instance, uid);

    // Cria e inicia o serviço de sincronização.
    final sync = SyncService(local, remote);
    sync.start();

    return AppBootstrap._(uid: uid, local: local, remote: remote, sync: sync);
  }

  Future<void> dispose() async {
    await sync.stop();
    sync.dispose();
    await local.close();
  }
}
