import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/action_card.dart';
import '../components/alert_banner.dart';
import '../components/bottom_nav.dart';
import '../components/post_card.dart';
import '../components/process_timeline_card.dart';
import '../components/screen_header.dart';
import '../components/status_badge.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 84: "Báo cáo của tôi"
class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

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
            // 1. Header màn hình
            const ScreenHeader(
              title: 'Báo cáo của tôi',
            ),

            // 2. Nội dung cuộn dữ liệu Firestore
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FoodLoopFirestoreService.streamActiveReports(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppTokens.space24),
                              child: CircularProgressIndicator(color: AppTokens.brand),
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];
                        // Lấy báo cáo đang xử lý từ Firestore hoặc mẫu dữ liệu chuẩn
                        final report = docs.isNotEmpty
                            ? docs.first.data()
                            : const <String, dynamic>{
                                'code': 'BC-2026-0891',
                                'productName': 'Sữa tươi TH True Milk 1L',
                                'productSubtitle': '2 hộp · Ngăn mát · HSD: 2 ngày',
                                'status': 'Đang xử lý',
                                'postStatus': 'Đang chờ duyệt',
                                'productImage':
                                    'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
                                'steps': [
                                  {
                                    'title': 'Đã tiếp nhận báo cáo',
                                    'subtitle': '27/10/2026 · Hệ thống tự động',
                                    'status': 'completed'
                                  },
                                  {
                                    'title': 'Kiểm duyệt viên đang xem xét',
                                    'subtitle': 'Đang đối soát thông tin sản phẩm',
                                    'status': 'inProgress'
                                  },
                                  {
                                    'title': 'Quyết định cuối cùng',
                                    'subtitle': 'Dự kiến trong 24 giờ tới',
                                    'status': 'pending'
                                  },
                                ],
                                'reviewerFeedback': {
                                  'title': 'Phản hồi từ kiểm duyệt viên',
                                  'message':
                                      'Đã ghi nhận yêu cầu và đang đối soát hạn dùng thực tế.',
                                },
                              };

                        final String code = report['code'] ?? '';
                        final String productName = report['productName'] ?? '';
                        final String productSubtitle = report['productSubtitle'] ?? '';
                        final String status = report['status'] ?? 'Đang xử lý';
                        final String postStatus = report['postStatus'] ?? 'Đang chờ duyệt';

                        // Trích xuất các bước timeline từ Firestore
                        final List<dynamic> rawSteps = report['steps'] ?? [];
                        final List<TimelineStepData> steps = rawSteps.map((s) {
                          final stepMap = s as Map<String, dynamic>;
                          StepStateStatus stepState = StepStateStatus.pending;
                          if (stepMap['status'] == 'completed') {
                            stepState = StepStateStatus.completed;
                          } else if (stepMap['status'] == 'inProgress') {
                            stepState = StepStateStatus.inProgress;
                          }
                          return TimelineStepData(
                            title: stepMap['title'] ?? '',
                            subtitle: stepMap['subtitle'] ?? '',
                            status: stepState,
                          );
                        }).toList();

                        // Trích xuất phản hồi kiểm duyệt viên
                        final feedback = report['reviewerFeedback'] as Map<String, dynamic>?;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Báo cáo $code',
                              style: AppTokens.headingMedium.copyWith(
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: AppTokens.space12),

                            // PostCard từ Firestore
                            PostCard(
                              title: productName,
                              subtitle: productSubtitle,
                              image: (report['productImage'] != null && (report['productImage'] as String).isNotEmpty)
                                  ? Image.network(
                                      report['productImage'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: AppTokens.brandLight,
                                        child: const Icon(Icons.kitchen_rounded, color: AppTokens.brand),
                                      ),
                                    )
                                  : Container(
                                      color: AppTokens.brandLight,
                                      child: const Icon(Icons.kitchen_rounded, color: AppTokens.brand),
                                    ),
                              trailing: StatusBadge(
                                text: status,
                                backgroundColor: const Color(0xFFFDE68A),
                                textColor: const Color(0xFF92400E),
                              ),
                            ),

                            const SizedBox(height: AppTokens.space16),

                            // Hàng trạng thái
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Trạng thái bài đăng',
                                  style: AppTokens.subtitle,
                                ),
                                StatusBadge(
                                  text: postStatus,
                                  icon: Icons.schedule_rounded,
                                  backgroundColor: AppTokens.warningBg,
                                  textColor: AppTokens.warningText,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppTokens.space16),

                            // Tiến trình xử lý từ Firestore
                            if (steps.isNotEmpty)
                              ProcessTimelineCard(steps: steps),

                            const SizedBox(height: AppTokens.space16),

                            // Khối phản hồi từ Firestore
                            if (feedback != null)
                              AlertBanner(
                                title: feedback['title'] ?? 'Phản hồi từ kiểm duyệt viên',
                                message: feedback['message'] ?? '',
                                actionText: 'Xem chi tiết',
                                icon: Icons.info_outline_rounded,
                                backgroundColor: AppTokens.infoBg,
                                borderColor: AppTokens.infoBorder,
                                iconColor: AppTokens.info,
                                onAction: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đang mở chi tiết phản hồi...'),
                                      backgroundColor: AppTokens.brand,
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: AppTokens.space24),

                    Text(
                      'Báo cáo đã xử lý',
                      style: AppTokens.headingMedium.copyWith(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space12),

                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FoodLoopFirestoreService.streamResolvedReports(),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppTokens.space8),
                            child: Text('Chưa có báo cáo nào đã xử lý.', style: AppTokens.subtitle),
                          );
                        }

                        return Column(
                          children: docs.map((doc) {
                            final data = doc.data();
                            final code = data['code'] ?? '';
                            final name = data['productName'] ?? '';
                            final sub = data['productSubtitle'] ?? '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppTokens.space12),
                              child: ActionCard(
                                title: '$code • $name',
                                subtitle: sub,
                                onTap: () {
                                  Navigator.pushNamed(context, '/decision-review');
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: AppTokens.space16),

                    // Banner kháng nghị
                    AlertBanner(
                      title: 'Không đồng ý với kết quả?',
                      message: 'Bạn có thể gửi kháng nghị trong 7 ngày.',
                      actionText: 'Gửi kháng nghị',
                      icon: Icons.warning_amber_rounded,
                      backgroundColor: AppTokens.warningBg,
                      borderColor: AppTokens.warningBorder,
                      iconColor: AppTokens.warning,
                      onAction: () {
                        Navigator.pushNamed(context, '/appeal-and-support');
                      },
                    ),

                    const SizedBox(height: AppTokens.space24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
