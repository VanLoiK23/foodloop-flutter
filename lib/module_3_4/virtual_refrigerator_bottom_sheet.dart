import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_theme.dart';

class VirtualRefrigeratorBottomSheet extends StatelessWidget {
  const VirtualRefrigeratorBottomSheet({super.key});

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
          const Text(
            'Thêm thực phẩm',
            style: TextStyle(
              color: AppColors.title,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _row(
            context,
            FontAwesomeIcons.penToSquare,
            'Nhập thủ công',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add-product');
            },
          ),
          const Divider(color: AppColors.border, height: 1),
          _row(
            context,
            FontAwesomeIcons.receipt,
            'Quét hóa đơn siêu thị',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/import-product');
            },
          ),
          const Divider(color: AppColors.border, height: 1),
          _row(
            context,
            FontAwesomeIcons.qrcode,
            'Quét mã QR',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/import-product');
            },
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.cream,
        child: FaIcon(icon, size: 16, color: AppColors.brand),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.title,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
