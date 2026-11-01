import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/screen_header.dart';
import '../theme/app_tokens.dart';

/// Màn hình 64 (Phụ): "Thời điểm đến nhận" (Module 6 & 7)
class RescuePickupTimeScreen extends StatefulWidget {
  final String? storeName;
  final String? productName;
  final int? quantity;

  const RescuePickupTimeScreen({
    super.key,
    this.storeName,
    this.productName,
    this.quantity,
  });

  @override
  State<RescuePickupTimeScreen> createState() => _RescuePickupTimeScreenState();
}

class _RescuePickupTimeScreenState extends State<RescuePickupTimeScreen> {
  String _selectedDate = 'Hôm nay, 31/10';
  String _selectedTimeSlot = '18:30 – 19:00';

  final List<String> _dates = const [
    'Hôm nay, 31/10',
    'Ngày mai, 01/11',
  ];

  final List<String> _timeSlots = const [
    '18:00 – 18:30',
    '18:30 – 19:00',
    '19:00 – 19:30',
    '19:30 – 20:00',
  ];

  void _confirmSelection() {
    final String combinedResult = '$_selectedDate · $_selectedTimeSlot';
    Navigator.pop(context, combinedResult);
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String store =
        routeArgs?['store'] ?? widget.storeName ?? 'Cửa hàng Rau Sạch Xanh';
    final String product =
        routeArgs?['product'] ?? widget.productName ?? 'Giỏ rau củ cuối ngày';
    final int qty = routeArgs?['quantity'] ?? widget.quantity ?? 1;

    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 3, // Tab Túi hàng / Chợ active theo thiết kế Màn 64
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình
            ScreenHeader(
              title: 'Thời điểm đến nhận',
              subtitle:
                  'Chọn ngày và khung giờ thuận tiện để đến nhận giỏ của bạn nhé.',
            ),

            // 2. Nội dung cuộn
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card thông tin cửa hàng
                    Container(
                      padding: const EdgeInsets.all(AppTokens.space16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.storefront_rounded,
                                color: AppTokens.brand,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppTokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  '350 m · Mở đến 20:00',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: AppTokens.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$product · $qty giỏ',
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: AppTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space20),

                    // Mục: Ngày đến nhận
                    const Text(
                      'Ngày đến nhận',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space10),

                    Row(
                      children: _dates.map((date) {
                        final isSelected = date == _selectedDate;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedDate = date);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTokens.brand
                                      : AppTokens.border.withValues(alpha: 0.8),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: AppTokens.brand,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppTokens.brand
                                          : AppTokens.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppTokens.space24),

                    // Mục: Khung giờ đến nhận
                    const Text(
                      'Khung giờ đến nhận',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cửa hàng nhận khách từ 18:00 đến 20:00.',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: AppTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space12),

                    // Lưới 2x2 các khung giờ
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.8,
                      children: _timeSlots.map((slot) {
                        final isSelected = slot == _selectedTimeSlot;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedTimeSlot = slot);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE8F5E9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? AppTokens.brand
                                    : AppTokens.border.withValues(alpha: 0.8),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isSelected) ...[
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: AppTokens.brand,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  slot,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppTokens.brand
                                        : AppTokens.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppTokens.space20),

                    // Card cảnh báo: Đến nhận đúng khung giờ nhé
                    Container(
                      padding: const EdgeInsets.all(AppTokens.space16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFD97706),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Đến nhận đúng khung giờ nhé',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Cửa hàng sẽ chuẩn bị giỏ theo giờ bạn chọn. Vui lòng đến trước 20:00 để nhận giỏ.',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Color(0xFFB45309),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space24),
                  ],
                ),
              ),
            ),

            // 3. Khối dính chân trang
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space16,
                vertical: AppTokens.space12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppTokens.border,
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppTokens.brand,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thời điểm đến nhận',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: AppTokens.textSecondary,
                              ),
                            ),
                            Text(
                              '$_selectedDate · $_selectedTimeSlot',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTokens.space10),

                  // Nút "Xác nhận Đặt mua" / "Xác nhận thời điểm"
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.brand,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _confirmSelection,
                      child: const Text(
                        'Xác nhận Đặt mua',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

