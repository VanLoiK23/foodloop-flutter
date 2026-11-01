import 'package:flutter/material.dart';
import '../app_theme.dart';

class HomeDashboardRedesign extends StatelessWidget {
  const HomeDashboardRedesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E7),
              Colors.white,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: const Icon(
                            Icons.home_outlined,
                            size: 20,
                            color: Color(0xFF2B3935),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Trang chủ',
                          style: TextStyle(
                            color: Color(0xFF2B3935),
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    // Nút thông báo
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/notify',
                            );
                          },
                          padding: const EdgeInsets.all(8),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_none,
                              size: 20,
                              color: Color(0xFF2B3935),
                            ),
                          ),
                        ),

                        // Chấm đỏ thông báo mới
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IgnorePointer(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD32F2F),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. Lời chào
                const Text(
                  'Chào buổi sáng, Hà!',
                  style: TextStyle(
                    color: Color(0xFF2B3935),
                    fontSize: 22,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đây là tình trạng thực phẩm của bạn hôm nay',
                  style: TextStyle(
                    color: Color(0xFF6B7180),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Thẻ thống kê
                Row(
                  children: [
                    Expanded(
                      child: _buildStatisticCard(
                        number: '24',
                        title: 'Thực phẩm',
                        icon: Icons.kitchen,
                        numberColor: const Color(0xFF2D7C31),
                        buttonText: 'Xem tủ',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatisticCard(
                        number: '5',
                        title: 'Sắp hết hạn',
                        icon: Icons.warning_amber_rounded,
                        numberColor: const Color(0xFFD32F2F),
                        buttonText: 'Xem',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // 4. Cần xử lý hôm nay
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Cần xử lý hôm nay',
                        style: TextStyle(
                          color: Color(0xFF2B3935),
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Sắp xếp: Sớm nhất',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: Color(0xFF2D7C31),
                          fontSize: 13,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Item 1
                _buildFoodItem(
                  name: 'Sữa tươi TH True Milk',
                  description: '4 hộp - Ngăn mát',
                  expiry: 'Còn 1 ngày',
                  imageUrl: 'https://placehold.co/56x56',
                ),

                const SizedBox(height: 12),

                // Item 2
                _buildFoodItem(
                  name: 'Sữa chua VinaMilk',
                  description: '1 lốc - Ngăn mát',
                  expiry: 'Còn 2 ngày',
                  imageUrl: 'https://placehold.co/56x56',
                ),

                const SizedBox(height: 12),

                // Nút xem tất cả
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D7C31),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Xem tất cả',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 5. Tiêu thụ tuần này
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tiêu thụ tuần này',
                            style: TextStyle(
                              color: Color(0xFF2B3935),
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '24/10 - 30/10',
                            style: TextStyle(
                              color: Color(0xFF6B7180),
                              fontSize: 13,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Xem báo cáo chi tiết',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: Color(0xFF2D7C31),
                          fontSize: 12,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Biểu đồ tiêu thụ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ĐÃ TIÊU THỤ',
                                  style: TextStyle(
                                    color: Color(0xFF6B7180),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '12 món',
                                  style: TextStyle(
                                    color: Color(0xFF2B3935),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: const Color(0xFFE2E8F0),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LÃNG PHÍ',
                                  style: TextStyle(
                                    color: Color(0xFF6B7180),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '2.4 kg',
                                  style: TextStyle(
                                    color: Color(0xFFD32F2F),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBarItem(
                              'T2',
                              0.4,
                              const Color(0xFFE2E8F0),
                            ),
                            _buildBarItem(
                              'T3',
                              0.6,
                              const Color(0xFFE2E8F0),
                            ),
                            _buildBarItem(
                              'T4',
                              0.3,
                              const Color(0xFFE2E8F0),
                            ),
                            _buildBarItem(
                              'T5',
                              0.8,
                              const Color(0xFF2D7C31),
                            ),
                            _buildBarItem(
                              'T6',
                              0.5,
                              const Color(0xFFE2E8F0),
                            ),
                            _buildBarItem(
                              'T7',
                              1.0,
                              const Color(0xFFF4B942),
                            ),
                            _buildBarItem(
                              'CN',
                              0.6,
                              const Color(0xFFE2E8F0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 6. Thao tác nhanh
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thao tác nhanh',
                      style: TextStyle(
                        color: Color(0xFF2B3935),
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/quick_action',
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: Color(0xFF2B3935),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Các nút thao tác nhanh - dùng Expanded để tránh overflow
                Row(
                  children: const [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.qr_code_scanner,
                        label: 'Quét hóa đơn',
                      ),
                    ),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.add,
                        label: 'Thêm thủ công',
                      ),
                    ),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.search,
                        label: 'Cùng thêm',
                      ),
                    ),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.share,
                        label: 'Chia sẻ',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // 7. Tác động xanh
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFC8E6C9),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(
                            Icons.eco,
                            color: Color(0xFF2D7C31),
                            size: 24,
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Color(0xFF2B3935),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '2.4 kg',
                        style: TextStyle(
                          color: Color(0xFF2B3935),
                          fontSize: 24,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Lượng thực phẩm bạn đã giảm lãng phí trong tháng này.',
                        style: TextStyle(
                          color: Color(0xFF6B7180),
                          fontSize: 13,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Cùng bảo vệ hành tinh',
                        style: TextStyle(
                          color: Color(0xFF2D7C31),
                          fontSize: 13,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),

      // 8. Bottom Navigation
      bottomNavigationBar: const FoodLoopBottomNav(
        currentIndex: 0,
      ),
    );
  }

  // Thẻ thống kê
  static Widget _buildStatisticCard({
    required String number,
    required String title,
    required IconData icon,
    required Color numberColor,
    required String buttonText,
  }) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                number,
                style: TextStyle(
                  color: numberColor,
                  fontSize: 28,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                icon,
                color: numberColor,
                size: 22,
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7180),
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7C31),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Thẻ thực phẩm
  static Widget _buildFoodItem({
    required String name,
    required String description,
    required String expiry,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2B3935),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF6B7180),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration: ShapeDecoration(
                color: const Color(0xFFF4B942),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 12,
                    color: Color(0xFF2B3935),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      expiry,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2B3935),
                        fontSize: 10,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Style chung cho các thẻ
  static ShapeDecoration _cardDecoration() {
    return ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 1,
          color: Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      shadows: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    );
  }

  // Cột biểu đồ
  static Widget _buildBarItem(
    String day,
    double heightFactor,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 80 * heightFactor,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            color: Color(0xFF6B7180),
            fontSize: 12,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Nút thao tác nhanh
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickActionButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2D7C31),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2B3935),
              fontSize: 11,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}