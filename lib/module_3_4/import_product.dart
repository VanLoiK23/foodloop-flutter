import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_theme.dart';
import 'virtual_refrigerator_bottom_sheet.dart';

class ImportProduct extends StatelessWidget {
  const ImportProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushNamed(context, '/virtual-fridge');
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: AppColors.title),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Thêm thực phẩm vào kho',
                        style: TextStyle(
                          color: AppColors.title,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chọn cách bạn muốn thêm thực phẩm',
                  style: TextStyle(color: AppColors.gray, fontSize: 15),
                ),
                const SizedBox(height: 24),
                _optionCard(
                  context,
                  FontAwesomeIcons.receipt,
                  'Quét hóa đơn siêu thị',
                  'Chụp ảnh để bóc tách thông tin',
                  'Nhanh nhất',
                  () => showAppSheet(context, const VirtualRefrigeratorBottomSheet()),
                ),
                const SizedBox(height: 16),
                _optionCard(
                  context,
                  FontAwesomeIcons.qrcode,
                  'Quét mã QR',
                  'Tra cứu nhanh hạn sử dụng',
                  null,
                  () => showAppSheet(context, const VirtualRefrigeratorBottomSheet()),
                ),
                const SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/add-product'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, color: AppColors.brand, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Hoặc nhập thủ công',
                          style: TextStyle(
                            color: AppColors.brand,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 2),
    );
  }

  Widget _optionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String? badgeText,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0D2B3A35), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.greenBg,
              child: FaIcon(icon, color: AppColors.brand, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.title,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (badgeText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: AppColors.title,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.gray, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
