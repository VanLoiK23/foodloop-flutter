import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_theme.dart';

class ProductSelectedBottomSheet extends StatelessWidget {
  const ProductSelectedBottomSheet({
    super.key,
    this.productId,
    this.name = 'Sữa tươi TH True Milk',
    this.subtitle = '4 hộp - Ngăn mát',
    this.badge = 'Còn 2 ngày',
  });

  final String? productId;
  final String name;
  final String subtitle;
  final String badge;

  Future<void> _updateStatus(String status) async {
    if (productId == null || !firebaseReady) return;
    await FirebaseFirestore.instance.collection('products').doc(productId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance.collection('activities').add({
      'text': '$name đã được đánh dấu $status',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _delete() async {
    if (productId == null || !firebaseReady) return;
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
    await FirebaseFirestore.instance.collection('activities').add({
      'text': 'Đã bỏ $name',
      'createdAt': FieldValue.serverTimestamp(),
    });
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
          Row(
            children: [
              const AppNetworkImage(size: 48, seed: 21),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.title,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, size: 10, color: AppColors.title),
                          const SizedBox(width: 4),
                          Text(
                            badge,
                            style: const TextStyle(
                              color: AppColors.title,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _action(
            FontAwesomeIcons.shareNodes,
            'Chia sẻ 1 chạm',
            AppColors.brand,
            () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/food-safety-check',
                arguments: {
                  'id': productId ?? '',
                  'name': name,
                  'subtitle': subtitle,
                  'expiry': badge,
                },
              );
            },
          ),
          _action(
            FontAwesomeIcons.check,
            'Đã dùng hết',
            AppColors.title,
            () async {
              await _updateStatus('used');
              if (context.mounted) Navigator.pop(context);
            },
          ),
          _action(
            FontAwesomeIcons.trashCan,
            'Bỏ đi',
            AppColors.danger,
            () async {
              await _delete();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        const Divider(color: AppColors.border, height: 1),
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: AppColors.cream,
            child: FaIcon(icon, size: 16, color: color),
          ),
          title: Text(
            label,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
