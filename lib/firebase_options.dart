import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCJ4uY6JssnyTWPls0TSiM1JUFGBcTpN0s",
    appId: "1:315746727470:web:ab54fc457ecaf50bbe91bf",
    messagingSenderId: "315746727470",
    projectId: "codex-fb283",
    authDomain: "codex-fb283.firebaseapp.com",
    storageBucket: "codex-fb283.firebasestorage.app",
    measurementId: "G-05CWHC0Z84", // مطلوب فقط للويب
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJ4uY6JssnyTWPls0TSiM1JUFGBcTpN0s',
    appId: '1:315746727470:web:ab54fc457ecaf50bbe91bf',
    messagingSenderId: '315746727470',
    projectId: 'codex-fb283',
    storageBucket: 'codex-fb283.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJ4uY6JssnyTWPls0TSiM1JUFGBcTpN0s',
    appId: '1:315746727470:web:ab54fc457ecaf50bbe91bf',
    messagingSenderId: '315746727470',
    projectId: 'codex-fb283',
    storageBucket: 'codex-fb283.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCJ4uY6JssnyTWPls0TSiM1JUFGBcTpN0s',
    appId: '1:315746727470:web:ab54fc457ecaf50bbe91bf',
    messagingSenderId: '315746727470',
    projectId: 'codex-fb283',
    storageBucket: 'codex-fb283.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCJ4uY6JssnyTWPls0TSiM1JUFGBcTpN0s',
    appId: '1:315746727470:web:ab54fc457ecaf50bbe91bf',
    messagingSenderId: '315746727470',
    projectId: 'codex-fb283',
    storageBucket: 'codex-fb283.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCJ4uY6JssnyTWPls0TSiM1JUFGBcTpN0s',
    appId: '1:315746727470:web:ab54fc457ecaf50bbe91bf',
    messagingSenderId: '315746727470',
    projectId: 'codex-fb283',
    storageBucket: 'codex-fb283.firebasestorage.app',
  );
}