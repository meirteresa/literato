// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyCOc-uKOa-0bh8zCpzvWcW4WPzgoWzxoXo',
    appId: '1:337568742739:web:91031cb432c38d6becf5a6',
    messagingSenderId: '337568742739',
    projectId: 'literato-594a6',
    authDomain: 'literato-594a6.firebaseapp.com',
    storageBucket: 'literato-594a6.firebasestorage.app',
    measurementId: 'G-Z275L9W5M5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkUOnkYm5OgjSw_KHQXYsXrsk9-bnZBtE',
    appId: '1:337568742739:android:52dc1c7e9434b7d1ecf5a6',
    messagingSenderId: '337568742739',
    projectId: 'literato-594a6',
    storageBucket: 'literato-594a6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVJYZ-mDWTVHk07Ghb2-C_ACHsLP7lfGs',
    appId: '1:337568742739:ios:307a94e825258e86ecf5a6',
    messagingSenderId: '337568742739',
    projectId: 'literato-594a6',
    storageBucket: 'literato-594a6.firebasestorage.app',
    iosBundleId: 'com.example.literato',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBVJYZ-mDWTVHk07Ghb2-C_ACHsLP7lfGs',
    appId: '1:337568742739:ios:307a94e825258e86ecf5a6',
    messagingSenderId: '337568742739',
    projectId: 'literato-594a6',
    storageBucket: 'literato-594a6.firebasestorage.app',
    iosBundleId: 'com.example.literato',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCOc-uKOa-0bh8zCpzvWcW4WPzgoWzxoXo',
    appId: '1:337568742739:web:705b36b4040dea4eecf5a6',
    messagingSenderId: '337568742739',
    projectId: 'literato-594a6',
    authDomain: 'literato-594a6.firebaseapp.com',
    storageBucket: 'literato-594a6.firebasestorage.app',
    measurementId: 'G-LH2WMW6PWB',
  );

}