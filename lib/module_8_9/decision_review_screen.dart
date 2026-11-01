import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/alert_banner.dart';
import '../components/bottom_nav.dart';
import '../components/post_card.dart';
import '../components/primary_button.dart';
import '../components/screen_header.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình "Xem quyết định" (Frame Figma 368:5196 - module_8_9)
class DecisionReviewScreen extends StatelessWidget {
  const DecisionReviewScreen({super.key});

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
            const ScreenHeader(
              title: 'Xem quyết định',
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FoodLoopFirestoreService.streamFlaggedNotice(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTokens.brand),
                    );
                  }

                  final firestoreData = snapshot.data?.data();
                  final data = firestoreData ?? const <String, dynamic>{
                    'flagTitle': 'Bài đăng bị gắn cờ',
                    'flagReason': 'Vi phạm quy chuẩn an toàn thực phẩm. Đã tạm ẩn khỏi cộng đồng.',
                    'productName': 'Sữa tươi TH True Milk 1L',
                    'productSubtitle': '2 hộp · Ngăn mát · HSD: 2 ngày',
                    'productImage': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
                    'decisionReviewTitle': 'Bạn muốn xem xét lại?',
                    'decisionReviewDescription': 'Nếu bạn cung cấp thêm thông tin minh chứng cho thấy sản phẩm vẫn đảm bảo an toàn, ban quản trị sẽ xem xét khôi phục bài đăng.',
                  };

                  final String flagTitle = data['flagTitle'] ?? '';
                  final String flagReason = data['flagReason'] ?? '';
                  final String productName = data['productName'] ?? '';
                  final String productSubtitle = data['productSubtitle'] ?? '';
                  final String productImage = data['productImage'] ?? '';
                  final String decisionReviewTitle =
                      data['decisionReviewTitle'] ?? 'Bạn muốn xem xét lại?';
                  final String decisionReviewDescription =
                      data['decisionReviewDescription'] ?? '';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cảnh báo bài đăng bị gỡ (AlertBanner từ Firestore)
                        if (flagTitle.isNotEmpty || flagReason.isNotEmpty)
                          AlertBanner(
                            title: flagTitle,
                            message: flagReason,
                          ),

                        const SizedBox(height: AppTokens.space24),

                        // Tiêu đề phần bài đăng liên quan
                        Text(
                          'Bài đăng liên quan',
                          style: AppTokens.headingMedium.copyWith(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space12),

                        // Thẻ bài đăng PostCard từ Firestore
                        PostCard(
                          title: productName,
                          subtitle: productSubtitle,
                          image: productImage.isNotEmpty
                              ? Image.network(
                                  productImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: AppTokens.brandLight,
                                    child: const Icon(
                                      Icons.eco_rounded,
                                      color: AppTokens.brand,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppTokens.brandLight,
                                  child: const Icon(
                                    Icons.eco_rounded,
                                    color: AppTokens.brand,
                                  ),
                                ),
                        ),

                        const SizedBox(height: AppTokens.space24),

                        // Khối câu hỏi và hướng dẫn từ Firestore
                        Text(
                          decisionReviewTitle,
                          style: AppTokens.headingMedium.copyWith(
                            fontSize: 16.0,
                          ),
                        ),
                        if (decisionReviewDescription.isNotEmpty) ...[
                          const SizedBox(height: AppTokens.space8),
                          Text(
                            decisionReviewDescription,
                            style: AppTokens.subtitle,
                          ),
                        ],

                        const SizedBox(height: AppTokens.space32),

                        // Nút bấm "Kháng nghị quyết định"
                        PrimaryButton(
                          text: 'Kháng nghị quyết định',
                          onPressed: () {
                            Navigator.pushNamed(context, '/appeal-and-support');
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
}
