import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/screen_header.dart';
import '../theme/app_tokens.dart';

/// Màn hình 68: "Liên kết thẻ ngân hàng & Liên kết thẻ thành công" (Module 6 & 7)
class RescueBankCardScreen extends StatefulWidget {
  final bool initialLinked;

  const RescueBankCardScreen({
    super.key,
    this.initialLinked = false,
  });

  @override
  State<RescueBankCardScreen> createState() => _RescueBankCardScreenState();
}

class _RescueBankCardScreenState extends State<RescueBankCardScreen> {
  late bool _isLinked;
  bool _saveCard = true;

  final TextEditingController _cardNumberController =
      TextEditingController(text: '•••• •••• •••• 1234');
  final TextEditingController _cardHolderController =
      TextEditingController(text: 'NGUYEN VAN A');
  final TextEditingController _expiryController =
      TextEditingController(text: '12 / 28');
  final TextEditingController _cvvController =
      TextEditingController(text: '•••');

  @override
  void initState() {
    super.initState();
    _isLinked = widget.initialLinked;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _handleLinkCard() {
    setState(() => _isLinked = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Liên kết thẻ ngân hàng thành công!'),
        backgroundColor: AppTokens.brand,
      ),
    );
  }

  void _handlePayment() {
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
              'Thanh toán thẻ thành công!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Đã thanh toán 45.000 đ bằng thẻ •••• 1234. Vui lòng đến nhận giỏ theo thời gian đã chọn.',
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
              title: _isLinked ? 'Thẻ ngân hàng' : 'Liên kết thẻ ngân hàng',
              subtitle: _isLinked
                  ? null
                  : 'Thêm thẻ để thanh toán giỏ giải cứu của bạn.',
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
                    // Banner thành công (chỉ hiện khi đã liên kết thẻ)
                    if (_isLinked) ...[
                      Container(
                        padding: const EdgeInsets.all(AppTokens.space14),
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
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppTokens.brand,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Liên kết thẻ thành công',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppTokens.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Thẻ đã sẵn sàng cho bước thanh toán.',
                                    style: TextStyle(
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
                      const SizedBox(height: AppTokens.space16),
                    ],

                    // Card số tiền: Giỏ giải cứu của bạn / Tổng thanh toán 45.000 đ
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space14,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Giỏ giải cứu của bạn',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: AppTokens.textSecondary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tổng thanh toán',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '45.000 đ',
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.brand,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTokens.space20),

                    // Trạng thái A: Nhập thông tin thẻ
                    if (!_isLinked) ...[
                      _buildCardFormSection(),
                    ]
                    // Trạng thái B: Hiển thị thẻ đã liên kết
                    else ...[
                      _buildLinkedCardSection(),
                    ],

                    const SizedBox(height: AppTokens.space20),

                    // Ghi chú bảo mật / minh họa
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: AppTokens.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLinked
                                ? 'Thẻ và trạng thái liên kết chỉ để minh họa. Nhấn thanh toán sẽ không phát sinh giao dịch thật.'
                                : 'Chỉ mô phỏng thao tác liên kết thẻ, không kết nối ngân hàng và không trừ tiền.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTokens.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTokens.space24),

                    // Nút chính
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.brand,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            _isLinked ? _handlePayment : _handleLinkCard,
                        child: Text(
                          _isLinked ? 'Thanh toán 45.000 đ' : 'Liên kết thẻ',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTokens.space12),

                    // Nút phụ (TextButton)
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          _isLinked
                              ? 'Chọn phương thức khác'
                              : 'Quay lại thanh toán',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.brand,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTokens.space16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Trạng thái A: Form nhập thông tin thẻ
  Widget _buildCardFormSection() {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTokens.border.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Thông tin thẻ',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.textPrimary,
                ),
              ),
              Text(
                'BẢN MẪU',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Số thẻ
          const Text(
            'Số thẻ',
            style: TextStyle(
              fontSize: 13.5,
              color: AppTokens.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          _buildInputBox(_cardNumberController),

          const SizedBox(height: 14),

          // Tên chủ thẻ
          const Text(
            'Tên chủ thẻ',
            style: TextStyle(
              fontSize: 13.5,
              color: AppTokens.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          _buildInputBox(_cardHolderController),

          const SizedBox(height: 14),

          // Ngày hết hạn & CVV
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ngày hết hạn',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildInputBox(_expiryController),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CVV / CVC',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildInputBox(_cvvController),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Thông tin giả lập. Không nhập dữ liệu thẻ thật.',
            style: TextStyle(
              fontSize: 12.0,
              color: AppTokens.textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          // Checkbox: Lưu thẻ cho lần thanh toán sau
          GestureDetector(
            onTap: () {
              setState(() => _saveCard = !_saveCard);
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _saveCard ? AppTokens.brand : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _saveCard ? AppTokens.brand : AppTokens.border,
                      width: 1.5,
                    ),
                  ),
                  child: _saveCard
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Lưu thẻ cho lần thanh toán sau',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: AppTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Trạng thái B: Thẻ đã liên kết
  Widget _buildLinkedCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thanh toán bằng thẻ',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: AppTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Thẻ mô phỏng chuẩn
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTokens.brand,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(
                              Icons.credit_card_rounded,
                              color: AppTokens.brand,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Thẻ ngân hàng',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'THẺ MẪU',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.brand,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '••••   ••••   ••••   1234',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'NGUYEN VAN A',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // Dải thông tin dưới thẻ
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space10,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: AppTokens.brand,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Đã chọn để thanh toán',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppTokens.textPrimary,
                          ),
                        ),
                        Text(
                          'Chưa thực hiện giao dịch',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: AppTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Link: Liên kết thẻ khác
        InkWell(
          onTap: () {
            setState(() => _isLinked = false);
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTokens.brand,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'Liên kết thẻ khác',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppTokens.brand,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBox(TextEditingController controller) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTokens.border.withValues(alpha: 0.8),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 14.5,
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

