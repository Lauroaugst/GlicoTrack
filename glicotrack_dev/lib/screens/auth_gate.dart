import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../services/app_bootstrap.dart';
import '../domain/models.dart';
import '../presentation/app_store.dart';
import 'main_screen.dart';
import 'splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<User?> _auth = FirebaseAuth.instance.userChanges();
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: _auth,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SplashScreen();
      }
      if (snapshot.hasError) {
        return const Scaffold(
          body: Center(
            child: Text(
              'Não foi possível verificar sua sessão. Reinicie o aplicativo.',
            ),
          ),
        );
      }
      final user = snapshot.data;
      return user == null
          ? const _AnonymousSession()
          : _UserSession(key: ValueKey(user.uid), user: user);
    },
  );
}

class _AnonymousSession extends StatefulWidget {
  const _AnonymousSession();

  @override
  State<_AnonymousSession> createState() => _AnonymousSessionState();
}

class _AnonymousSessionState extends State<_AnonymousSession> {
  late Future<User> _session = AppBootstrap.restoreSession();

  @override
  Widget build(BuildContext context) => FutureBuilder<User>(
    future: _session,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Conecte-se à internet para iniciar o aplicativo pela primeira vez.',
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _session = AppBootstrap.restoreSession()),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        );
      }
      // The auth stream opens the existing screens as soon as the session exists.
      return const SplashScreen();
    },
  );
}

class _UserSession extends StatefulWidget {
  const _UserSession({super.key, required this.user});
  final User user;
  @override
  State<_UserSession> createState() => _UserSessionState();
}

class _UserSessionState extends State<_UserSession>
    with WidgetsBindingObserver {
  late Future<AppStore> _loading;
  AppStore? _store;

  PatientProfile _authProfile(User user) => PatientProfile(
    name: user.displayName ?? user.email?.split('@').first ?? 'Paciente',
    email: user.email ?? '',
    createdAt: user.metadata.creationTime ?? DateTime.now(),
  );

  @override
  void didUpdateWidget(covariant _UserSession oldWidget) {
    super.didUpdateWidget(oldWidget);
    _store?.updateAuthProfile(_authProfile(widget.user));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loading = _open();
  }

  Future<AppStore> _open() async {
    final user = widget.user;
    final services = await AppBootstrap.initialize(startSync: false);
    final store = AppStore(
      uid: user.uid,
      local: services.local,
      sync: services.sync,
      passwordRequiredForDeletion: user.providerData.any(
        (provider) => provider.providerId == 'password',
      ),
      initialProfile: PatientProfile(
        name: user.displayName ?? user.email?.split('@').first ?? 'Paciente',
        email: user.email ?? '',
        createdAt:
            DateTime.tryParse(
              user.metadata.creationTime?.toIso8601String() ?? '',
            ) ??
            DateTime.now(),
      ),
    );
    try {
      await store.initialize();
    } catch (_) {
      store.dispose();
      rethrow;
    }
    if (!mounted) {
      store.dispose();
      throw StateError('Sessão encerrada.');
    }
    _store = store;
    store.updateAuthProfile(_authProfile(widget.user));
    return store;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _store?.sync.request();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppStore>(
    future: _loading,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Não foi possível abrir o armazenamento seguro.'),
                TextButton(
                  onPressed: () => setState(() => _loading = _open()),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const SplashScreen();
      }
      return ChangeNotifierProvider.value(
        value: snapshot.data!,
        child: Navigator(
          onGenerateRoute: (_) =>
              MaterialPageRoute<void>(builder: (_) => const MainScreen()),
        ),
      );
    },
  );
}
