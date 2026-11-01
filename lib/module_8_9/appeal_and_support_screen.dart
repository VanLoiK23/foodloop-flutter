import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/action_card.dart';
import '../components/alert_banner.dart';
import '../components/app_form_field.dart';
import '../components/bottom_nav.dart';
import '../components/confirmation_checkbox.dart';
import '../components/post_card.dart';
import '../components/primary_button.dart';
import '../components/screen_header.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 90: "Kháng nghị và hỗ trợ" (module_8_9)
class AppealAndSupportScreen extends StatefulWidget {
  const AppealAndSupportScreen({super.key});

  @override
  State<AppealAndSupportScreen> createState() => _AppealAndSupportScreenState();
}

class _AppealAndSupportScreenState extends State<AppealAndSupportScreen> {
  // State quản lý form
  String? _selectedRequestType;
  final TextEditingController _explanationController = TextEditingController();
  bool _isConfirmed = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _explanationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(String productName) async {
    if (!_isConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng xác nhận thông tin cung cấp là đúng sự thật.'),
          backgroundColor: AppTokens.danger,
        ),
      );
      return;
    }

    final explanation = _explanationController.text.trim();
    if (explanation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập giải trình của bạn.'),
          backgroundColor: AppTokens.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FoodLoopFirestoreService.submitAppeal(
        productName: productName,
        requestType: _selectedRequestType ?? 'Kháng nghị',
        explanation: explanation,
      );

      if (!mounted) return;
      _explanationController.clear();
      setState(() {
        _isConfirmed = false;
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kháng nghị của bạn đã được gửi thành công lên Firebase!'),
          backgroundColor: AppTokens.brand,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi gửi kháng nghị: $e'),
          backgroundColor: AppTokens.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 4,
        onTap: (index) {},
      ),
      body: SafeArea(
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
              'headerSubtitle': 'Nếu cho rằng quyết định là nhầm lẫn, bạn có thể gửi kháng nghị.',
              'flagTitle': 'Bài đăng bị gắn cờ',
              'flagReason': 'Vi phạm quy chuẩn an toàn thực phẩm. Đã tạm ẩn khỏi cộng đồng.',
              'productName': 'Sữa tươi TH True Milk 1L',
              'productSubtitle': '2 hộp · Ngăn mát · HSD: 2 ngày',
              'productImage': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
              'evidenceHint': 'Chọn ảnh minh chứng từ thư viện (hạn dùng, bao bì)',
              'requestTypes': [
                'Thông tin hạn dùng bị hiểu nhầm',
                'Bao bì vẫn nguyên vẹn',
                'Đã trao đổi rõ với người nhận',
                'Lý do khác',
              ],
            };

            // Dữ liệu đọc thuần túy từ Firestore
            final String headerSubtitle = data['headerSubtitle'] ?? '';
            final String flagTitle = data['flagTitle'] ?? '';
            final String flagReason = data['flagReason'] ?? '';
            final String productName = data['productName'] ?? '';
            final String productSubtitle = data['productSubtitle'] ?? '';
            final String productImage = data['productImage'] ?? '';
            final String evidenceHint = data['evidenceHint'] ?? '';

            final List<dynamic>? dynamicTypes =
                data['requestTypes'] as List<dynamic>?;
            final List<String> requestTypes = dynamicTypes != null
                ? dynamicTypes.map((e) => e.toString()).toList()
                : <String>[];

            final currentSelected = (requestTypes.isNotEmpty &&
                    _selectedRequestType != null &&
                    requestTypes.contains(_selectedRequestType))
                ? _selectedRequestType!
                : (requestTypes.isNotEmpty ? requestTypes.first : '');

            return Column(
              children: [
                // Header nạp subtitle từ Firestore
                ScreenHeader(
                  title: 'Kháng nghị và hỗ trợ',
                  subtitle: headerSubtitle.isNotEmpty ? headerSubtitle : null,
                ),

                // Nội dung cuộn nạp dữ liệu từ Firestore
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. AlertBanner từ Firestore
                        if (flagTitle.isNotEmpty || flagReason.isNotEmpty)
                          AlertBanner(
                            title: flagTitle,
                            message: flagReason,
                            actionText: 'Xem quyết định',
                            onAction: () {
                              Navigator.pushNamed(context, '/decision-review');
                            },
                          ),

                        const SizedBox(height: AppTokens.space16),

                        // 2. PostCard từ Firestore
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

                        const SizedBox(height: AppTokens.space16),

                        // 3. Dropdown loại yêu cầu từ Firestore
                        if (requestTypes.isNotEmpty) ...[
                          AppFormField(
                            label: 'Loại yêu cầu',
                            isDropdown: true,
                            dropdownValue: currentSelected,
                            dropdownItems: requestTypes,
                            onDropdownChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedRequestType = value);
                              }
                            },
                            helperText: 'Chọn đúng loại để được xử lý nhanh hơn.',
                          ),
                          const SizedBox(height: AppTokens.space16),
                        ],

                        // 4. Giải trình
                        AppFormField(
                          label: 'Giải trình của bạn',
                          hintText:
                              'Mô tả lý do bạn cho rằng quyết định chưa đúng...',
                          controller: _explanationController,
                          minLines: 4,
                          maxLines: 5,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(
                              left: AppTokens.space12,
                              top: AppTokens.space12,
                              right: AppTokens.space8,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: Icon(
                                Icons.edit_note_rounded,
                                color: AppTokens.textSecondary,
                                size: 24,
                              ),
                            ),
                          ),
                          helperText: 'Tối đa 500 ký tự.',
                        ),

                        const SizedBox(height: AppTokens.space16),

                        // 5. Minh chứng
                        ActionCard(
                          title: 'Đính kèm minh chứng',
                          subtitle: evidenceHint.isNotEmpty
                              ? evidenceHint
                              : 'Chọn ảnh minh chứng từ thư viện',
                          leadingIcon: Icons.crop_free_rounded,
                          leadingBgColor: AppTokens.brandLight,
                          leadingIconColor: AppTokens.brand,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đang mở thư viện ảnh...'),
                                backgroundColor: AppTokens.brand,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: AppTokens.space16),

                        // 6. Checkbox cam kết
                        ConfirmationCheckbox(
                          value: _isConfirmed,
                          text: 'Tôi xác nhận thông tin cung cấp là đúng sự thật.',
                          onChanged: (val) {
                            setState(() => _isConfirmed = val ?? false);
                          },
                        ),

                        const SizedBox(height: AppTokens.space24),

                        // 7. Nhóm hỗ trợ khác
                        Text(
                          'Cần hỗ trợ khác?',
                          style: AppTokens.headingLarge.copyWith(
                            fontSize: 17.0,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space12),

                        // 8. ActionCard liên hệ hỗ trợ tài khoản
                        ActionCard(
                          title: 'Liên hệ hỗ trợ tài khoản',
                          subtitle: 'Dùng khi tài khoản bị khóa tạm thời',
                          onTap: () {
                            Navigator.pushNamed(context, '/account-support');
                          },
                        ),

                        const SizedBox(height: AppTokens.space24),

                        // 9. Nút PrimaryButton gửi dữ liệu lên Firestore
                        PrimaryButton(
                          text: 'Gửi kháng nghị',
                          isLoading: _isSubmitting,
                          onPressed: () => _handleSubmit(productName),
                        ),

                        const SizedBox(height: AppTokens.space24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
