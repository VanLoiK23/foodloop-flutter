import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const String _userIdKey = 'userId';

  /// Lưu ID người dùng sau khi đăng ký/đăng nhập.
  static Future<void> saveUserId(String userId) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User ID không được để trống.');
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  /// Lấy ID người dùng hiện tại.
  static Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Kiểm tra trạng thái đăng nhập.
  static Future<bool> isLoggedIn() async {
    final String? userId = await getUserId();
    return userId != null && userId.trim().isNotEmpty;
  }

  /// Xóa session khi đăng xuất.
  static Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}
