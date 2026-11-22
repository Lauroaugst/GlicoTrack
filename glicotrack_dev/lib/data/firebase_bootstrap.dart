import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

/// Values are supplied by --dart-define-from-file=firebase.local.json or native
/// FlutterFire configuration. No placeholder credentials and no demo auth bypass.
Future<void> initializeFirebase() async {
  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  if (apiKey.isNotEmpty) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: apiKey,
        appId: String.fromEnvironment('FIREBASE_APP_ID'),
        messagingSenderId: String.fromEnvironment(
          'FIREBASE_MESSAGING_SENDER_ID',
        ),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
        iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  // SQLite is the encrypted persistent store; disable the unencrypted SDK cache.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );
  const emulatorHost = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
  if (emulatorHost.isNotEmpty) {
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(emulatorHost, 5001);
  }
}
