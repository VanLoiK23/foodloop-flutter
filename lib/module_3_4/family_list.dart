import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_theme.dart';

class FamilyList extends StatefulWidget {
  const FamilyList({super.key});

  @override
  State<FamilyList> createState() => _FamilyListState();
}

class _FamilyListState extends State<FamilyList> {
  static const List<Map<String, dynamic>> _defaultMembers = [
    {
      'id': 'mem_1',
      'name': 'Phan Hà',
      'email': 'phanha@gmail.com',
      'role': 'Thành viên',
    },
    {
      'id': 'mem_2',
      'name': 'Bé An',
      'email': 'bean@gmail.com',
      'role': 'Thành viên',
    },
  ];
  
  // Sửa: thêm generic đầy đủ để doc.data() là Map<String, dynamic>
  Stream<QuerySnapshot<Map<String, dynamic>>> _members() {
    if (!firebaseReady) return const Stream.empty();
    return FirebaseFirestore.instance.collection('members').snapshots();
  }

  Future<void> _deleteMember(String id, String name) async {
    if (!firebaseReady) return;
    try {
      await FirebaseFirestore.instance.collection('members').doc(id).delete();
      
      // Ghi log hoạt động
      await FirebaseFirestore.instance.collection('activities').add({
        'text': 'Đã xóa thành viên $name khỏi kho gia đình',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa $name khỏi danh sách'), backgroundColor: AppColors.brand),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: AppColors.dangerStrong),
        );
      }
    }
  }

  Future<void> _updateMemberName(String id, String newName) async {
    if (!firebaseReady || newName.trim().isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('members').doc(id).update({
        'name': newName.trim(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đổi biệt danh thành công'), backgroundColor: AppColors.brand),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật: $e'), backgroundColor: AppColors.dangerStrong),
        );
      }
    }
  }

  // HÀM HIỂN THỊ POPUP ĐỔI TÊN THÀNH VIÊN
  void _showEditNameDialog(String id, String currentName) {
    final nameController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Đổi biệt danh', style: TextStyle(color: AppColors.title, fontSize: 18, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Nhập biệt danh mới',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: AppColors.gray, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brand,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _updateMemberName(id, nameController.text);
              },
            ),
          ],
        );
      },
    );
  }

  // HÀM HIỂN THỊ BOTTOM SHEET HÀNH ĐỘNG
  void _showMemberActionSheet(String id, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Text('Thành viên $name', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.title)),
              const SizedBox(height: 8),
              const Divider(color: AppColors.border, height: 1),
              
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: const Icon(Icons.settings, color: AppColors.title, size: 20),
                ),
                title: const Text('Đổi biệt danh', style: TextStyle(color: AppColors.title, fontSize: 14)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showEditNameDialog(id, name);
                },
              ),
              
              const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 64),
              
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.dangerBg, shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline, color: AppColors.dangerStrong, size: 20),
                ),
                title: const Text('Xóa khỏi kho gia đình', style: TextStyle(color: AppColors.dangerStrong, fontSize: 14)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _deleteMember(id, name);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          // Sửa: StreamBuilder dùng generic đầy đủ khớp với _members()
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _members(),
            builder: (context, snapshot) {
              final memberDocs = snapshot.data?.docs ?? [];
              final List<Map<String, dynamic>> memberList = memberDocs.isNotEmpty
                  ? memberDocs.map((doc) => {'id': doc.id, ...doc.data()}).toList()
                  : _defaultMembers;
              final totalMembers = memberList.length + 1; // +1 tính luôn chủ sở hữu cứng

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                        child: IconButton(
                          onPressed: () => Navigator.pushNamed(context, '/virtual-fridge'),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.title),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thành viên gia đình',
                              style: TextStyle(color: AppColors.title, fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Quản lý quyền truy cập kho',
                              style: TextStyle(color: AppColors.gray, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/invite-family'),
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Mời thành\nviên', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: const FaIcon(FontAwesomeIcons.userGroup, size: 16, color: AppColors.accent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kho gia đình', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.title, fontSize: 14)),
                              Text(
                                '$totalMembers thành viên đã tham gia',
                                style: const TextStyle(color: AppColors.gray, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.greenBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle, size: 6, color: AppColors.brand),
                              SizedBox(width: 4),
                              Text('ĐÃ ĐỒNG BỘ', style: TextStyle(color: AppColors.brand, fontSize: 10, fontWeight: FontWeight.w700)),
                            ]
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      const Text(
                        'Danh sách thành viên',
                        style: TextStyle(color: AppColors.title, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Text('$totalMembers'.padLeft(2, '0'), style: const TextStyle(color: AppColors.gray, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // HARDCODE CHỦ SỞ HỮU MẶC ĐỊNH
                  _memberCard(
                    id: null,
                    name: 'Huỳnh Văn Lợi',
                    email: 'loihv@gmail.com',
                    role: 'Chủ sở hữu',
                    isOwner: true,
                    seed: 11,
                  ),
                  
                  // RENDER THÀNH VIÊN (ƯU TIÊN FIREBASE, FALLBACK MẪU)
                  ...memberList.map((data) {
                    final id = data['id']?.toString();
                    return _memberCard(
                      id: id,
                      name: data['name']?.toString() ?? 'Thành viên',
                      email: data['email']?.toString() ?? '',
                      role: data['role']?.toString() ?? 'Thành viên',
                      isOwner: false,
                      seed: (id?.hashCode ?? data['name'].hashCode).abs() % 40 + 1,
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const FoodLoopBottomNav(currentIndex: 3),
    );
  }

  Widget _memberCard({
    required String? id,
    required String name,
    required String email,
    required String role,
    required bool isOwner,
    required int seed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://picsum.photos/seed/$seed/200'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.title, fontSize: 14)),
                      ),
                      if (isOwner) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('BẠN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.accent)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(email, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                ],
              ),
            ),
            
            // ROLE BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isOwner ? AppColors.greenBg : AppColors.surface,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text(
                role, 
                style: TextStyle(
                  color: isOwner ? AppColors.brand : AppColors.gray, 
                  fontWeight: FontWeight.w600, 
                  fontSize: 11
                )
              )
            ),
            
            // 3-DOT MENU CHO CÁC THÀNH VIÊN KHÁC
            if (!isOwner) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _showMemberActionSheet(id!, name),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.more_vert, color: AppColors.gray, size: 18),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}