import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_session.dart';

class MN05Login1 extends StatefulWidget {
  const MN05Login1({super.key});

  @override
  State<MN05Login1> createState() => _MN05Login1State();
}

class _MN05Login1State extends State<MN05Login1> {
  // Controller lấy dữ liệu nhập vào
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Khóa form để validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Trạng thái ẩn/hiện mật khẩu và loading
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng nhập trực tiếp từ Flutter với Firestore
  Future<void> _handleLogin() async {
    // 1. Kiểm tra validation form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ẩn bàn phím ảo
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text; // Không trim password

      // 2. Truy vấn trực tiếp Firestore tìm user theo email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Nếu không tìm thấy email trong hệ thống
      if (querySnapshot.docs.isEmpty) {
        if (!mounted) return;
        _showErrorSnackBar('Email hoặc mật khẩu không chính xác.');
        return;
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      final storedPassword = userData['password'];

      // Kiểm tra mật khẩu khớp hay không
      if (storedPassword != password) {
        if (!mounted) return;
        _showErrorSnackBar('Email hoặc mật khẩu không chính xác.');
        return;
      }
await UserSession.saveUserId(userDoc.id);
      // 3. Cập nhật thời gian đăng nhập gần nhất (lastLoginAt)
      await userDoc.reference.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập thành công!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      // 4. Chuyển sang màn hình chính (Ví dụ chuyển route, bạn có thể thay đổi tên route theo app của bạn)
       Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Lỗi kết nối mạng. Vui lòng kiểm tra lại.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E7),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Header / Logo (Giữ nguyên giao diện cũ)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF831212),
                        width: 1,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage("/assets/images/Logo.png"), // TODO: Thay bằng ảnh thật trong assets
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Tiêu đề
                  const Text(
                    'Chào mừng trở lại',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF2B3A35),
                      fontSize: 28,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.21,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Đăng nhập để tiếp tục sử dụng FoodLoop.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF2B3A35),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. Form Đăng nhập (Email & Password)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: TextStyle(
                        color: Color(0xFF2B3A35),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Ô nhập Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Color(0xFF2B3A35),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập email của bạn',
                      hintStyle: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.50),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 1,
                          color: Color(0x3F2E7D32),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 1,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(width: 1, color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(width: 1, color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email không được để trống.';
                      }
                      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegExp.hasMatch(value.trim())) {
                        return 'Định dạng email không hợp lệ.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        color: Color(0xFF2B3A35),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Ô nhập Password có nút bật/tắt hiển thị
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                      color: Color(0xFF2B3A35),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập password của bạn',
                      hintStyle: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.50),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 1,
                          color: Color(0x3F2E7D32),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 1,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(width: 1, color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(width: 1, color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mật khẩu không được để trống.';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 4. Quên mật khẩu
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Xử lý quên mật khẩu
                      },
                      child: const Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.43,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Nút Đăng nhập tích hợp Loading
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 6. Hoặc đăng nhập với (Social icons)
                  // const Text(
                  //   'Hoặc đăng nhập với',
                  //   style: TextStyle(
                  //     color: Color(0xFF2E7D32),
                  //     fontSize: 14,
                  //     fontFamily: 'Inter',
                  //     fontWeight: FontWeight.w600,
                  //     height: 1.43,
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: NetworkImage("https://placehold.co/30x30"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: NetworkImage("https://placehold.co/30x30"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: NetworkImage("https://placehold.co/30x30"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 7. Đăng ký tài khoản mới
                GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, '/register');
  },
  child: const Text(
    'Bạn chưa có tài khoản?',
    style: TextStyle(
      color: Color(0xFF2E7D32),
      fontSize: 14,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      height: 1.43,
    ),
  ),
),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}