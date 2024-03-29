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
    apiKey: 'AIzaSyBj__3Smu7osreJeUzgqO6hjdHupdZGbj4',
    appId: '1:699956929703:web:3885bafc63062190892782',
    messagingSenderId: '699956929703',
    projectId: 'kitepay-org',
    authDomain: 'kitepay-org.firebaseapp.com',
    storageBucket: 'kitepay-org.appspot.com',
    measurementId: 'G-FN9ZRPFGPC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCOTfX3ENbfNA-Rq22kqK-HVKaVGNDTnG4',
    appId: '1:699956929703:android:1638837987b142aa892782',
    messagingSenderId: '699956929703',
    projectId: 'kitepay-org',
    storageBucket: 'kitepay-org.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAJHmCvpjcJa-_rdmmWBhAIuF0wvX_vhM',
    appId: '1:699956929703:ios:f4d494b9ab1f74c9892782',
    messagingSenderId: '699956929703',
    projectId: 'kitepay-org',
    storageBucket: 'kitepay-org.appspot.com',
    iosClientId: '699956929703-ojfnd430sukfm0sd9of9rspb9sks0q4p.apps.googleusercontent.com',
    iosBundleId: 'org.kitepay',
  );
}
