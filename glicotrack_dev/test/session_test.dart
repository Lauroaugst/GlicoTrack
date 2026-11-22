import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glicotrack_dev/services/app_bootstrap.dart';

class _User extends Fake implements User {}

class _Credential extends Fake implements UserCredential {
  _Credential(this.user);
  @override
  final User? user;
}

class _Auth extends Fake implements FirebaseAuth {
  _Auth({this.currentUser, this.createdUser, this.failure});
  @override
  final User? currentUser;
  final User? createdUser;
  final Exception? failure;
  int signIns = 0;

  @override
  Future<UserCredential> signInAnonymously() async {
    signIns++;
    if (failure != null) throw failure!;
    return _Credential(createdUser);
  }
}

void main() {
  test(
    'reuses the persisted session without network or changing its UID',
    () async {
      final user = _User();
      final auth = _Auth(currentUser: user);
      expect(await AppBootstrap.restoreSession(auth: auth), same(user));
      expect(auth.signIns, 0);
    },
  );

  test(
    'first launch creates an anonymous session without asking for credentials',
    () async {
      final user = _User();
      final auth = _Auth(createdUser: user);
      expect(await AppBootstrap.restoreSession(auth: auth), same(user));
      expect(auth.signIns, 1);
    },
  );

  test('failed first connection propagates for retry instead of opening another UID', () async {
    final failure = FirebaseAuthException(code: 'network-request-failed');
    final auth = _Auth(failure: failure);
    await expectLater(
      AppBootstrap.restoreSession(auth: auth),
      throwsA(same(failure)),
    );
    expect(auth.signIns, 1);
  });
}
