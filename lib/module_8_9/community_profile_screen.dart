import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

                  final userData = profileSnapshot.data?.data() ?? {};

                  // Trích xuất dữ liệu người dùng từ Firestore
                  final String name = userData['name'] ?? '';
                  final String memberSince = userData['memberSince'] ?? '';
                  final int trustScore = (userData['trustScore'] as num?)?.toInt() ?? 0;
                  final int trustScoreMax = (userData['trustScoreMax'] as num?)?.toInt() ?? 100;
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
                          name: name.isNotEmpty ? name : 'Thành viên FoodLoop',
                          caption: memberSince.isNotEmpty ? memberSince : 'Thành viên cộng đồng',
                          avatar: avatarUrl.isNotEmpty
                              ? Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                    child: Icon(
                                      Icons.eco_rounded,
                                      color: Colors.white,
                                      size: 38,
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
                          onTap: () => _showTrustCriteria(context),
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

                            final docs = historySnapshot.data?.docs ?? [];
                            if (docs.isEmpty) {
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
                              children: docs.map((doc) {
                                final item = doc.data();
                                final String title = item['productName'] ?? item['title'] ?? '';
                                final String subtitle = item['productSubtitle'] ?? item['subtitle'] ?? '';
                                final String imageUrl = item['productImage'] ?? item['imageUrl'] ?? '';
                                final String status = item['status'] ?? 'Đã chia sẻ';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppTokens.space12),
                                  child: PostCard(
                                    title: title,
                                    subtitle: subtitle,
                                    image: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
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
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Đã hiểu',
                  style: TextStyle(
                    color: AppTokens.brand,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

