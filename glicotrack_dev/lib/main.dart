import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glicotrack_dev/screens/splash_screen.dart';

import 'services/app_bootstrap.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Recupera o usuário autenticado.
  var user = FirebaseAuth.instance.currentUser;

  // Cria uma sessão anônima caso não exista usuário.
  if (user == null) {
    final credential = await FirebaseAuth.instance.signInAnonymously();
    user = credential.user;
  }

  if (user == null) {
    throw StateError('Não foi possível autenticar o usuário.');
  }

  // Inicializa SQLite, Firestore e sincronização.
  final services = await AppBootstrap.initialize();

  debugPrint('Banco de dados inicializado para o usuário autenticado.');

  // Inicia a interface do aplicativo.
  runApp(GlicoTrackApp(services: services));
}

class GlicoTrackApp extends StatelessWidget {
  const GlicoTrackApp({super.key, required this.services});

  final AppBootstrap services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlicoTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE3F1FD),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0060C0)),
        fontFamily: 'Roboto',
      ),
     home: SplashScreen(
  localDatabase: services.local,
),
    );
  }
}
