import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/alert_banner.dart';
import '../components/bottom_nav.dart';
import '../components/honor_poster_card.dart';
import '../components/primary_button.dart';
import '../components/screen_header.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 98: "Thẻ vinh danh" (module_8_9)

class HonorCardScreen extends StatefulWidget {
  const HonorCardScreen({super.key});

  @override
  State<HonorCardScreen> createState() => _HonorCardScreenState();
}

class _HonorCardScreenState extends State<HonorCardScreen> {
  // Chỉ số kiểu màu thẻ được chọn (0: Xanh mint, 1: Trắng, 2: Kem)
  int _selectedThemeIndex = 0;

  final List<Color> _cardThemeBackgrounds = const [
    Color(0xFFE8F5E9), // Xanh mint dịu mát (mặc định)
    Color(0xFFFFFFFF), // Trắng tinh tế
    Color(0xFFF7F4E8), // Vàng kem ấm áp
  ];

  final List<Color> _pickerDotColors = const [
    Color(0xFF2E7D32), // Xanh lá thương hiệu
    Color(0xFFFFFFFF), // Trắng
    Color(0xFFF7F4E8), // Kem
  ];

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
            // 1. Header màn hình kèm nút quay lại
            const ScreenHeader(
              title: 'Thẻ vinh danh',
              subtitle: 'Chia sẻ tác động xanh của bạn.',
            ),

            // 2. Nội dung cuộn lắng nghe Firestore
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FoodLoopFirestoreService.streamHonorCardData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTokens.brand),
                    );
                  }

                  final data = snapshot.data?.data() ?? {};

                  // Trích xuất dữ liệu từ Firestore
                  final String userName = data['userName'] ?? 'Minh Anh';
                  final String monthYear =
                      data['monthYear'] ?? 'Tháng 10/2026';
                  final String preventedWaste =
                      data['preventedWaste']?.toString() ?? '24,6';
                  final String reducedCo2 =
                      data['reducedCo2']?.toString() ?? '61,5';
                  final String savedMoney =
                      data['savedMoney']?.toString() ?? '428.000';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HonorPosterCard(
                          userName: userName,
                          monthYear: monthYear,
                          preventedWaste: preventedWaste,
                          reducedCo2: reducedCo2,
                          savedMoney: savedMoney,
                          backgroundColor:
                              _cardThemeBackgrounds[_selectedThemeIndex],
                        ),

                        const SizedBox(height: AppTokens.space24),

                        Text(
                          'Chọn kiểu thẻ',
                          style: AppTokens.headingMedium.copyWith(
                            fontSize: 16.0,
                            color: AppTokens.title,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space12),

                        Row(
                          children: List.generate(_pickerDotColors.length, (index) {
                            final isSelected = _selectedThemeIndex == index;
                            final dotColor = _pickerDotColors[index];

                            return Padding(
                              padding: const EdgeInsets.only(right: AppTokens.space16),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedThemeIndex = index);
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTokens.brand
                                          : const Color(0xFFE2E8F0),
                                      width: isSelected ? 2.5 : 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(3.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: dotColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFCBD5E1),
                                        width: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        const AlertBanner(
                          icon: Icons.info_outline_rounded,
                          iconColor: AppTokens.info,
                          backgroundColor: AppTokens.infoBg,
                          borderColor: AppTokens.infoBorder,
                          title: 'Thẻ không chứa thông tin cá nhân',
                          message:
                              'Chỉ có số liệu tổng hợp, không hiển thị vị trí hoặc địa chỉ của bạn.',
                        ),

                        const SizedBox(height: AppTokens.space20),

                        PrimaryButton(
                          text: 'Lưu ảnh',
                          isOutlined: true,
                          borderColor: AppTokens.brand,
                          textColor: AppTokens.brand,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã lưu ảnh thẻ vinh danh vào thư viện!'),
                                backgroundColor: AppTokens.brand,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: AppTokens.space12),

                        PrimaryButton(
                          text: 'Chia sẻ thẻ',
                          backgroundColor: AppTokens.brand,
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Đang mở hộp thoại chia sẻ tác động xanh...'),
                                backgroundColor: AppTokens.brand,
                              ),
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
}

