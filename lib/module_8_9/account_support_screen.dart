import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/app_form_field.dart';
import '../components/bottom_nav.dart';
import '../components/primary_button.dart';
import '../components/screen_header.dart';
import '../services/foodloop_firestore_service.dart';
import '../theme/app_tokens.dart';

class AccountSupportScreen extends StatefulWidget {
  const AccountSupportScreen({super.key});

  @override
  State<AccountSupportScreen> createState() => _AccountSupportScreenState();
}

class _AccountSupportScreenState extends State<AccountSupportScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final email = _emailController.text.trim();
    final content = _contentController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập địa chỉ email hợp lệ.'),
          backgroundColor: AppTokens.danger,
        ),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung cần hỗ trợ.'),
          backgroundColor: AppTokens.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FoodLoopFirestoreService.submitSupportRequest(
        email: email,
        content: content,
      );

      if (!mounted) return;
      _emailController.clear();
      _contentController.clear();
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Yêu cầu hỗ trợ của bạn đã được gửi thành công lên Firebase!'),
          backgroundColor: AppTokens.brand,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi gửi yêu cầu hỗ trợ: $e'),
          backgroundColor: AppTokens.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      bottomNavigationBar: FoodLoopBottomNavComponent(
        currentIndex: 4,
        onTap: (index) {},
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FoodLoopFirestoreService.streamAccountSupportInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTokens.brand),
              );
            }

            final firestoreData = snapshot.data?.data();
            final data = firestoreData ?? const <String, dynamic>{
              'headerTitle': 'Liên hệ hỗ trợ tài khoản',
              'headerSubtitle': 'Chúng tôi sẽ phản hồi qua email trong vòng 24 giờ.',
              'introTitle': 'Bạn gặp vấn đề về tài khoản?',
              'introSubtitle': 'Vui lòng mô tả chi tiết vấn đề để đội ngũ hỗ trợ nhanh nhất.',
            };

            final String headerTitle =
                data['title'] ?? 'Liên hệ hỗ trợ tài khoản';
            final String headerSubtitle = data['subtitle'] ?? '';
            final String emailLabel = data['emailLabel'] ?? 'Email liên hệ';
            final String emailHint = data['emailHint'] ?? 'Nhập email của bạn';
            final String emailHelper = data['emailHelper'] ?? '';
            final String contentLabel =
                data['contentLabel'] ?? 'Nội dung cần hỗ trợ';
            final String contentHint = data['contentHint'] ?? '';
            final String contentHelper = data['contentHelper'] ?? '';
            final String submitButtonText =
                data['submitButtonText'] ?? 'Gửi yêu cầu';

            return Column(
              children: [
                // Header tải dữ liệu từ Firestore
                ScreenHeader(
                  title: headerTitle,
                  subtitle: headerSubtitle.isNotEmpty ? headerSubtitle : null,
                ),

                // Nội dung cuộn
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ô nhập email liên hệ
                        AppFormField(
                          label: emailLabel,
                          hintText: emailHint,
                          controller: _emailController,
                          helperText:
                              emailHelper.isNotEmpty ? emailHelper : null,
                        ),

                        const SizedBox(height: AppTokens.space20),

                        // Ô nhập nội dung cần hỗ trợ
                        AppFormField(
                          label: contentLabel,
                          hintText: contentHint,
                          controller: _contentController,
                          minLines: 4,
                          maxLines: 5,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(
                              left: AppTokens.space12,
                              top: AppTokens.space12,
                              right: AppTokens.space8,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: Icon(
                                Icons.edit_note_rounded,
                                color: AppTokens.textSecondary,
                                size: 24,
                              ),
                            ),
                          ),
                          helperText:
                              contentHelper.isNotEmpty ? contentHelper : null,
                        ),

                        const SizedBox(height: AppTokens.space32),

                        // Nút bấm gửi yêu cầu
                        PrimaryButton(
                          text: submitButtonText,
                          isLoading: _isSubmitting,
                          onPressed: _handleSubmit,
                        ),

                        const SizedBox(height: AppTokens.space24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
