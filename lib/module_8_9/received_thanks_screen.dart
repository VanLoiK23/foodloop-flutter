import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/action_card.dart';
import '../components/bottom_nav.dart';
import '../components/metric_stat_card.dart';
import '../components/received_sticker_pill.dart';
import '../components/screen_header.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 89: "Lời cảm ơn đã nhận" (module_8_9)
class ReceivedThanksScreen extends StatelessWidget {
  const ReceivedThanksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 4,
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình
            const ScreenHeader(
              title: 'Lời cảm ơn đã nhận',
              subtitle: 'Danh tiếng của bạn trong cộng đồng.',
            ),

            // 2. Nội dung cuộn lắng nghe dữ liệu từ Firestore
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FoodLoopFirestoreService.streamReceivedThanksData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTokens.brand),
                    );
                  }

                  final data = snapshot.data?.data() ?? {};

                  // 1. Chỉ số tóm tắt
                  final String thanksCount =
                      data['thanksCount']?.toString() ?? '12';
                  final String reputationScore =
                      data['reputationScore']?.toString() ?? '86';

                  // 2. Danh sách nhãn dán đã nhận
                  final rawStickers = data['stickers'] as List<dynamic>?;
                  final List<String> stickers = rawStickers != null
                      ? rawStickers.map((e) => e.toString()).toList()
                      : const [
                          'Cảm ơn bạn!',
                          'Thật tử tế!',
                          'Hàng xóm tuyệt vời',
                        ];

                  // 3. Danh sách lời cảm ơn gần đây
                  final rawRecentThanks =
                      data['recentThanks'] as List<dynamic>?;
                  final List<Map<String, dynamic>> recentThanks =
                      rawRecentThanks != null
                          ? rawRecentThanks
                              .map((e) => e as Map<String, dynamic>)
                              .toList()
                          : const [
                              {
                                'title': 'Anh Hùng · Cảm ơn bạn!',
                                'subtitle':
                                    '2 hộp sữa tươi TH True Milk · 27/10/2026',
                              },
                              {
                                'title': 'Bạn Thu · Thật tử tế!',
                                'subtitle': '1 bó rau muống · 24/10/2026',
                              },
                              {
                                'title': 'Cô Mai · Hàng xóm tuyệt vời',
                                'subtitle': '3 quả cà chua · 20/10/2026',
                              },
                              {
                                'title': 'Anh Hùng · Nhờ bạn mà không lãng phí',
                                'subtitle': '1 ổ bánh mì · 15/10/2026',
                              },
                            ];

                  // 4. Lịch sử điểm danh tiếng
                  final rawHistory =
                      data['reputationHistory'] as List<dynamic>?;
                  final List<Map<String, dynamic>> reputationHistory =
                      rawHistory != null
                          ? rawHistory
                              .map((e) => e as Map<String, dynamic>)
                              .toList()
                          : const [
                              {
                                'title': '+2 điểm · Giao dịch hoàn tất',
                                'subtitle': '27/10/2026',
                              },
                              {
                                'title': '+1 điểm · Nhận lời cảm ơn',
                                'subtitle': '24/10/2026',
                              },
                              {
                                'title': '+2 điểm · Giao dịch hoàn tất',
                                'subtitle': '20/10/2026',
                              },
                            ];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MetricStatCard(
                                title: 'Lời cảm ơn',
                                value: thanksCount,
                                unit: 'lời',
                                subtitle: 'Từ khi tham gia',
                                onTap: () => _showNotice(
                                  context,
                                  'Tổng số lời cảm ơn: $thanksCount lời',
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTokens.space12),
                            Expanded(
                              child: MetricStatCard(
                                title: 'Điểm danh tiếng',
                                value: reputationScore,
                                unit: 'điểm',
                                subtitle: 'Cộng đồng',
                                onTap: () => _showNotice(
                                  context,
                                  'Điểm uy tín danh tiếng: $reputationScore điểm',
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTokens.space24),

                        Text(
                          'Nhãn dán đã nhận',
                          style: AppTokens.headingMedium.copyWith(
                            fontSize: 16.0,
                            color: AppTokens.title,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space12),

                        ...stickers.map((label) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppTokens.space10),
                            child: ReceivedStickerPill(
                              label: label,
                              onTap: () => _showNotice(
                                context,
                                'Nhãn dán: "$label"',
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: AppTokens.space24),

                        Text(
                          'Lời cảm ơn gần đây',
                          style: AppTokens.headingMedium.copyWith(
                            fontSize: 16.0,
                            color: AppTokens.title,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space12),

                        ...recentThanks.map((item) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppTokens.space12),
                            child: ActionCard(
                              title: item['title'] ?? '',
                              subtitle: item['subtitle'] ?? '',
                              onTap: () => _showNotice(
                                context,
                                'Chi tiết: ${item['title']}',
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: AppTokens.space24),

                        Text(
                          'Lịch sử danh tiếng',
                          style: AppTokens.headingMedium.copyWith(
                            fontSize: 16.0,
                            color: AppTokens.title,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space12),

                        ...reputationHistory.map((hist) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppTokens.space12),
                            child: ActionCard(
                              title: hist['title'] ?? '',
                              subtitle: hist['subtitle'] ?? '',
                              onTap: () => _showNotice(
                                context,
                                'Lịch sử: ${hist['title']}',
                              ),
                            ),
                          );
                        }),

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

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTokens.brand,
      ),
    );
  }
}

