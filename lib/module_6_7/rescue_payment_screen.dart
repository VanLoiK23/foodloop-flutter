import 'dart:async';
import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/screen_header.dart';
import '../theme/app_tokens.dart';

/// Màn hình 68: "Phương thức thanh toán" (Module 6 & 7)
class RescuePaymentScreen extends StatefulWidget {
  final int? amount;

  const RescuePaymentScreen({
    super.key,
    this.amount,
  });

  @override
  State<RescuePaymentScreen> createState() => _RescuePaymentScreenState();
}

class _RescuePaymentScreenState extends State<RescuePaymentScreen> {
  // Phương thức thanh toán được chọn
  String _selectedMethod = 'MoMo'; // 'MoMo', 'QR', 'BankCard'

  // Đếm ngược thời gian giữ chỗ
  int _secondsRemaining = 12 * 60 + 40; // 12:40
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handlePay() {
    if (_selectedMethod == 'QR') {
      Navigator.pushNamed(context, '/rescue-qr-payment');
    } else if (_selectedMethod == 'BankCard') {
      Navigator.pushNamed(context, '/rescue-bank-card');
    } else {
      // MoMo
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(AppTokens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppTokens.brand,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Thanh toán MoMo thành công!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đã thanh toán 45.000 đ cho giỏ giải cứu của bạn. Vui lòng đến nhận đúng khung giờ đã chọn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTokens.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTokens.brand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/rescue-order-history');
                  },
                  child: const Text('Xem lịch sử đơn hàng'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/rescue-market',
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Về Chợ giải cứu',
                    style: TextStyle(
                      color: AppTokens.textSecondary,
                      fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 3, // Tab Túi hàng / Chợ active theo thiết kế Màn 68
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình
            ScreenHeader(
              title: 'Phương thức thanh toán',
              subtitle: 'Chọn cách thanh toán 45.000 đ.',
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
                    // Card 1: Khối chọn phương thức thanh toán
                    Container(
                      padding: const EdgeInsets.all(AppTokens.space16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phương thức',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Option 1: Ví điện tử MoMo
                          _buildRadioOption(
                            id: 'MoMo',
                            title: 'Ví điện tử MoMo',
                            isSelected: _selectedMethod == 'MoMo',
                          ),

                          const SizedBox(height: 12),

                          // Option 2: Chuyển khoản QR
                          _buildRadioOption(
                            id: 'QR',
                            title: 'Chuyển khoản QR',
                            isSelected: _selectedMethod == 'QR',
                          ),

                          const SizedBox(height: 12),

                          // Option 3: Thẻ ngân hàng
                          _buildRadioOption(
                            id: 'BankCard',
                            title: 'Thẻ ngân hàng',
                            isSelected: _selectedMethod == 'BankCard',
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'Bản mẫu giao diện, chưa kết nối cổng thanh toán.',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: AppTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space24),

                    // Card 2: Trạng thái giao dịch
                    const Text(
                      'Trạng thái giao dịch',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space12),

                    // Bước 1: Đã chọn phương thức (Xong)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFC8E6C9),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppTokens.brand,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Đã chọn phương thức',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTokens.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Xong',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space10),

                    // Bước 2: Đang chờ thanh toán (Hiện tại)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTokens.textSecondary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Đang chờ thanh toán',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTokens.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Hiện tại',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space10),

                    // Bước 3: Hoàn tất (Chưa)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTokens.border.withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTokens.textSecondary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Hoàn tất',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTokens.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Chưa',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space14),

                    // Hộp thông tin: Đang chờ xác nhận từ cổng thanh toán
                    Container(
                      padding: const EdgeInsets.all(AppTokens.space14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFDBEAFE),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF2563EB),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Đang chờ xác nhận từ cổng thanh toán',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Giữ chỗ còn ${_formatTimer(_secondsRemaining)}.',
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: Color(0xFF1E40AF),
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

            // 3. Khối 2 nút thao tác chân trang
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
              child: Row(
                children: [
                  // Nút "Hủy"
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: AppTokens.brand,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.brand,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppTokens.space12),

                  // Nút "Thanh toán 45.00 đ"
                  Expanded(
                    flex: 6,
                    child: SizedBox(
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
                        onPressed: _handlePay,
                        child: const Text(
                          'Thanh toán 45.00 đ',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

  Widget _buildRadioOption({
    required String id,
    required String title,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMethod = id);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTokens.brand : AppTokens.textSecondary,
                width: 2.0,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTokens.brand,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.0,
              color: AppTokens.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

