 
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/user_session.dart';

class Screen102SystemPermissions extends StatefulWidget {
  const Screen102SystemPermissions({super.key});

  @override
  State<Screen102SystemPermissions> createState() =>
      _Screen102SystemPermissionsState();
}

class _Screen102SystemPermissionsState
    extends State<Screen102SystemPermissions> {
  bool _isLoading = false;

  // Trạng thái chọn quyền
  bool _notificationSelected = false;
  bool _cameraSelected = false;
  bool _locationSelected = false;

  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color textColor = Color(0xFF2B3A35);
  static const Color hintColor = Color(0xFF6B7280);
  static const Color backgroundColor = Color(0xFFFFF8E7);

  // =========================
  // THÔNG BÁO
  // =========================

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  // =========================
  // CAMERA
  // =========================

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isDenied) {
      await Permission.camera.request();
    }
  }

  // =========================
  // VỊ TRÍ
  // =========================

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.status;

    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  // =========================
  // CHO PHÉP QUYỀN ĐÃ CHỌN
  // =========================

  Future<void> _allowPermissions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Kiểm tra Session
      final userId = await UserSession.getUserId();

      if (!mounted) return;

      if (userId == null || userId.trim().isEmpty) {
        _showMessage(
          'Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.',
          isError: true,
        );
        return;
      }

      // 2. Chỉ xin quyền Thông báo nếu đã chọn
      if (_notificationSelected) {
        await _requestNotificationPermission();
      }

      // 3. Chỉ xin quyền Camera nếu đã chọn
      if (_cameraSelected) {
        await _requestCameraPermission();
      }

      // 4. Chỉ xin quyền Vị trí nếu đã chọn
      if (_locationSelected) {
        await _requestLocationPermission();
      }

      if (!mounted) return;

      // 5. Hoàn tất → Home
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Không thể xử lý quyền truy cập: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =========================
  // BỎ QUA
  // =========================

  Future<void> _skipPermissions() async {
    if (_isLoading) return;

    final userId = await UserSession.getUserId();

    if (!mounted) return;

    if (userId == null || userId.trim().isEmpty) {
      _showMessage(
        'Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.',
        isError: true,
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  // =========================
  // MESSAGE
  // =========================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade700 : primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =========================
  // BUILD
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
              backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // BỎ QUA
                // =========================

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                        _isLoading ? null : _skipPermissions,
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

                const SizedBox(height: 4),

                // =========================
                // TIÊU ĐỀ
                // =========================

                const Center(
                  child: Text(
                    'Hoàn tất thiết lập',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Cho phép FoodLoop sử dụng một số quyền để hỗ trợ bạn tốt hơn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: hintColor,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================
                // DANH SÁCH QUYỀN
                // =========================

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // =========================
                        // THÔNG BÁO
                        // =========================

                        _buildPermissionCard(
                          icon: Icons.notifications_outlined,
                          title: 'Thông báo',
                          description:
                              'Cho phép FoodLoop gửi thông báo nhắc bạn khi thực phẩm sắp hết hạn, cập nhật hoạt động trong hộ gia đình và thông báo về các hoạt động chia sẻ thực phẩm.',
                          selected: _notificationSelected,
                          onTap: () {
                            setState(() {
                              _notificationSelected =
                                  !_notificationSelected;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // =========================
                        // CAMERA
                        // =========================

                        _buildPermissionCard(
                          icon: Icons.camera_alt_outlined,
                          title: 'Camera',
                          description:
                              'Cho phép FoodLoop sử dụng camera để quét mã vạch và chụp hóa đơn thực phẩm. Thông tin được quét có thể giúp bạn nhanh chóng thêm thực phẩm vào tủ lạnh ảo và quản lý hạn sử dụng.',
                          selected: _cameraSelected,
                          onTap: () {
                            setState(() {
                              _cameraSelected =
                                  !_cameraSelected;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // =========================
                        // VỊ TRÍ
                        // =========================

                        _buildPermissionCard(
                          icon: Icons.location_on_outlined,
                          title: 'Vị trí',
                          description:
                              'Cho phép FoodLoop sử dụng vị trí của bạn để hiển thị các thực phẩm được chia sẻ và những điểm cộng đồng gần bạn trên bản đồ.',
                          selected: _locationSelected,
                          onTap: () {
                            setState(() {
                              _locationSelected =
                                  !_locationSelected;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // INDICATOR
                // =========================

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDot(false),
                      const SizedBox(width: 8),
                      _buildDot(true),
                      const SizedBox(width: 8),
                      _buildDot(false),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // NÚT CHO PHÉP
                // =========================

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor:
                          primaryColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed:
                        _isLoading ? null : _allowPermissions,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Cho phép quyền truy cập',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 1.50,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // PERMISSION CARD
  // =========================

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: selected
              ? const Color(0xFFE8F5E9)
              : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: selected ? 2 : 1,
              color: selected
                  ? const Color(0xFF3E9B6A)
                  : const Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: selected
                      ? const Color(0xFF3E9B6A)
                      : textColor,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.33,
                    ),
                  ),
                ),

                // Dấu chọn
                AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 180),
                  child: selected
                      ? const Icon(
                          Icons.check_circle,
                          key: ValueKey('selected'),
                          color: Color(0xFF3E9B6A),
                          size: 24,
                        )
                      : const Icon(
                          Icons.radio_button_unchecked,
                          key: ValueKey('unselected'),
                          color: Color(0xFFD1D5DB),
                          size: 24,
                        ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              description,
              textAlign: TextAlign.justify,
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
    );
  }

  // =========================
  // DOT
  // =========================

  Widget _buildDot(bool active) {
    return Container(
      width: 6,
      height: 6,
      decoration: ShapeDecoration(
        color: active
            ? primaryColor
            : const Color(0xFFE5E7EB),
        shape: const OvalBorder(),
      ),
    );
  }
}
 