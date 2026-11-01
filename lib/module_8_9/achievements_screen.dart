import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/achievement_badge_card.dart';
import '../components/bottom_nav.dart';
import '../components/screen_header.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 95: "Huy hiệu thành tựu" (module_8_9)
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 4, // Tab cá nhân được active theo Figma
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình với nút quay lại tròn trắng
            const ScreenHeader(
              title: 'Huy hiệu thành tựu',
            ),

            // 2. Nội dung chính cuộn dọc lắng nghe Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FoodLoopFirestoreService.streamAchievements(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTokens.brand),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  // Nếu chưa có dữ liệu trên Firestore, hiển thị danh sách mẫu ban đầu theo thiết kế
                  final List<Map<String, dynamic>> badges = docs.isNotEmpty
                      ? docs.map((d) => d.data()).toList()
                      : [
                          {
                            'title': 'Tác động mạnh mẽ',
                            'description': 'Gây ảnh hưởng đến môi trường nào!',
                            'isUnlocked': true,
                            'progress': 1.0,
                            'progressText': '1/1 lần',
                          },
                          {
                            'title': 'Người bảo quản xanh',
                            'description': 'Cứu 10 kg thực phẩm khỏi lãng phí',
                            'isUnlocked': true,
                            'progress': 1.0,
                            'progressText': '10/10 kg',
                          },
                          {
                            'title': 'Hàng xóm tử tế',
                            'description': 'Chia sẻ thành công 5 lần',
                            'isUnlocked': false,
                            'progress': 3 / 5,
                            'progressText': '3/5 lần',
                          },
                          {
                            'title': 'Tiết kiệm 500.000 đ',
                            'description': 'Tiết kiệm tổng cộng 500.000 đ',
                            'isUnlocked': false,
                            'progress': 428000 / 500000,
                            'progressText': '428.000/500.000 đ',
                          },
                          {
                            'title': 'Cứu người là nghĩa cao đẹp',
                            'description': 'Số giỏ hàng đã giải cứu',
                            'isUnlocked': false,
                            'progress': 5 / 7,
                            'progressText': '5/7 ngày',
                          },
                          {
                            'title': 'Giảm 100 kg CO₂e',
                            'description': 'Góp phần giảm 100 kg CO₂e',
                            'isUnlocked': false,
                            'progress': 61.5 / 100,
                            'progressText': '61,5/100 kg',
                          },
                        ];

                  final unlockedBadges =
                      badges.where((b) => b['isUnlocked'] == true).toList();
                  final inProgressBadges =
                      badges.where((b) => b['isUnlocked'] != true).toList();
                  final totalCount = badges.length;
                  final unlockedCount = unlockedBadges.length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dòng tóm tắt tiến độ mở khóa huy hiệu
                        Text(
                          'Đã mở khóa $unlockedCount trong $totalCount huy hiệu.',
                          style: AppTokens.subtitle.copyWith(
                            fontSize: 13.5,
                            color: AppTokens.textSecondary,
                          ),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        if (unlockedBadges.isNotEmpty) ...[
                          Text(
                            'Đã mở khóa',
                            style: AppTokens.headingMedium.copyWith(
                              fontSize: 16.0,
                              color: AppTokens.title,
                            ),
                          ),
                          const SizedBox(height: AppTokens.space12),
                          ...unlockedBadges.map((badge) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppTokens.space12,
                              ),
                              child: AchievementBadgeCard(
                                title: badge['title'] ?? '',
                                description: badge['description'] ?? '',
                                isUnlocked: true,
                                progress: (badge['progress'] as num?)?.toDouble() ?? 1.0,
                                progressText: badge['progressText'] ?? '',
                                onTap: () => _showBadgeDetail(context, badge),
                              ),
                            );
                          }),
                          const SizedBox(height: AppTokens.space16),
                        ],

                        if (inProgressBadges.isNotEmpty) ...[
                          Text(
                            'Đang thực hiện',
                            style: AppTokens.headingMedium.copyWith(
                              fontSize: 16.0,
                              color: AppTokens.title,
                            ),
                          ),
                          const SizedBox(height: AppTokens.space12),
                          ...inProgressBadges.map((badge) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppTokens.space12,
                              ),
                              child: AchievementBadgeCard(
                                title: badge['title'] ?? '',
                                description: badge['description'] ?? '',
                                isUnlocked: false,
                                progress: (badge['progress'] as num?)?.toDouble() ?? 0.0,
                                progressText: badge['progressText'] ?? '',
                                onTap: () => _showBadgeDetail(context, badge),
                              ),
                            );
                          }),
                        ],

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

  void _showBadgeDetail(BuildContext context, Map<String, dynamic> badge) {
    final title = badge['title'] ?? '';
    final description = badge['description'] ?? '';
    final isUnlocked = badge['isUnlocked'] == true;
    final progressText = badge['progressText'] ?? '';

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
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isUnlocked
                          ? Icons.emoji_events_outlined
                          : Icons.lock_outline_rounded,
                      color: isUnlocked
                          ? AppTokens.brand
                          : AppTokens.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTokens.headingMedium.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUnlocked ? 'Đã đạt được' : 'Tiến trình: $progressText',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? AppTokens.brand
                              : AppTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space16),
            Text(
              description,
              style: AppTokens.bodyMedium.copyWith(color: AppTokens.body),
            ),
            const SizedBox(height: AppTokens.space24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Đóng',
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

