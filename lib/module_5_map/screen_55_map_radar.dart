import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'models/food_post_model.dart';
import 'services/food_service.dart';
import 'screen_55_settings_bottom_sheet.dart';
import 'screen_55_quick_view_bottom_sheet.dart';
import 'widgets/radar_map_widget.dart';

class Screen55MapRadar extends StatefulWidget {
  const Screen55MapRadar({super.key});

  @override
  State<Screen55MapRadar> createState() => _Screen55MapRadarState();
}

class _Screen55MapRadarState extends State<Screen55MapRadar> {
  String _typeFilter = 'Tất cả'; // 'Tất cả', 'Cho', 'Xin'
  FoodPost? _selectedPost;
  bool _hasCheckedHighlight = false;

  @override
  void initState() {
    super.initState();
    // Tự động seed dữ liệu mẫu lên Firestore nếu đang trống
    FoodService.instance.seedInitialDataIfEmpty();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCheckedHighlight) {
      _hasCheckedHighlight = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['highlightPostId'] != null) {
        final targetId = args['highlightPostId'].toString();
        Future.delayed(const Duration(milliseconds: 400), () {
          FoodService.instance.getFoodPostById(targetId).then((post) {
            if (post != null && mounted) {
              _showPostPreview(post);
            }
          });
        });
      }
    }
  }

  void _showSettingsBottomSheet() {
    Screen55SettingsBottomSheet.show(context);
  }

  void _showPostPreview(FoodPost post) {
    setState(() {
      _selectedPost = post;
    });

    Screen55QuickViewBottomSheet.show(
      context,
      post,
      () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          '/food-detail',
          arguments: post,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header: Tiêu đề "Quanh bạn" & Nút mở BottomSheet Cài đặt
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quanh bạn',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.title,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_outlined, color: AppColors.title),
                    onPressed: _showSettingsBottomSheet,
                    tooltip: 'Cài đặt bản đồ',
                  ),
                ],
              ),
            ),

            // Toggle chuyển đổi: Bản đồ / Danh sách
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Bản đồ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/food-list');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.list_alt, size: 16, color: AppColors.gray),
                              SizedBox(width: 6),
                              Text(
                                'Danh sách',
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Chip bộ lọc: Tất cả / Cho / Xin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('Tất cả'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cho'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Xin'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Nội dung theo trạng thái quyền vị trí
            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 2),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _typeFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _typeFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brand : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brand : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.title,
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    return StreamBuilder<List<FoodPost>>(
      stream: FoodService.instance.getFoodPostsStream(typeFilter: _typeFilter),
      builder: (context, snapshot) {
        final posts = snapshot.data ?? [];

        return Stack(
          children: [
            // Bản đồ radar
            Positioned.fill(
              child: RadarMapWidget(
                posts: posts,
                selectedPost: _selectedPost,
                onPostSelected: _showPostPreview,
              ),
            ),

            // Tag thông tin bán kính ở trên bản đồ
            Positioned(
              top: 14,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.radar, size: 14, color: AppColors.brand),
                    const SizedBox(width: 6),
                    Text(
                      'Bán kính 1 km · ${posts.length} bài đăng',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.title,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
