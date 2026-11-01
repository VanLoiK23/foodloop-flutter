import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'models/food_request_model.dart';
import 'services/food_service.dart';

class Screen58MyRequest extends StatefulWidget {
  final FoodRequest? request;

  const Screen58MyRequest({super.key, this.request});

  @override
  State<Screen58MyRequest> createState() => _Screen58MyRequestState();
}

class _Screen58MyRequestState extends State<Screen58MyRequest> {
  void _confirmCancel(FoodRequest req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hủy yêu cầu này?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn hủy yêu cầu xin nhận thực phẩm? Hành động này sẽ thông báo tới người chia sẻ.',
          style: TextStyle(fontSize: 14, color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Giữ lại', style: TextStyle(color: AppColors.gray)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FoodService.instance.cancelRequest(req.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã hủy yêu cầu xin thực phẩm thành công'),
                    backgroundColor: AppColors.brand,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xác nhận hủy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.title),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
            }
          },
        ),
        title: const Text(
          'Yêu cầu của tôi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.title,
          ),
        ),
      ),
      body: StreamBuilder<List<FoodRequest>>(
        stream: FoodService.instance.getMyRequestsStream(),
        builder: (context, snapshot) {
          final requests = snapshot.data ?? [];

          // Nếu có argument hoặc chưa có trên stream, lấy request đầu tiên hoặc tạo mẫu
          final req = widget.request ??
              (requests.isNotEmpty
                  ? requests.first
                  : FoodRequest(
                      id: 'sample_01',
                      postId: 'post_banhmi_01',
                      foodTitle: 'Bánh mì ngọt',
                      giverName: 'Lan Anh',
                      requestedQuantity: 2,
                      unit: 'cái',
                      timeSlot: '18:00 - 18:30',
                      message: 'Chào bạn, mình xin 2 cái bánh mì cho bữa sáng mai. Cảm ơn bạn!',
                      status: 'pending',
                      createdAt: DateTime.now(),
                    ));

          final isCancelled = req.isCancelled;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thẻ thông tin món yêu cầu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF8E6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.bakery_dining_outlined, color: AppColors.brand, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${req.foodTitle} · ${req.requestedQuantity} ${req.unit}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.title,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${req.giverName} · Cách bạn 250 m',
                              style: const TextStyle(fontSize: 12, color: AppColors.gray),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCancelled
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          req.statusDisplay,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCancelled
                                ? AppColors.danger
                                : const Color(0xFFF57F17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Tiến trình Timeline
                const Text(
                  'Tiến trình',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  ),
                  child: Column(
                    children: [
                      _buildTimelineStep(
                        isCompleted: true,
                        isActive: false,
                        icon: Icons.check,
                        title: 'Đã gửi yêu cầu',
                        subtitle: 'Hôm nay · ${_formatTime(req.createdAt)}',
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        isCompleted: false,
                        isActive: !isCancelled,
                        isDanger: isCancelled,
                        icon: isCancelled ? Icons.close : Icons.hourglass_empty,
                        title: isCancelled
                            ? 'Yêu cầu đã bị hủy'
                            : 'Đang chờ ${req.giverName} duyệt',
                        subtitle: isCancelled
                            ? 'Bạn đã hủy yêu cầu này'
                            : 'Thường phản hồi trong vài giờ',
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        isCompleted: false,
                        isActive: false,
                        icon: Icons.radio_button_unchecked,
                        title: 'Đến lấy thực phẩm',
                        subtitle: 'Hôm nay · ${req.timeSlot}',
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Lời nhắn của bạn
                const Text(
                  'Lời nhắn của bạn',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  ),
                  child: Text(
                    req.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.title,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 4. Nút Hủy yêu cầu (chỉ hiện khi chưa hủy)
                if (!isCancelled) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _confirmCancel(req),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Hủy yêu cầu',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Yêu cầu này đã kết thúc',
                      style: TextStyle(fontSize: 14, color: AppColors.gray, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineStep({
    required bool isCompleted,
    required bool isActive,
    bool isDanger = false,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    Color circleColor;
    Color iconColor;

    if (isCompleted) {
      circleColor = AppColors.brand;
      iconColor = Colors.white;
    } else if (isDanger) {
      circleColor = AppColors.danger;
      iconColor = Colors.white;
    } else if (isActive) {
      circleColor = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFF57F17);
    } else {
      circleColor = Colors.grey.shade200;
      iconColor = Colors.grey.shade500;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isCompleted ? AppColors.brand : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDanger ? AppColors.danger : AppColors.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
                if (!isLast) const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
