import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_theme.dart';
import 'space_selected_action_bottom_sheet.dart';

class StorageSpaceSelection extends StatelessWidget {
  const StorageSpaceSelection({super.key});

  // Sửa: thêm generic đầy đủ để doc.data() là Map<String, dynamic> (không còn Object?)
  Stream<QuerySnapshot<Map<String, dynamic>>> _spaces() {
    if (!firebaseReady) return const Stream.empty();
    // Khuyến nghị: có thể thêm .orderBy('createdAt') để sắp xếp danh sách theo thời gian tạo
    return FirebaseFirestore.instance.collection('spaces').orderBy('createdAt').snapshots();
  }
  
  // Hàm chuyển đổi String template thành Icon tương ứng
  FaIconData _getIconForTemplate(String template) {
    switch (template) {
      case 'Ngăn đông':
        return FontAwesomeIcons.snowflake;
      case 'Tủ bếp':
        return FontAwesomeIcons.kitchenSet;
      case 'Ngăn mát':
        return FontAwesomeIcons.temperatureLow;
      case 'Vị trí khác':
      default:
        return FontAwesomeIcons.locationDot;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          // Sửa: StreamBuilder dùng generic đầy đủ khớp với _spaces()
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _spaces(),
            builder: (context, snapshot) {
              final spaces = snapshot.data?.docs ?? [];
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/virtual-fridge'),
                        icon: const Icon(Icons.arrow_back, color: AppColors.title),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Không gian lưu trữ',
                              style: TextStyle(
                                color: AppColors.title,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Chọn nơi bạn muốn xem thực phẩm',
                              style: TextStyle(color: AppColors.gray, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Thông tin kho tổng
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.greenBg,
                          child: FaIcon(FontAwesomeIcons.house, size: 16, color: AppColors.brand),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kho gia đình', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.title)),
                              Text('Được chia sẻ với 3 thành viên', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('Đã đồng bộ', style: TextStyle(color: AppColors.brand, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Các khu vực của bạn',
                    style: TextStyle(color: AppColors.title, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  
                  // Chỉ hiển thị dữ liệu thực tế từ Firebase
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: AppColors.brand),
                      ),
                    )
                  else if (spaces.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Chưa có không gian nào. Hãy tạo mới!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.gray),
                      ),
                    )
                  else
                    ...spaces.map((doc) {
                      final data = doc.data();
                      final spaceName = data['name']?.toString() ?? 'Không gian';
                      // Lấy icon tương ứng dựa trên template
                      final iconTemplate = _getIconForTemplate(data['template']?.toString() ?? '');
                      // Lấy note (ghi chú) để hiển thị làm mô tả nhỏ
                      final note = data['note']?.toString() ?? '';
                      // Logic xác định trạng thái cảnh báo (warning) nếu status nhắc đến sự cố hoặc quá hạn
                      final status = data['status']?.toString() ?? '';
                      final isWarning = status.toLowerCase().contains('hết hạn') || status.toLowerCase().contains('quá hạn');

                      return _space(
                        context,
                        doc.id,
                        spaceName,
                        note, // Truyền Note vào làm description
                        '${data['itemCount'] ?? 0} món đang lưu trữ',
                        status,
                        iconTemplate,
                        isWarning,
                      );
                    }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/space-add'),
                    icon: const Icon(Icons.add, color: AppColors.brand),
                    label: const Text('+ Tạo không gian mới', style: TextStyle(color: AppColors.brand)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppColors.brand),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tạo thêm khu vực để quản lý thực phẩm riêng biệt',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 1),
    );
  }

  Widget _space(
    BuildContext context,
    String? id,
    String name,
    String description, // Thêm mô tả nhỏ
    String itemCountText,
    String badge,
    FaIconData icon,
    bool warning,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => Navigator.pushNamed(context, '/space-selected', arguments: {
          'spaceId': id,
          'spaceName': name,
        }),
        onLongPress: () => showAppSheet(
          context,
          SpaceSelectedActionBottomSheet(spaceId: id, spaceName: name),
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.cream,
          child: FaIcon(icon, size: 16, color: AppColors.title),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.title)),
            // Hiển thị phần mô tả nhỏ (nếu có nhập ghi chú)
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: AppColors.gray, fontStyle: FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(itemCountText, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
            if (badge.isNotEmpty)
              Text(
                badge,
                style: TextStyle(
                  color: warning ? AppColors.dangerStrong : AppColors.brand,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.gray),
          onPressed: () => showAppSheet(
            context,
            SpaceSelectedActionBottomSheet(spaceId: id, spaceName: name),
          ),
        ),
      ),
    );
  }
}