import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/app_form_field.dart';
import '../components/bottom_nav.dart';
import '../components/confirmation_checkbox.dart';
import '../components/media_upload_preview.dart';
import '../components/post_card.dart';
import '../components/primary_button.dart';
import '../components/screen_header.dart';
import '../components/selection_group_card.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình "Kháng nghị và hỗ trợ" (Biến thể Báo cáo bài đăng - module_8_9)
class ReportAppealScreen extends StatefulWidget {
  const ReportAppealScreen({super.key});

  @override
  State<ReportAppealScreen> createState() => _ReportAppealScreenState();
}

class _ReportAppealScreenState extends State<ReportAppealScreen> {
  // Lý do báo cáo được chọn
  String? _selectedReason;
  final TextEditingController _detailController = TextEditingController();
  bool _isConfirmed = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit({
    required String productName,
    required String productSubtitle,
    required String productImage,
  }) async {
    if (!_isConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng xác nhận nội dung báo cáo là đúng sự thật.'),
          backgroundColor: AppTokens.danger,
        ),
      );
      return;
    }

    final detail = _detailController.text.trim();
    if (detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mô tả chi tiết lý do báo cáo.'),
          backgroundColor: AppTokens.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FoodLoopFirestoreService.addReport(
        reason: _selectedReason ?? 'Sai phạm',
        detail: detail,
        productName: productName,
        productSubtitle: productSubtitle,
        productImage: productImage,
      );

      if (!mounted) return;
      _detailController.clear();
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Báo cáo của bạn đã được gửi thành công lên Firebase!'),
          backgroundColor: AppTokens.brand,
        ),
      );

      Navigator.pushReplacementNamed(context, '/my-reports');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi gửi báo cáo: $e'),
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
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Kháng nghị và hỗ trợ',
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FoodLoopFirestoreService.streamReportTargetProduct(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTokens.brand),
                    );
                  }

                  final firestoreData = snapshot.data?.data();
                  final data = firestoreData ?? const <String, dynamic>{
                    'productName': 'Rau muống hữu cơ Đà Lạt',
                    'productSubtitle': '1 bó · Ngăn mát · HSD: 1 ngày',
                    'productImage': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=400&q=80',
                    'reasons': [
                      'Thực phẩm có dấu hiệu hỏng, quá hạn',
                      'Bao bì rách, không đảm bảo vệ sinh',
                      'Thông tin sai lệch với thực tế',
                      'Hành vi không phù hợp',
                      'Lý do khác',
                    ],
                  };

                  final String productName = data['productName'] ?? '';
                  final String productSubtitle = data['productSubtitle'] ?? '';
                  final String productImage = data['productImage'] ?? '';

                  final List<dynamic>? dynamicReasons =
                      data['reasons'] as List<dynamic>?;
                  final List<String> reasons = dynamicReasons != null
                      ? dynamicReasons.map((e) => e.toString()).toList()
                      : <String>[];

                  final currentSelectedReason = (reasons.isNotEmpty &&
                          _selectedReason != null &&
                          reasons.contains(_selectedReason))
                      ? _selectedReason!
                      : (reasons.isNotEmpty ? reasons.first : '');

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PostCard từ Firestore
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
                                      Icons.kitchen_rounded,
                                      color: AppTokens.brand,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppTokens.brandLight,
                                  child: const Icon(
                                    Icons.kitchen_rounded,
                                    color: AppTokens.brand,
                                  ),
                                ),
                        ),

                        const SizedBox(height: AppTokens.space16),

                        // Nhóm chọn lý do từ Firestore
                        if (reasons.isNotEmpty) ...[
                          SelectionGroupCard(
                            title: 'Lý do báo cáo',
                            options: reasons,
                            selectedValue: currentSelectedReason,
                            onChanged: (val) {
                              setState(() => _selectedReason = val);
                            },
                            helperText: 'Chọn một lý do',
                          ),
                          const SizedBox(height: AppTokens.space16),
                        ],

                        // Mô tả chi tiết
                        AppFormField(
                          label: 'Mô tả chi tiết',
                          hintText: 'Quyết định chưa đúng vì',
                          controller: _detailController,
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
                          helperText: 'Tối đa 300 ký tự.',
                        ),

                        const SizedBox(height: AppTokens.space16),

                        // Minh chứng đính kèm
                        MediaUploadPreview(
                          placeholderCount: 3,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Đang mở thư viện tải ảnh minh chứng...'),
                                backgroundColor: AppTokens.brand,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: AppTokens.space16),

                        // Checkbox xác nhận
                        ConfirmationCheckbox(
                          value: _isConfirmed,
                          text: 'Tôi xác nhận nội dung báo cáo là đúng sự thật.',
                          onChanged: (val) {
                            setState(() => _isConfirmed = val ?? false);
                          },
                        ),

                        const SizedBox(height: AppTokens.space24),

                        // Nút gửi kháng nghị
                        PrimaryButton(
                          text: 'Gửi kháng nghị',
                          isLoading: _isSubmitting,
                          onPressed: () => _handleSubmit(
                            productName: productName,
                            productSubtitle: productSubtitle,
                            productImage: productImage,
                          ),
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
