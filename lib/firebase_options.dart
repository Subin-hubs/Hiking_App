import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARlmcowtMTggVTt09ZaRTps7Boo7thFnc',
    appId: '1:799807802561:android:67ff9316e4866a9bd61840',
    messagingSenderId: '799807802561',
    projectId: 'hiking-56092',
    storageBucket: 'hiking-56092.firebasestorage.app',
    androidClientId: '799807802561-5cl7khngb8drso04e28if0sfmeiqei8a.apps.googleusercontent.com',
  );
}