import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/action_card.dart';
import '../components/alert_banner.dart';
import '../components/bottom_nav.dart';
import '../components/post_card.dart';
import '../components/profile_header_card.dart';
import '../components/screen_header.dart';
import '../components/status_badge.dart';
import '../components/trust_score_card.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 85 (86 trong Figma): "Hồ sơ cộng đồng" (module_8_9)
class CommunityProfileScreen extends StatelessWidget {
  final String? userId;

  static const Map<String, dynamic> _defaultUserProfile = {
    'name': 'Minh Anh',
    'fullName': 'Nguyễn Minh Anh',
    'displayName': 'Minh Anh',
    'memberSince': 'Thành viên từ tháng 10/2026',
    'trustScore': 86,
    'trustScoreMax': 100,
    'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
    'trustInfoTitle': 'Điểm tin cậy được tính thế nào?',
    'trustInfoDescription': 'Dựa trên tỷ lệ bàn giao thành công, đánh giá từ hàng xóm và số báo cáo vi phạm.',
  };

  static const List<Map<String, dynamic>> _defaultSharedHistory = [
    {
      'name': 'Sữa tươi TH True Milk 1L',
      'subtitle': '2 hộp · Ngăn mát · HSD: 04/11/2026',
      'imageUrl': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
      'status': 'Đã chia sẻ',
    },
    {
      'name': 'Rau muống xanh',
      'subtitle': '1 bó · Ngăn mát · HSD: 03/11/2026',
      'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=400&q=80',
      'status': 'Đã chia sẻ',
    },
    {
      'name': 'Cà chua bi Đà Lạt',
      'subtitle': '500 g · Kệ bếp · HSD: 05/11/2026',
      'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=400&q=80',
      'status': 'Đã chia sẻ',
    },
  ];

