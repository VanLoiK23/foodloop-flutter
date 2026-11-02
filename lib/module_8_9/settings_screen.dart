import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/action_card.dart';
import '../components/app_switch.dart';
import '../components/bottom_nav.dart';
import '../components/primary_button.dart';
import '../components/screen_header.dart';
import '../services/foodloop_firestore_service.dart';
import '../services/foodloop_seeder_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 100: "Cài đặt"
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 4,
        onTap: (index) {
          // Xử lý chuyển tab
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header chính
            const ScreenHeader(
              title: 'Cài đặt',
              showBackButton: false,
            ),

            // StreamBuilder lắng nghe cài đặt từ Firestore
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FoodLoopFirestoreService.streamUserSettings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTokens.brand),
                    );
                  }

                  final data = snapshot.data?.data() ?? {};

                  // Trích xuất các thuộc tính từ Firestore
                  final String profileName = data['profileName'] ?? 'Thông tin cá nhân';
                  final String profileSubtitle = data['profileSubtitle'] ?? 'Hồ sơ cộng đồng';
                  final String honorCards = data['honorCards'] ?? '3 thẻ';
                  final String badgeSubtitle = data['badgeSubtitle'] ?? 'Thành tựu của bạn';

                  // Trạng thái các công tắc từ Firestore
                  final bool remindExpiry = data['remindExpiry'] ?? true;
                  final bool recipeSuggestions = data['recipeSuggestions'] ?? true;
                  final bool receiveRequests = data['receiveRequests'] ?? true;

                  final String profileVisibility = data['profileVisibility'] ?? 'Ai có thể xem hồ sơ của bạn';
                  final String locationSharing = data['locationSharing'] ?? 'Chỉ hiển thị khu vực gần đúng';

                  final bool locationPermission = data['locationPermission'] ?? true;
                  final bool cameraPermission = data['cameraPermission'] ?? true;
                  final bool pushNotificationPermission = data['pushNotificationPermission'] ?? true;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Hồ sơ cá nhân'),
                        const SizedBox(height: AppTokens.space8),
                        ActionCard(
                          title: profileName,
                          subtitle: profileSubtitle,
                          onTap: () => Navigator.pushNamed(context, '/community-profile'),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        _buildSectionTitle('Hộ gia đình'),
                        const SizedBox(height: AppTokens.space8),
                        ActionCard(
                          title: 'Thẻ vinh danh',
                          subtitle: honorCards,
                          onTap: () => Navigator.pushNamed(context, '/honor-card'),
                        ),
                        const SizedBox(height: AppTokens.space10),
                        ActionCard(
                          title: 'Huy hiệu',
                          subtitle: badgeSubtitle,
                          onTap: () => Navigator.pushNamed(context, '/achievements'),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        _buildSectionTitle('Thông báo'),
                        const SizedBox(height: AppTokens.space8),
                        ActionCard(
                          title: 'Nhắc hạn dùng',
                          subtitle: 'Báo trước 2 ngày khi thực phẩm sắp hết hạn',
                          trailing: AppSwitch(
                            value: remindExpiry,
                            onChanged: (val) {
                              FoodLoopFirestoreService.updateSetting('remindExpiry', val);
                            },
                          ),
                        ),
                        const SizedBox(height: AppTokens.space10),
                        ActionCard(
                          title: 'Gợi ý công thức',
                          subtitle: 'Gợi ý món từ nguyên liệu sắp hết hạn',
                          trailing: AppSwitch(
                            value: recipeSuggestions,
                            onChanged: (val) {
                              FoodLoopFirestoreService.updateSetting('recipeSuggestions', val);
                            },
                          ),
                        ),
                        const SizedBox(height: AppTokens.space10),
                        ActionCard(
                          title: 'Yêu cầu nhận đồ',
                          subtitle: 'Khi có người xin thực phẩm bạn chia sẻ',
                          trailing: AppSwitch(
                            value: receiveRequests,
                            onChanged: (val) {
                              FoodLoopFirestoreService.updateSetting('receiveRequests', val);
                            },
                          ),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        _buildSectionTitle('Quyền riêng tư'),
                        const SizedBox(height: AppTokens.space8),
                        ActionCard(
                          title: 'Hiển thị hồ sơ',
                          subtitle: profileVisibility,
                          onTap: () => _showNotice(context, 'Cài đặt quyền hiển thị hồ sơ'),
                        ),
                        const SizedBox(height: AppTokens.space10),
                        ActionCard(
                          title: 'Chia sẻ vị trí',
                          subtitle: locationSharing,
                          onTap: () => _showNotice(context, 'Cài đặt chia sẻ vị trí'),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        _buildSectionTitle('Quyền thiết bị'),
                        const SizedBox(height: AppTokens.space8),
                        ActionCard(
                          title: 'Vị trí',
                          subtitle: 'Tìm điểm tặng đồ gần nhà',
                          trailing: AppSwitch(
                            value: locationPermission,
                            onChanged: (val) {
                              FoodLoopFirestoreService.updateSetting('locationPermission', val);
                            },
                          ),
                        ),
                        const SizedBox(height: AppTokens.space10),
                        ActionCard(
                          title: 'Máy ảnh',
                          subtitle: 'Quét hóa đơn và mã QR',
                          trailing: AppSwitch(
                            value: cameraPermission,
                            onChanged: (val) {
                              FoodLoopFirestoreService.updateSetting('cameraPermission', val);
                            },
                          ),
                        ),
                        const SizedBox(height: AppTokens.space10),
                        ActionCard(
                          title: 'Thông báo đẩy',
                          subtitle: 'Nhận nhắc nhở trên điện thoại',
                          trailing: AppSwitch(
                            value: pushNotificationPermission,
                            onChanged: (val) {
                              FoodLoopFirestoreService.updateSetting('pushNotificationPermission', val);
                            },
                          ),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        _buildSectionTitle('Quản lý tài khoản'),
                        const SizedBox(height: AppTokens.space8),
                        ActionCard(
                          title: 'Đổi mật khẩu',
                          subtitle: 'Cập nhật mật khẩu đăng nhập',
                          onTap: () => _showNotice(context, 'Mở màn hình đổi mật khẩu'),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        // Khối tiện ích Nạp dữ liệu mẫu
                        _buildSectionTitle('Dữ liệu & Khởi tạo mẫu'),
                        const SizedBox(height: AppTokens.space8),
                        Container(
                          padding: const EdgeInsets.all(AppTokens.space16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppTokens.radiusLg,
                            border: Border.all(
                              color: AppTokens.border.withValues(alpha: 0.8),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nạp dữ liệu mẫu lên Firebase',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppTokens.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tự động tạo đầy đủ dữ liệu cho tất cả các màn hình: Chợ giải cứu, Tủ lạnh, Bản đồ radar, Thông báo, Thành tựu & Báo cáo.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppTokens.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTokens.brand,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
                                  label: const Text(
                                    'Nạp dữ liệu mẫu ngay (Seed Firebase)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onPressed: () => _handleSeedData(context),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        // Nút Đăng xuất
                        PrimaryButton(
                          text: 'Đăng xuất',
                          isOutlined: true,
                          onPressed: () => _confirmSignOut(context),
                        ),

                        const SizedBox(height: AppTokens.space12),

                        // Nút Xóa tài khoản
                        PrimaryButton(
                          text: 'Xóa tài khoản',
                          backgroundColor: AppTokens.danger,
                          onPressed: () => _confirmDeleteAccount(context),
                        ),

                        const SizedBox(height: AppTokens.space24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTokens.headingMedium.copyWith(
        fontSize: 16.0,
      ),
    );
  }

  Future<void> _handleSeedData(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTokens.brand),
                SizedBox(height: 16),
                Text('Đang nạp toàn bộ dữ liệu mẫu lên Firestore...'),
              ],
            ),
          ),
        ),
      ),
    );

    final result = await FoodLoopSeederService.seedAll();
    if (context.mounted) {
      Navigator.pop(context); // Đóng dialog loading
      if (result['success'] == true) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTokens.surface,
            shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusLg),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppTokens.brand),
                SizedBox(width: 8),
                Text('Nạp dữ liệu thành công!'),
              ],
            ),
            content: Text(
              'Đã tạo thành công ${result['totalDocs']} documents trên Firestore cho tất cả 14 collections của hệ thống FoodLoop.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.brand,
                  shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusMd),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Xong', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi nạp dữ liệu: ${result['error']}'),
            backgroundColor: AppTokens.danger,
          ),
        );
      }
    }
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTokens.brand,
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTokens.surface,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusLg),
        title: const Text('Đăng xuất', style: AppTokens.headingMedium),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
          style: AppTokens.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppTokens.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.brand,
              shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusMd),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showNotice(context, 'Đã đăng xuất thành công.');
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTokens.surface,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusLg),
        title: const Text('Xóa tài khoản', style: AppTokens.headingMedium),
        content: const Text(
          'Hành động này không thể hoàn tác. Toàn bộ dữ liệu của bạn sẽ bị xóa vĩnh viễn.',
          style: AppTokens.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppTokens.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.danger,
              shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusMd),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showNotice(context, 'Yêu cầu xóa tài khoản đã được tiếp nhận.');
            },
            child: const Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
