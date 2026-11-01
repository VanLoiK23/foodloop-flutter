import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cấu hình Firebase đọc từ file .env
/// Lưu ý: phải gọi `await dotenv.load(fileName: '.env')` TRƯỚC khi dùng class này.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase chưa được cấu hình cho nền tảng: $defaultTargetPlatform',
        );
    }
  }

  // Đọc 1 biến từ .env, báo lỗi rõ ràng nếu thiếu
  static String _env(String key, {String? fallbackKey}) {
    final value = dotenv.env[key] ??
        (fallbackKey != null ? dotenv.env[fallbackKey] : null);
    if (value == null || value.isEmpty) {
      throw StateError('Thiếu biến "$key" trong file .env');
    }
    return value;
  }

  static String? _envOptional(String key) {
    final value = dotenv.env[key];
    return (value == null || value.isEmpty) ? null : value;
  }

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _env(
          'FIREBASE_ANDROID_API_KEY',
          fallbackKey: 'EXPO_PUBLIC_FIREBASE_API_KEY',
        ),
        // Ưu tiên App ID của Android, nếu không có thì dùng App ID chung
        appId: _env(
          'FIREBASE_ANDROID_APP_ID',
          fallbackKey: 'EXPO_PUBLIC_FIREBASE_APP_ID',
        ),
        messagingSenderId: _env('EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _env('EXPO_PUBLIC_FIREBASE_PROJECT_ID'),
        storageBucket: _envOptional('EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET'),
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: _env('EXPO_PUBLIC_FIREBASE_API_KEY'),
        appId: _env(
          'FIREBASE_IOS_APP_ID',
          fallbackKey: 'EXPO_PUBLIC_FIREBASE_APP_ID',
        ),
        messagingSenderId: _env('EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _env('EXPO_PUBLIC_FIREBASE_PROJECT_ID'),
        storageBucket: _envOptional('EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET'),
        iosBundleId: _envOptional('FIREBASE_IOS_BUNDLE_ID'),
      );

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _env('EXPO_PUBLIC_FIREBASE_API_KEY'),
        appId: _env('EXPO_PUBLIC_FIREBASE_APP_ID'),
        messagingSenderId: _env('EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _env('EXPO_PUBLIC_FIREBASE_PROJECT_ID'),
        authDomain: _envOptional('EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN'),
        storageBucket: _envOptional('EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET'),
      );
}
