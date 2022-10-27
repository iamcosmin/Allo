// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAyLt2_FAHc0I2c1iBLH_MxWzo2kllSvA8',
    appId: '1:1049075385887:web:89f4887e574f8b93f2372a',
    messagingSenderId: '1049075385887',
    projectId: 'allo-ms',
    authDomain: 'allo-ms.firebaseapp.com',
    storageBucket: 'allo-ms.appspot.com',
    measurementId: 'G-N5D9CRB413',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmMz7REpzPdTuKbzDsXg57ZE8DfZ6zgNU',
    appId: '1:1049075385887:android:5d91ff67a3a076aff2372a',
    messagingSenderId: '1049075385887',
    projectId: 'allo-ms',
    storageBucket: 'allo-ms.appspot.com',
  );
}