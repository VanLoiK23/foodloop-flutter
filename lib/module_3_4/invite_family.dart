import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

import '../app_theme.dart';
import 'invite_family_bottom_sheet.dart';

class InviteFamily extends StatefulWidget {
  const InviteFamily({super.key});

  @override
  State<InviteFamily> createState() => _InviteFamilyState();
}

class _InviteFamilyState extends State<InviteFamily> {
  final emailController = TextEditingController();
  bool _isCopied = false;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // --- HÀM VALIDATE EMAIL ---
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  Future<void> _sendInvite() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Vui lòng nhập địa chỉ email', isError: true);
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar('Định dạng email không hợp lệ', isError: true);
      return;
    }

    if (!firebaseReady) {
      _showSnackBar('Lỗi kết nối máy chủ', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Kiểm tra email có tồn tại trong collection 'users' hay không
      final userQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Nếu không tìm thấy user
      if (userQuery.docs.isEmpty) {
        _showSnackBar('Tài khoản chưa được đăng ký trên hệ thống FoodLoop', isError: true);
        return;
      }

      // Lấy thông tin user từ Firebase (Giả sử collection users có trường 'name')
      final userData = userQuery.docs.first.data();
      final userName = userData['name']?.toString() ?? email.split('@')[0];

      // 2. Thêm vào invitations (Lời mời)
      await firestore.collection('invitations').add({
        'email': email,
        'status': 'Đang chờ',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Tự động thêm vào danh sách members (Thành viên kho)
      await firestore.collection('members').add({
        'email': email,
        'name': userName,
        'role': 'Thành viên',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // 4. Ghi nhận lịch sử hoạt động
      await firestore.collection('activities').add({
        'text': 'Đã mời $userName tham gia kho gia đình',
        'createdAt': FieldValue.serverTimestamp(),
      });

      emailController.clear();
      _showSnackBar('Đã thêm $email vào kho gia đình thành công!');
      
    } catch (e) {
      _showSnackBar('Lỗi khi gửi lời mời: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _copyLink() async {
    const link = 'https://foodloop.app/invite/family/kho-gia-dinh-123';
    await Clipboard.setData(const ClipboardData(text: link));
    
    if (mounted) {
      setState(() {
        _isCopied = true;
      });

      // Hẹn giờ 5 giây sau đổi text lại như cũ
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _isCopied = false;
          });
        }
      });
    }
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.dangerStrong : AppColors.brand,
        ),
      );
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          // Sửa: thêm generic đầy đủ để doc.data() là Map<String, dynamic>
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firebaseReady
                ? FirebaseFirestore.instance
                    .collection('invitations')
                    .orderBy('createdAt', descending: true)
                    .snapshots()
                : const Stream.empty(),
            builder: (context, snapshot) {
              final invites = snapshot.data?.docs ?? [];
              
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: AppColors.title),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mời thành viên',
                              style: TextStyle(color: AppColors.title, fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Cùng gia đình quản lý kho thực phẩm',
                              style: TextStyle(color: AppColors.gray, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Thẻ "Kho gia đình"
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.greenBg,
                            borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Kho gia đình', style: TextStyle(color: AppColors.brand, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // MỜI BẰNG EMAIL
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border)
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const Text('Mời bằng email', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.title, fontSize: 16)),
                             const SizedBox(height: 12),
                             TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Nhập địa chỉ email',
                                  hintStyle: const TextStyle(color: AppColors.muted),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _isLoading ? null : _sendInvite,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.brand,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading 
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Gửi lời mời', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 12),
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: AppColors.brand),
                                  SizedBox(width: 6),
                                  Text('Email khả dụng để gửi lời mời', style: TextStyle(color: AppColors.brand, fontSize: 12)),
                                ],
                              ),
                          ]
                      )
                  ),
                  const SizedBox(height: 16),
                  
                  // MỜI BẰNG LIÊN KẾT
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border)
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const Text('Mời bằng liên kết', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.title, fontSize: 16)),
                             const Text('Chia sẻ liên kết để người thân tham gia kho', style: TextStyle(color: AppColors.gray, fontSize: 13)),
                             const SizedBox(height: 12),
                             Row(
                                 children: [
                                     Expanded(
                                         child: OutlinedButton(
                                            onPressed: _copyLink,
                                            style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: AppColors.accent),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                minimumSize: const Size(0, 50)
                                            ),
                                            child: Text(
                                                _isCopied ? 'Đã sao chép' : 'Sao chép liên kết', 
                                                style: const TextStyle(color: AppColors.title, fontWeight: FontWeight.bold)
                                            ),
                                          ),
                                     ),
                                     const SizedBox(width: 12),
                                     Container(
                                         decoration: BoxDecoration(
                                             color: AppColors.surface,
                                             borderRadius: BorderRadius.circular(12),
                                             border: Border.all(color: AppColors.border)
                                         ),
                                         child: IconButton(
                                             icon: const Icon(Icons.share, color: AppColors.title),
                                             onPressed: () {} // Thêm logic share system nếu cần
                                         )
                                     )
                                 ]
                             ),
                             const SizedBox(height: 12),
                             const Row(
                                children: [
                                  Icon(Icons.circle, size: 6, color: AppColors.brand),
                                  SizedBox(width: 6),
                                  Text('Liên kết còn hiệu lực trong 1h', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                                ],
                              ),
                          ]
                      )
                  ),
                  
                  const SizedBox(height: 16),

                  // MÃ QR
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border)
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const Text('Mã QR lời mời', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.title, fontSize: 16)),
                             const SizedBox(height: 16),
                             Center(
                                 child: Container(
                                     width: 150,
                                     height: 150,
                                     decoration: BoxDecoration(
                                         border: Border.all(color: AppColors.border, width: 2),
                                         borderRadius: BorderRadius.circular(16)
                                     ),
                                     child: const Stack(
                                         alignment: Alignment.center,
                                         children: [
                                             Icon(Icons.qr_code_2, size: 100, color: AppColors.border), // Giả lập QR mờ mờ
                                             CircleAvatar(
                                                 backgroundColor: AppColors.accent,
                                                 child: Icon(Icons.group, color: Colors.white, size: 20)
                                             )
                                         ]
                                     )
                                 )
                             ),
                             const SizedBox(height: 16),
                             GestureDetector(
                                onTap: () => showAppSheet(context, const InviteFamilyBottomSheet()),
                                child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                    child: const Text('Quét trực tiếp hoặc Chia sẻ QR', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.title))
                                )
                             )
                          ]
                      )
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // LỜI MỜI ĐANG CHỜ
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Lời mời đang chờ', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.title, fontSize: 16)),
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: Text('${invites.length}'.padLeft(2, '0'), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12))
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // LIST INVITES
                  if (invites.isEmpty)
                     Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border)
                        ),
                        child: const Center(child: Text('Chưa có lời mời nào đang chờ', style: TextStyle(color: AppColors.gray)))
                     )
                  else
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border)
                        ),
                        child: Column(
                            children: invites.map((doc) {
                                final data = doc.data();
                                final isLast = doc == invites.last;
                                return Column(
                                    children: [
                                        ListTile(
                                          leading: AppNetworkImage(size: 40, seed: data['email'].hashCode.abs() % 80),
                                          title: Text(data['email']?.toString() ?? 'Lời mời', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.title, fontSize: 14)),
                                          subtitle: Row(
                                              children: [
                                                  const Icon(Icons.history, size: 12, color: AppColors.gray),
                                                  const SizedBox(width: 4),
                                                  Text(data['status']?.toString() ?? 'Đang chờ', style: const TextStyle(color: AppColors.gray, fontSize: 12))
                                              ]
                                          ),
                                          trailing: const Icon(Icons.more_vert, color: AppColors.gray),
                                        ),
                                        if (!isLast) const Divider(height: 1, color: AppColors.border, indent: 70)
                                    ]
                                );
                            }).toList()
                        )
                    )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}