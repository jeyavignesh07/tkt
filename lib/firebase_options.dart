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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyCEvt8re7FnqGre9R6QA1czTR2n1AL0fCg',
    appId: '1:37586350703:web:124a0cdd89cdbad119139a',
    messagingSenderId: '37586350703',
    projectId: 'hits429',
    authDomain: 'hits429.firebaseapp.com',
    storageBucket: 'hits429.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWOGDk9ecjeDoltI6IZ20AaKnpxf2ybqc',
    appId: '1:37586350703:android:bcdbfd4d7d1389eb19139a',
    messagingSenderId: '37586350703',
    projectId: 'hits429',
    storageBucket: 'hits429.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgkvW15UvAP1jxsSNE4b9MtR5fkXgvMN0',
    appId: '1:37586350703:ios:b0fc4afd7fd536fd19139a',
    messagingSenderId: '37586350703',
    projectId: 'hits429',
    storageBucket: 'hits429.appspot.com',
    iosBundleId: 'com.example.ticketApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCgkvW15UvAP1jxsSNE4b9MtR5fkXgvMN0',
    appId: '1:37586350703:ios:b0fc4afd7fd536fd19139a',
    messagingSenderId: '37586350703',
    projectId: 'hits429',
    storageBucket: 'hits429.appspot.com',
    iosBundleId: 'com.example.ticketApp',
  );
}