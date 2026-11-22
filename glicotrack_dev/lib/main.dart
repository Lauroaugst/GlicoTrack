import 'package:material_ui/material_ui.dart';

import 'data/firebase_bootstrap.dart';
import 'screens/auth_gate.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const GlicoTrackApp());
}

class GlicoTrackApp extends StatelessWidget {
  const GlicoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlicoTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE3F1FD),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0060C0)),
        fontFamily: 'Roboto', // Ou a fonte que estiver utilizando
      ),
      // O aplicativo agora começa pela SplashScreen
      home: const _Bootstrap(),
    );
  }
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late Future<void> _initialization = initializeFirebase();
  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings_outlined, size: 64),
                  const Text(
                    'A conexão segura precisa ser configurada. Consulte a configuração Firebase na documentação do projeto.',
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _initialization = initializeFirebase()),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const SplashScreen();
      }
      return const AuthGate();
    },
  );
}
