import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_theme.dart';

class SpaceSelectedActionBottomSheet extends StatelessWidget {
  const SpaceSelectedActionBottomSheet({
    super.key,
    this.spaceId,
    this.spaceName = 'Ngăn mát',
  });

  final String? spaceId;
  final String spaceName;

  Future<void> _delete(BuildContext context) async {
    if (spaceId == null || !firebaseReady) return;
    
    try {
      await FirebaseFirestore.instance.collection('spaces').doc(spaceId).delete();
      
      await FirebaseFirestore.instance.collection('activities').add({
        'text': 'Đã xóa không gian $spaceName',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa $spaceName thành công'),
            backgroundColor: AppColors.brand,
          ),
        );
        // Trở về trang trước đó sau khi xóa xong (về danh sách không gian)
        Navigator.pop(context); // Đóng popup xác nhận
        Navigator.pop(context); // Đóng trang chi tiết không gian
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: AppColors.dangerStrong),
        );
      }
    }
  }

  // --- HÀM HIỂN THỊ POPUP XÁC NHẬN ---
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.dangerStrong, size: 28),
              const SizedBox(width: 8),
              const Expanded(child: Text('Xác nhận xóa')),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa không gian "$spaceName"? Tất cả sản phẩm bên trong có thể sẽ không thuộc không gian nào nữa.',
            style: const TextStyle(color: AppColors.title),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: AppColors.gray, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.dangerStrong,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Xóa', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                // Gọi hàm xóa và truyền context của toàn bộ app để Pop đúng trang
                _delete(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            spaceName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.title,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: AppColors.cream,
              child: FaIcon(FontAwesomeIcons.penToSquare, size: 16, color: AppColors.title),
            ),
            title: const Text(
              'Chỉnh sửa không gian lưu trữ',
              style: TextStyle(color: AppColors.title, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context); // Đóng BottomSheet
              Navigator.pushNamed(context, '/space-edit', arguments: {
                'spaceId': spaceId,
                'spaceName': spaceName,
              });
            },
          ),
          const Divider(color: AppColors.border, height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: AppColors.dangerBg, // Nền đỏ nhạt để cảnh báo
              child: FaIcon(FontAwesomeIcons.trashCan, size: 16, color: AppColors.dangerStrong), // Icon đỏ đậm
            ),
            title: const Text(
              'Xóa không gian lưu trữ',
              style: TextStyle(color: AppColors.dangerStrong, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context); // Đóng BottomSheet trước
              _showDeleteConfirmationDialog(context); // Mở Popup xác nhận
            },
          ),
        ],
      ),
    );
  }
}