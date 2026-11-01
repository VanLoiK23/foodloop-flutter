import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_theme.dart';

class InviteFamilyBottomSheet extends StatefulWidget {
  const InviteFamilyBottomSheet({super.key});

  @override
  State<InviteFamilyBottomSheet> createState() => _InviteFamilyBottomSheetState();
}

class _InviteFamilyBottomSheetState extends State<InviteFamilyBottomSheet> {
  Future<void> _copyLink(BuildContext context) async {
    const link = 'https://foodloop.app/invite/family/kho-gia-dinh-123';
    await Clipboard.setData(const ClipboardData(text: link));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã sao chép liên kết mời thành công'), backgroundColor: AppColors.brand),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _downloadQR(BuildContext context) async {
    // Giả lập delay tải ảnh xuống
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.brand)),
    );
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (context.mounted) {
        Navigator.pop(context); // Tắt dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã lưu mã QR vào thiết bị (Thư viện ảnh)'), backgroundColor: AppColors.brand),
        );
        Navigator.pop(context); // Tắt bottom sheet
    }
  }

  // Sửa: nhận Object, tự chọn FaIcon (FaIconData) hoặc Icon (IconData)
  Widget _buildShareAppIcon(Object icon, String label, Color bgColor, Color iconColor) {
      final Widget iconWidget = icon is FaIconData
          ? FaIcon(icon, color: iconColor, size: 24)
          : Icon(icon as IconData, color: iconColor, size: 24);

      return Column(
          children: [
              CircleAvatar(
                  radius: 24,
                  backgroundColor: bgColor,
                  child: iconWidget
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray))
          ]
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Mã QR Kho gia đình Header
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16)
              ),
              child: Row(
                  children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                  Icon(Icons.qr_code_2, color: AppColors.gray, size: 32),
                                  Icon(Icons.group, color: AppColors.accent, size: 12)
                              ]
                          )
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text('Mã QR Kho gia đình', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.title, fontSize: 14)),
                                  Text('Quét mã để tham gia quản lý kho chung', style: TextStyle(color: AppColors.gray, fontSize: 12))
                              ]
                          )
                      )
                  ]
              )
          ),
          const SizedBox(height: 20),

          // Chia sẻ qua
          const Text('Chia sẻ qua', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.title)),
          const SizedBox(height: 16),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  _buildShareAppIcon(Icons.abc, 'Zalo', Colors.blue, Colors.white), // Zalo
                  _buildShareAppIcon(FontAwesomeIcons.facebookMessenger, 'Messenger', Colors.blueAccent, Colors.white),
                  _buildShareAppIcon(Icons.mail, 'Gmail', Colors.white, Colors.red),
                  _buildShareAppIcon(Icons.bluetooth, 'Bluetooth', Colors.blue, Colors.white),
              ]
          ),
          const SizedBox(height: 16),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  _buildShareAppIcon(Icons.share, 'Nearby', AppColors.surface, AppColors.title),
                  _buildShareAppIcon(Icons.chat_bubble, 'Tin nhắn', Colors.green, Colors.white),
                  _buildShareAppIcon(FontAwesomeIcons.instagram, 'Instagram', Colors.purpleAccent, Colors.white),
                  _buildShareAppIcon(Icons.more_horiz, 'Thêm', AppColors.surface, AppColors.gray),
              ]
          ),
          const SizedBox(height: 24),
          
          // Các hành động
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16)
              ),
              child: Column(
                  children: [
                      ListTile(
                        leading: const Icon(Icons.link, color: AppColors.brand),
                        title: const Text('Sao chép liên kết mời', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.title)),
                        trailing: const Icon(Icons.copy, size: 16, color: AppColors.gray),
                        onTap: () => _copyLink(context),
                      ),
                      const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.download, color: AppColors.gray),
                        title: const Text('Lưu mã QR vào thiết bị', style: TextStyle(color: AppColors.title)),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                        onTap: () => _downloadQR(context),
                      ),
                  ]
              )
          ),
          const SizedBox(height: 16),
          const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Icon(Icons.security, size: 14, color: AppColors.brand),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('Chỉ chia sẻ mã QR với người bạn muốn mời vào kho gia đình để bảo mật thông tin thực phẩm.', style: TextStyle(color: AppColors.brand, fontSize: 10))
                  )
              ]
          )
        ],
      ),
    );
  }
}