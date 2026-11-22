import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _message;

  Future<void> _submit({bool reset = false}) async {
    if (_busy) return;
    final email = _email.text.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ||
        (!reset &&
            (_password.text.length < 6 ||
                (_register &&
                    (_name.text.trim().isEmpty || _name.text.length > 120))))) {
      setState(
        () => _message = 'Informe um e-mail válido, senha com pelo menos 6 caracteres e seu nome no cadastro.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (reset) {
        await auth.sendPasswordResetEmail(email: email);
        if (mounted) {
          setState(
            () => _message = 'Se houver uma conta com esse e-mail, você receberá as instruções.',
          );
        }
      } else if (_register) {
        final current = auth.currentUser;
        // The previous startup created anonymous accounts. Link the account
        // instead of replacing its UID, so existing local/remote records stay owned.
        final credential = current != null && current.isAnonymous
            ? await current.linkWithCredential(
                EmailAuthProvider.credential(
                  email: email,
                  password: _password.text,
                ),
              )
            : await auth.createUserWithEmailAndPassword(
                email: email,
                password: _password.text,
              );
        await credential.user?.updateDisplayName(_name.text.trim());
      } else {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: _password.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(
          () => _message = switch (error.code) {
            'network-request-failed' => 'Conecte-se à internet para entrar ou criar uma conta. A sessão já iniciada funciona offline.',
            'weak-password' => 'Escolha uma senha mais forte.',
            'too-many-requests' =>
              'Muitas tentativas. Aguarde e tente novamente.',
            'email-already-in-use' || 'credential-already-in-use' => 'Esse e-mail já tem uma conta. Entre nela para consultar o histórico dessa conta ou use outro e-mail para vincular esta sessão.',
            _ => 'Não foi possível entrar. Confira os dados ou recupere sua senha.',
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'Não foi possível concluir. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF0060C0),
      foregroundColor: Colors.white,
      title: const Text('GlicoTrack'),
      centerTitle: true,
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (FirebaseAuth.instance.currentUser?.isAnonymous == true)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Você tem uma sessão temporária neste aparelho. Crie uma conta para manter seus registros. Entrar em outra conta abre o histórico dela.',
                    ),
                  ),
                Text(
                  _register ? 'Criar conta' : 'Entrar',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                if (_register)
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                  ),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  autofillHints: [
                    _register
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                if (_message != null)
                  Semantics(liveRegion: true, child: Text(_message!)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(
                      _busy
                          ? 'Aguarde…'
                          : _register
                          ? 'Criar conta'
                          : 'Entrar',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          _register = !_register;
                          _message = null;
                        }),
                  child: Text(_register ? 'Já tenho conta' : 'Criar uma conta'),
                ),
                TextButton(
                  onPressed: _busy ? null : () => _submit(reset: true),
                  child: const Text('Esqueci minha senha'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
