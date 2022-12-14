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
    apiKey: 'AIzaSyDfYftSocfX0HwhfC5J5b68jHoSw2KBS-w',
    appId: '1:1016551248064:web:87b390839f03d8aa515d25',
    messagingSenderId: '1016551248064',
    projectId: 'agora-basic',
    androidClientId:
        '1016551248064-gmj5u3vbrquk17ihc87po54a61kl9l2j.apps.googleusercontent.com',
    iosClientId:
        '1016551248064-clilivalhj7q1jql6p26fu7n5j5o93e3.apps.googleusercontent.com',
    authDomain: 'agora-basic.firebaseapp.com',
    storageBucket: 'agora-basic.appspot.com',
    measurementId: 'G-DRBW9T4GSV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDeSvZKUOJrbplgjTJaP-nzqSVsYE8MLqY',
    appId: '1:1016551248064:android:901016ed21eaa8d4515d25',
    messagingSenderId: '1016551248064',
    projectId: 'agora-basic',
    storageBucket: 'agora-basic.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhoNg3_PMvKV7AR0NiYPj_LNiO-EccZTo',
    appId: '1:1016551248064:ios:1ad3812adde3b7ff515d25',
    messagingSenderId: '1016551248064',
    projectId: 'agora-basic',
    storageBucket: 'agora-basic.appspot.com',
    androidClientId:
        '1016551248064-gmj5u3vbrquk17ihc87po54a61kl9l2j.apps.googleusercontent.com',
    iosClientId:
        '1016551248064-clilivalhj7q1jql6p26fu7n5j5o93e3.apps.googleusercontent.com',
    iosBundleId: 'com.example.agoraDemo',
  );
}
