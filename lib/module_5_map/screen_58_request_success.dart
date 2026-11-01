import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'models/food_request_model.dart';

class Screen58RequestSuccess extends StatelessWidget {
  final FoodRequest? request;

  const Screen58RequestSuccess({super.key, this.request});

  @override
  Widget build(BuildContext context) {
    final req = request ?? (ModalRoute.of(context)?.settings.arguments as FoodRequest?);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Biểu tượng dấu tick thành công
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    color: AppColors.brand,
                    size: 46,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Đã gửi yêu cầu!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.title,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '${req?.giverName ?? 'Người cho'} sẽ xem và phản hồi sớm. Bạn sẽ nhận thông báo khi được duyệt.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 32),

              // Thẻ tóm tắt thông tin đã gửi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                ),
                child: Column(
                  children: [
                    Row(
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
                                '${req?.foodTitle ?? 'Bánh mì ngọt'} · ${req?.requestedQuantity ?? 2} ${req?.unit ?? 'cái'}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.title,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Hôm nay · ${req?.timeSlot ?? '18:00 - 18:30'}',
                                style: const TextStyle(fontSize: 12, color: AppColors.gray),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        req?.statusDisplay ?? 'Đang chờ duyệt',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF57F17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Nút Xem yêu cầu của tôi
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/my-requests',
                      arguments: req,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Xem yêu cầu của tôi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Nút Tiếp tục xem quanh bạn
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.title,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục xem quanh bạn',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
