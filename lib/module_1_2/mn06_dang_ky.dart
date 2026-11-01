import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Sửa lại dòng import này cho đúng với cấu trúc dự án của bạn:
import '../services/user_session.dart'; 

class MN06NgK1 extends StatefulWidget {
  const MN06NgK1({super.key});

  @override
  State<MN06NgK1> createState() => _MN06NgK1State();
}

class _MN06NgK1State extends State<MN06NgK1> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;

  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color textColor = Color(0xFF2B3A35);
  static const Color hintColor = Color(0xFF6B7280);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // =========================
  // THÔNG BÁO
  // =========================

  void _showMessage(String message, {bool success = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? primaryColor : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================
  // VALIDATE EMAIL
  // =========================

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email.';
    }

    final emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không đúng định dạng.';
    }

    return null;
  }

  // =========================
  // VALIDATE PASSWORD
  // =========================

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu.';
    }

    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự.';
    }

    return null;
  }

  // =========================
  // ĐĂNG KÝ FIRESTORE
  // =========================

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      _showMessage(
        'Vui lòng đồng ý với điều khoản và chính sách bảo mật.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim().toLowerCase();

      // Kiểm tra email đã tồn tại
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (!mounted) return;

      if (existingUser.docs.isNotEmpty) {
        _showMessage('Email này đã được đăng ký.');
        return;
      }

      // Tạo document ID tự động
      final userDocument = _firestore.collection('users').doc();

      // Dữ liệu tài khoản
      final userData = {
        'userId': userDocument.id,
        'fullName': _nameController.text.trim(),
        'email': email,
        'password': _passwordController.text,
        'avatarUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Lưu tài khoản vào Firestore
      await userDocument.set(userData);

      // Lấy ID người dùng
      final String newUserId = userDocument.id;

      // LƯU USER ID VÀO SESSION
      await UserSession.saveUserId(newUserId);

      if (!mounted) return;

      debugPrint('ĐĂNG KÝ THÀNH CÔNG');
      debugPrint('USER ID: $newUserId');
      debugPrint('SESSION: Đã lưu');

      _showMessage(
        'Tạo tài khoản thành công!',
        success: true,
      );

      // Chuyển sang màn hình chọn vai trò
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/personal_household',
        (route) => false,
        arguments: newUserId,
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'permission-denied':
          message = 'Không có quyền truy cập Firestore.';
          break;

        case 'unavailable':
          message = 'Không thể kết nối máy chủ. Vui lòng thử lại.';
          break;

        case 'network-request-failed':
          message = 'Lỗi kết nối mạng.';
          break;

        default:
          message = 'Đăng ký thất bại: ${e.message ?? e.code}';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage('Đã xảy ra lỗi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =========================
  // LABEL
  // =========================

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: textColor,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          height: 1.43,
        ),
      ),
    );
  }

  // =========================
  // TEXT FIELD DECORATION
  // =========================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: hintColor,
        fontSize: 15,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        icon,
        color: hintColor,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
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
          width: 1.5,
          color: primaryColor,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }

  // =========================
  // TEXT FIELD
  // =========================

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: !_isLoading,
          style: const TextStyle(
            color: textColor,
            fontSize: 15,
            fontFamily: 'Inter',
          ),
          decoration: _inputDecoration(
            hint: hint,
            icon: icon,
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }

  // =========================
  // GIAO DIỆN
  // =========================

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
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LOGO
                  Container(
                    width: 100,
                    height: 100,
                    decoration: ShapeDecoration(
                      image: const DecorationImage(
                        image: NetworkImage(
                          '/assets/images/Logo.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFF831212),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Tạo tài khoản',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.21,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Tham gia FoodLoop để bắt đầu giảm lãng phí thực phẩm.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // HỌ VÀ TÊN
                  _buildTextField(
                    label: 'Họ và tên',
                    hint: 'Nhập tên của bạn',
                    icon: Icons.person_outline,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // EMAIL
                  _buildTextField(
                    label: 'Email',
                    hint: 'Nhập email của bạn',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 14),

                  // MẬT KHẨU
                  _buildTextField(
                    label: 'Password',
                    hint: 'Nhập password của bạn',
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: hintColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // XÁC NHẬN MẬT KHẨU
                  _buildTextField(
                    label: 'Nhập lại password',
                    hint: 'Nhập lại password của bạn',
                    icon: Icons.lock_outline,
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập lại mật khẩu.';
                      }

                      if (value != _passwordController.text) {
                        return 'Mật khẩu xác nhận không khớp.';
                      }

                      return null;
                    },
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: hintColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ĐIỀU KHOẢN
                  CheckboxListTile(
                    value: _acceptedTerms,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: primaryColor,
                    title: const Text(
                      'Tôi đồng ý với các điều khoản và chính sách bảo mật.',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // NÚT TẠO TÀI KHOẢN
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor:
                            primaryColor.withValues(alpha: 0.6),
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
                              'Tạo tài khoản',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CHUYỂN ĐẾN ĐĂNG NHẬP
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            );
                          },
                    child: const Text(
                      'Bạn đã có tài khoản?',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        height: 1.43,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}