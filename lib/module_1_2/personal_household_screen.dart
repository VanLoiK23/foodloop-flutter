import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/user_session.dart';

class MN08PersonalHousehold extends StatefulWidget {
  const MN08PersonalHousehold({super.key});

  @override
  State<MN08PersonalHousehold> createState() =>
      _MN08PersonalHouseholdState();
}

class _MN08PersonalHouseholdState
    extends State<MN08PersonalHousehold> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String? selectedRole;
  String? userDocumentId;

  bool isLoading = true;

  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color textColor = Color(0xFF2B3A35);
  static const Color hintColor = Color(0xFF6B7280);

  // =========================
  // LẤY UID TỪ SESSION
  // =========================

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final sessionUserId = await UserSession.getUserId();
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      final userId = (sessionUserId != null && sessionUserId.trim().isNotEmpty)
          ? sessionUserId
          : authUid;

      if (userId != null && userId.trim().isNotEmpty) {
        userDocumentId = userId;
        try {
          final doc = await _firestore.collection('users').doc(userId).get();
          if (doc.exists && doc.data() != null) {
            final role = doc.data()!['role']?.toString();
            if (role != null && role.isNotEmpty) {
              selectedRole = role;
            }
          }
        } catch (_) {}
      }

      // Mặc định chọn Cá nhân theo Figma nếu chưa có dữ liệu
      selectedRole ??= 'Cá nhân';

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        selectedRole ??= 'Cá nhân';
        isLoading = false;
      });
    }
  }

  // =========================
  // THÔNG BÁO
  // =========================

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              success ? primaryColor : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =========================
  // LƯU ROLE FIRESTORE
  // =========================

  Future<void> saveRole() async {
    if (isLoading) return;

    // Kiểm tra lựa chọn
    if (selectedRole == null) {
      _showMessage(
        'Vui lòng chọn Cá nhân hoặc Hộ gia đình.',
      );
      return;
    }

    // Nếu chưa có UID thì thử lấy lại từ Session
    String? userId = userDocumentId;

    if (userId == null || userId.trim().isEmpty) {
      userId = await UserSession.getUserId();
    }

    // Không có session
    if (userId == null || userId.trim().isEmpty) {
      _showMessage(
        'Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.',
      );
      return;
    }

    userDocumentId = userId;

    setState(() {
      isLoading = true;
    });

    try {
      // users/{uid}
      final userRef = _firestore
          .collection('users')
          .doc(userId);

      // Kiểm tra tài khoản có tồn tại
      final userSnapshot = await userRef.get();

      if (!mounted) return;

      if (!userSnapshot.exists) {
        _showMessage(
          'Tài khoản không tồn tại trong hệ thống.',
        );
        return;
      }

      // Lưu role vào đúng users/{uid}
      await userRef.update({
        'role': selectedRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showMessage(
        'Cập nhật vai trò thành công!',
        success: true,
      );

      // Không truyền arguments nữa.
      // Profile sẽ tự lấy UID từ UserSession.
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/profile_setup',
        (route) => false,
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      _showMessage(
        'Lỗi Firestore: ${e.message ?? e.code}',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Đã xảy ra lỗi: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================
  // BỎ QUA
  // =========================

  Future<void> _skip() async {
    if (isLoading) return;

    final userId = await UserSession.getUserId();

    if (!mounted) return;

    if (userId == null || userId.trim().isEmpty) {
      _showMessage(
        'Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.',
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/profile_setup',
      (route) => false,
    );
  }

  // =========================
  // THẺ LỰA CHỌN ROLE
  // =========================

  Widget buildRoleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              setState(() {
                selectedRole = role;
              });
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: isSelected
              ? const Color(0xFFE8F5E9)
              : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: isSelected ? 2 : 1,
              color: isSelected
                  ? primaryColor
                  : const Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 26,
              color: textColor,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.33,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: const TextStyle(
                      color: hintColor,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // =========================
  // INDICATOR
  // =========================

  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // BỎ QUA
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                        isLoading ? null : _skip,
                    child: const Text(
                      'Bỏ qua',
                      style: TextStyle(
                        color: hintColor,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // TIÊU ĐỀ
                const Text(
                  'Bạn sử dụng FoodLoop cho ai?',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Chọn cách bạn muốn quản lý thực phẩm.',
                  style: TextStyle(
                    color: hintColor,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // CÁ NHÂN
                buildRoleCard(
                  role: 'personal',
                  title: 'Cá nhân',
                  description:
                      'Quản lý thực phẩm của riêng bạn',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 16),

                // HỘ GIA ĐÌNH
                buildRoleCard(
                  role: 'household',
                  title: 'Hộ gia đình',
                  description:
                      'Cùng quản lý thực phẩm với gia đình',
                  icon: Icons.home_outlined,
                ),

                const Spacer(),

                // INDICATOR
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDot(primaryColor),

                      const SizedBox(width: 8),

                      _buildDot(
                        const Color(0xFFE5E7EB),
                      ),

                      const SizedBox(width: 8),

                      _buildDot(
                        const Color(0xFFE5E7EB),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // NÚT TIẾP TỤC
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor:
                          Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed:
                        isLoading ? null : saveRole,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Tiếp tục',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight:
                                  FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}