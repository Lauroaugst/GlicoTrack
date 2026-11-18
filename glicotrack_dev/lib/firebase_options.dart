import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBzuPwNYthetyhqyxpst3U9KiVvEhmxocw',
    appId: '1:905174798749:web:c86d555a0664f51e9a5f74',
    messagingSenderId: '905174798749',
    projectId: 'glicotrack-bf802',
    authDomain: 'glicotrack-bf802.firebaseapp.com',
    storageBucket: 'glicotrack-bf802.firebasestorage.app',
    measurementId: 'G-GJQ7WEH91Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDXBihx-MsW_TqvBOqs6MEcSZUM-uIa5Fo',
    appId: '1:905174798749:android:971ac439cad75b829a5f74',
    messagingSenderId: '905174798749',
    projectId: 'glicotrack-bf802',
    storageBucket: 'glicotrack-bf802.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlr7QhGMaoRtVBz6YgJl12CcYv-ViXZa0',
    appId: '1:905174798749:ios:c759f5b5feed520f9a5f74',
    messagingSenderId: '905174798749',
    projectId: 'glicotrack-bf802',
    storageBucket: 'glicotrack-bf802.firebasestorage.app',
    iosBundleId: 'com.example.glicotrackDev',
  );
}