  const CommunityProfileScreen({
    super.key,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 4, // Tab cá nhân / hồ sơ được active theo thiết kế
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình
            const ScreenHeader(
              title: 'Hồ sơ cộng đồng',
            ),

            // 2. Nội dung chính cuộn dọc lắng nghe Firestore
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FoodLoopFirestoreService.streamCommunityProfile(userId),
                builder: (context, profileSnapshot) {
                  if (profileSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTokens.brand),
                    );
                  }

                  final rawData = profileSnapshot.data?.data();
                  final userData = (rawData != null && rawData.isNotEmpty)
                      ? rawData
                      : _defaultUserProfile;

                  // Trích xuất dữ liệu người dùng từ Firestore (ưu tiên Firebase, fallback mẫu chuẩn)
                  final String name = userData['name'] ??
                      userData['fullName'] ??
                      userData['displayName'] ??
                      'Minh Anh';
                  final String memberSince = userData['memberSince'] ??
                      'Thành viên từ tháng 10/2026';
                  final int trustScore =
                      (userData['trustScore'] as num?)?.toInt() ?? 86;
                  final int trustScoreMax =
                      (userData['trustScoreMax'] as num?)?.toInt() ?? 100;
                  final String avatarUrl = userData['avatarUrl'] ?? '';

                  final String trustInfoTitle = userData['trustInfoTitle'] ??
                      'Điểm tin cậy được tính thế nào?';
                  final String trustInfoDescription =
                      userData['trustInfoDescription'] ??
                          'Dựa trên tỷ lệ bàn giao thành công, đánh giá từ hàng xóm và số báo cáo vi phạm.';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeaderCard(
                          name: name,
                          caption: memberSince.startsWith('Thành viên')
                              ? memberSince
                              : 'Thành viên từ $memberSince',
                          avatar: avatarUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Image.network(
                                    avatarUrl,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                      child: Icon(
                                        Icons.eco_rounded,
                                        color: Colors.white,
                                        size: 38,
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đang mở chi tiết hồ sơ cá nhân...'),
                                backgroundColor: AppTokens.brand,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: AppTokens.space20),

                        TrustScoreCard(
                          title: 'Điểm tin cậy',
                          score: trustScore,
                          maxScore: trustScoreMax,
                          onTap: () => Navigator.pushNamed(context, '/received-thanks'),
                        ),

                        const SizedBox(height: AppTokens.space16),

                        AlertBanner(
                          title: trustInfoTitle,
                          message: trustInfoDescription,
                          icon: Icons.info_outline_rounded,
                          iconColor: AppTokens.info,
                          backgroundColor: AppTokens.infoBg,
                          borderColor: AppTokens.infoBorder,
                          actionText: 'Xem tiêu chí',
                          onAction: () => _showTrustCriteria(context),
                        ),

                        const SizedBox(height: AppTokens.space16),

                        ActionCard(
                          title: 'Lời cảm ơn đã nhận',
                          subtitle: 'Xem phản hồi tích cực từ hàng xóm & huy hiệu cộng đồng',
                          onTap: () => Navigator.pushNamed(context, '/received-thanks'),
                        ),

                        const SizedBox(height: AppTokens.space24),

                        Text(
                          'Lịch sử chia sẻ',
                          style: AppTokens.headingMedium.copyWith(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space12),

                        // Lắng nghe danh sách quà đã chia sẻ từ Firestore
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FoodLoopFirestoreService.streamSharedHistory(),
                          builder: (context, historySnapshot) {
                            if (historySnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppTokens.space16),
                                  child: CircularProgressIndicator(
                                    color: AppTokens.brand,
                                  ),
                                ),
                              );
                            }

                            final rawDocs = historySnapshot.data?.docs ?? [];
                            final List<Map<String, dynamic>> items =
                                rawDocs.isNotEmpty
                                    ? rawDocs.map((d) => d.data()).toList()
                                    : _defaultSharedHistory;

                            if (items.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppTokens.space24),
                                decoration: BoxDecoration(
                                  color: AppTokens.surface,
                                  borderRadius: AppTokens.radiusLg,
                                  border: Border.all(
                                    color: AppTokens.border,
                                    width: 1.0,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Chưa có món quà nào được chia sẻ.',
                                    style: AppTokens.subtitle,
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: items.map((item) {
                                // 1. Trích xuất tên món ăn (hỗ trợ cả 'name', 'productName', 'title')
                                final String title = item['name'] ??
                                    item['productName'] ??
                                    item['title'] ??
                                    'Món quà chia sẻ';

                                // 2. Trích xuất mô tả chi tiết / phụ đề
                                String subtitle = item['productSubtitle'] ??
                                    item['subtitle'] ??
                                    '';
                                if (subtitle.isEmpty) {
                                  final parts = <String>[];
                                  if (item['quantity'] != null) {
                                    final unit = item['unit'] ?? '';
                                    parts.add('${item['quantity']} $unit'.trim());
                                  }
                                  if (item['space'] != null &&
                                      item['space'].toString().isNotEmpty) {
                                    parts.add(item['space'].toString());
                                  } else if (item['category'] != null &&
                                      item['category'].toString().isNotEmpty) {
                                    parts.add(item['category'].toString());
                                  }
                                  if (item['expiry'] != null &&
                                      item['expiry'].toString().isNotEmpty) {
                                    parts.add('HSD: ${item['expiry']}');
                                  } else if (item['badge'] != null &&
                                      item['badge'].toString().isNotEmpty) {
                                    parts.add(item['badge'].toString());
                                  }
                                  subtitle = parts.isNotEmpty
                                      ? parts.join(' · ')
                                      : 'Đã chia sẻ thành công';
                                }

                                final String imageUrl = item['imageUrl'] ??
                                    item['productImage'] ??
                                    '';
                                final String status =
                                    item['status'] ?? 'Đã chia sẻ';

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppTokens.space12,
                                  ),
                                  child: PostCard(
                                    title: title,
                                    subtitle: subtitle,
                                    image: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Container(
                                              color: AppTokens.brandLight,
                                              child: const Icon(
                                                Icons.kitchen_rounded,
                                                color: AppTokens.brand,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: AppTokens.brandLight,
                                            child: const Icon(
                                              Icons.kitchen_rounded,
                                              color: AppTokens.brand,
                                            ),
                                          ),
                                    trailing: StatusBadge(
                                      text: status,
                                      backgroundColor: const Color(0xFFFDE68A),
                                      textColor: const Color(0xFF92400E),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
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

  void _showTrustCriteria(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppTokens.space20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiêu chí tính điểm tin cậy',
              style: AppTokens.headingMedium,
            ),
            const SizedBox(height: AppTokens.space12),
            const Text(
              '• Tỷ lệ bàn giao thực phẩm thành công (+10 điểm/lần)\n'
              '• Đánh giá tích cực từ người nhận (+5 điểm/lượt)\n'
              '• Tần suất hoạt động và chia sẻ đều đặn (+5 điểm/tháng)\n'
              '• Báo cáo sai phạm được xác minh (-20 điểm/lần)',
              style: AppTokens.bodyMedium,
            ),
            const SizedBox(height: AppTokens.space20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      color: AppTokens.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/received-thanks');
                  },
                  child: const Text(
                    'Xem lời cảm ơn ->',
                    style: TextStyle(
                      color: AppTokens.brand,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

