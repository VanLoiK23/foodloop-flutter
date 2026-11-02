import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/alert_banner.dart';
import '../components/bottom_nav.dart';
import '../components/confirmation_checkbox.dart';
import '../components/post_card.dart';
import '../components/primary_button.dart';
import '../components/screen_header.dart';
import '../components/status_badge.dart';
import '../module_5_map/services/food_service.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

/// Màn hình 81: "Kiểm tra an toàn thực phẩm" (module_8_9)
class FoodSafetyCheckScreen extends StatefulWidget {
  final String? productId;

  const FoodSafetyCheckScreen({
    super.key,
    this.productId,
  });

  @override
  State<FoodSafetyCheckScreen> createState() => _FoodSafetyCheckScreenState();
}

class _FoodSafetyCheckScreenState extends State<FoodSafetyCheckScreen> {
  // Tập hợp các mục checklist đã được tích chọn
  final Set<int> _checkedIndices = {};
  bool _isSubmitting = false;

  void _toggleIndex(int index) {
    setState(() {
      if (_checkedIndices.contains(index)) {
        _checkedIndices.remove(index);
      } else {
        _checkedIndices.add(index);
      }
    });
  }

  Future<void> _handleContinue({
    required String productId,
    required List<String> checklist,
    required String productName,
    required String productSubtitle,
    required String expiryText,
  }) async {
    setState(() => _isSubmitting = true);

    try {
      final confirmed = _checkedIndices.map((i) => checklist[i]).toList();
      // 1. Ghi nhận xác minh an toàn thực phẩm lên Firestore
      await FoodLoopFirestoreService.submitFoodSafetyVerification(
        productId: productId,
        isPassed: true,
        confirmedItems: confirmed,
      );

      // 2. Tạo bài đăng chia sẻ 1 chạm trên bản đồ Quanh bạn
      // Note: vị trí của sản phẩm chia sẻ 1 chạm sẽ cách bạn ngẫu nhiên dưới và pickupAddress mặc định là 470 Trần Đại Nghĩa
      final sharedPost = await FoodService.instance.createSharedFoodPost(
        title: productName.isNotEmpty ? productName : 'Thực phẩm chia sẻ',
        badge: expiryText.isNotEmpty ? expiryText : 'Còn 1 ngày',
        condition: 'Đã kiểm tra an toàn (${confirmed.length} tiêu chí đạt)',
        pickupAddress: '470 Trần Đại Nghĩa',
      );

      // 3. Cập nhật trạng thái món đồ trong kho tủ lạnh
      if (productId.isNotEmpty && productId != 'food_safety_check_target') {
        try {
          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .update({'status': 'shared'});
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chia sẻ "${sharedPost.title}" lên Bản đồ Quanh bạn!'),
          backgroundColor: AppTokens.brand,
          duration: const Duration(seconds: 2),
        ),
      );

      // 4. Chuyển ngay đến Bản đồ "Quanh bạn" và hiển thị bài đăng vừa tạo
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/map',
        (route) => route.isFirst,
        arguments: {'highlightPostId': sharedPost.id},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi chia sẻ: $e'),
          backgroundColor: AppTokens.danger,
        ),
      );
    }
  }

  void _showFullRules(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppTokens.space20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quy tắc an toàn thực phẩm',
              style: AppTokens.headingMedium,
            ),
            const SizedBox(height: AppTokens.space12),
            const Text(
              '1. Thực phẩm chia sẻ phải còn trong hạn sử dụng an toàn.\n'
              '2. Bao bì còn nguyên vẹn, kín, không rách hay biến dạng.\n'
              '3. Đảm bảo vệ sinh an toàn thực phẩm và điều kiện bảo quản nhiệt độ chuẩn.\n'
              '4. Cung cấp thông tin trung thực về nguồn gốc và thời hạn.',
              style: AppTokens.bodyMedium,
            ),
            const SizedBox(height: AppTokens.space20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Đã hiểu quy tắc',
                  style: TextStyle(
                    color: AppTokens.brand,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final String? effectiveProductId = widget.productId ??
        (routeArgs is String
            ? routeArgs
            : (routeArgs is Map ? routeArgs['id']?.toString() : null));
    final Map<String, dynamic>? customProduct =
        routeArgs is Map<String, dynamic> ? routeArgs : null;

    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 1, // Tab tủ lạnh / quản lý thực phẩm được active theo thiết kế
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header màn hình
            const ScreenHeader(
              title: 'Kiểm tra an toàn thực phẩm',
            ),

            // 2. Nội dung cuộn lắng nghe dữ liệu từ Firestore
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FoodLoopFirestoreService.streamFoodSafetyCheck(effectiveProductId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTokens.brand),
                    );
                  }

                  final data = snapshot.data?.data() ?? {};

                  // Trích xuất dữ liệu từ Firestore hoặc arguments truyền vào
                  final String productName = customProduct?['name'] ??
                      customProduct?['title'] ??
                      data['productName'] ??
                      '';
                  final String productSubtitle = customProduct?['subtitle'] ??
                      customProduct?['space'] ??
                      data['productSubtitle'] ??
                      '';
                  final String productImage = customProduct?['image'] ??
                      customProduct?['imageUrl'] ??
                      data['productImage'] ??
                      '';
                  final String expiryText = customProduct?['expiry'] ??
                      data['expiryText'] ??
                      'Còn hạn sử dụng';

                  final String ruleTitle = data['ruleTitle'] ?? 'Quy tắc an toàn thực phẩm';
                  final String ruleMessage = data['ruleMessage'] ??
                      'Chỉ chia sẻ thực phẩm còn hạn, bao bì nguyên vẹn và đúng sự thật.';

                  final List<dynamic>? dynamicChecklist =
                      data['checklist'] as List<dynamic>?;
                  final List<String> checklist = dynamicChecklist != null
                      ? dynamicChecklist.map((e) => e.toString()).toList()
                      : <String>[
                          'Thực phẩm còn hạn sử dụng và đúng với thông tin đã nhập',
                          'Bao bì nguyên vẹn, không phồng, rách hay rò rỉ',
                          'Đã bảo quản đúng cách (ngăn mát hoặc ngăn đông nếu cần)',
                        ];

                  final int totalItems = checklist.length;
                  final int checkedCount = _checkedIndices.length;
                  final bool allChecked = totalItems > 0 && checkedCount == totalItems;
                  final double progress = totalItems > 0 ? (checkedCount / totalItems) : 0.0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PostCard(
                          title: productName.isNotEmpty ? productName : 'Sữa tươi TH True...',
                          subtitle: productSubtitle.isNotEmpty ? productSubtitle : '2 hộp - Ngăn mát',
                          image: productImage.isNotEmpty
                              ? Image.network(
                                  productImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: AppTokens.brandLight,
                                    child: const Icon(
                                      Icons.local_drink_rounded,
                                      color: AppTokens.brand,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppTokens.brandLight,
                                  child: const Icon(
                                    Icons.local_drink_rounded,
                                    color: AppTokens.brand,
                                  ),
                                ),
                          trailing: StatusBadge(
                            icon: Icons.schedule_rounded,
                            text: expiryText,
                            backgroundColor: const Color(0xFFFDE68A),
                            textColor: const Color(0xFF92400E),
                          ),
                        ),

                        const SizedBox(height: AppTokens.space16),

                        AlertBanner(
                          icon: Icons.info_outline_rounded,
                          iconColor: AppTokens.info,
                          backgroundColor: AppTokens.infoBg,
                          borderColor: AppTokens.infoBorder,
                          title: ruleTitle,
                          message: ruleMessage,
                          actionText: 'Xem đầy đủ quy tắc',
                          onAction: () => _showFullRules(context),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        RichText(
                          text: TextSpan(
                            style: AppTokens.bodyMedium.copyWith(
                              color: AppTokens.title,
                              fontSize: 14.5,
                            ),
                            children: [
                              const TextSpan(text: 'Đã xác nhận '),
                              TextSpan(
                                text: '$checkedCount/$totalItems',
                                style: const TextStyle(
                                  color: AppTokens.brand,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: ' mục'),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTokens.space8),

                        // Thanh tiến độ ngang
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5.0,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTokens.brand,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppTokens.space20),

                        ...List.generate(checklist.length, (index) {
                          final itemText = checklist[index];
                          final isChecked = _checkedIndices.contains(index);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppTokens.space12),
                            child: ConfirmationCheckbox(
                              isCardStyle: true,
                              value: isChecked,
                              text: itemText,
                              onChanged: (val) => _toggleIndex(index),
                            ),
                          );
                        }),

                        const SizedBox(height: AppTokens.space16),

                        PrimaryButton(
                          text: 'Hoàn tất chia sẻ lên Bản đồ',
                          isEnabled: allChecked,
                          isLoading: _isSubmitting,
                          backgroundColor:
                              allChecked ? AppTokens.brand : const Color(0xFFE2E8F0),
                          textColor:
                              allChecked ? Colors.white : const Color(0xFF94A3B8),
                          onPressed: allChecked
                              ? () => _handleContinue(
                                    productId: effectiveProductId ?? 'food_safety_check_target',
                                    checklist: checklist,
                                    productName: productName,
                                    productSubtitle: productSubtitle,
                                    expiryText: expiryText,
                                  )
                              : null,
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

