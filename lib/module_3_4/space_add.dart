import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_theme.dart';

class SpaceAdd extends StatefulWidget {
  const SpaceAdd({super.key});

  @override
  State<SpaceAdd> createState() => _SpaceAddState();
}

class _SpaceAddState extends State<SpaceAdd> {
  final nameController = TextEditingController(text: 'Ngăn mát');
  final noteController = TextEditingController();
  String template = 'Ngăn mát';
  
  // Thay đổi từ bool remind sang int remindDays giống SpaceEdit
  int remindDays = 3; 
  bool _isLoading = false; 

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameController.text.trim();

    // 1. Validation: Kiểm tra rỗng
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên không gian *'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // 2. Validation: Kiểm tra Firebase
    if (!firebaseReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi kết nối máy chủ (Firebase chưa sẵn sàng)'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Bắt đầu quá trình lưu (Khóa nút bấm)
    setState(() => _isLoading = true);

    try {
      // Tắt bàn phím đang mở
      FocusScope.of(context).unfocus();

      await FirebaseFirestore.instance.collection('spaces').add({
        'name': name,
        'note': noteController.text.trim(),
        'template': template,
        'remindDays': remindDays, // Lưu số ngày nhắc nhở
        'itemCount': 0,
        'status': 'CHƯA CÓ ĐỒ',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('activities').add({
        'text': 'Đã tạo không gian $name',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Thông báo thành công
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm không gian $name thành công'),
              backgroundColor: AppColors.brand,
            ),
          );
          Navigator.pop(context); // Trở về màn hình trước
      }
      
    } catch (e) {
      // 3. Xử lý khi có lỗi mạng / lỗi Firebase
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      // Mở khóa nút bấm nếu màn hình vẫn còn
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- HÀM HIỂN THỊ BOTTOM SHEET CHỌN SỐ NGÀY NHẮC NHỞ ---
  void _showReminderBottomSheet() {
    int tempDays = remindDays;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thời gian nhắc hạn dùng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.title),
              ),
              const SizedBox(height: 4),
              const Text(
                'Chọn số ngày muốn được nhắc trước',
                style: TextStyle(fontSize: 12, color: AppColors.gray),
              ),
              const SizedBox(height: 16),
              
              // CupertinoPicker cho trải nghiệm cuộn
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: remindDays - 1),
                  onSelectedItemChanged: (int index) {
                    tempDays = index + 1;
                  },
                  children: List<Widget>.generate(7, (int index) {
                    final isSelected = (index + 1) == tempDays;
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: isSelected 
                            ? BoxDecoration(
                                color: AppColors.greenBg,
                                borderRadius: BorderRadius.circular(20),
                              )
                            : null,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 18, 
                            color: isSelected ? AppColors.brand : AppColors.title,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Vuốt lên hoặc xuống để thay đổi', style: TextStyle(color: AppColors.gray, fontSize: 10)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      remindDays = tempDays;
                    });
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Xác nhận', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Cập nhật lại UI thẻ để giống với _templateCard trong SpaceEdit cho đồng bộ
  Widget _templateCard(String title, String subtitle, IconData icon) {
    final selected = template == title;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          template = title;
          nameController.text = title;
          nameController.selection = TextSelection.fromPosition(
            TextPosition(offset: nameController.text.length),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.brand : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(icon, size: 16, color: selected ? AppColors.brand : AppColors.title),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.title, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.gray)),
                ],
              ),
            ),
            if (selected)
                const Icon(Icons.check_circle, color: AppColors.brand, size: 16)
          ],
        ),
      ),
    );
  }

  IconData _getIconForTemplate(String templateStr) {
    switch (templateStr) {
      case 'Ngăn đông':
        return FontAwesomeIcons.snowflake;
      case 'Tủ bếp':
        return FontAwesomeIcons.kitchenSet;
      case 'Vị trí khác':
        return FontAwesomeIcons.locationDot;
      case 'Ngăn mát':
      default:
        return FontAwesomeIcons.temperatureLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            // UX: Tự động ẩn bàn phím khi vuốt màn hình
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.title),
                  ),
                  const Expanded(
                    child: Text(
                      'Thêm không gian',
                      style: TextStyle(color: AppColors.title, fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                   Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border)
                      ),
                      child: const Row(
                          children: [
                              Icon(Icons.home, color: AppColors.brand, size: 14),
                              SizedBox(width: 4),
                              Text('Nhà của Lợi', style: TextStyle(color: AppColors.title, fontSize: 12, fontWeight: FontWeight.bold)),
                          ]
                      )
                  )
                ],
              ),
              const SizedBox(height: 16),

              // BẮT ĐẦU TỪ MẪU
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
                          const Text('BẮT ĐẦU TỪ MẪU', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 12)),
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.2,
                            children: [
                              _templateCard('Ngăn mát', 'Rau, sữa, thịt cá tươi', FontAwesomeIcons.temperatureLow),
                              _templateCard('Ngăn đông', 'Đồ đông lạnh', FontAwesomeIcons.snowflake),
                              _templateCard('Tủ bếp', 'Đồ khô, gia vị', FontAwesomeIcons.kitchenSet),
                              _templateCard('Vị trí khác', 'Tùy chỉnh', FontAwesomeIcons.locationDot),
                            ],
                          ),
                      ]
                  )
              ),
              const SizedBox(height: 16),

               // THÔNG TIN
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
                          const Text('THÔNG TIN', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 12)),
                          const SizedBox(height: 12),
                          
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  RichText(
                                      text: const TextSpan(
                                          text: 'Tên không gian ',
                                          style: TextStyle(color: AppColors.title, fontWeight: FontWeight.bold, fontSize: 12),
                                          children: [
                                              TextSpan(text: '*', style: TextStyle(color: AppColors.dangerStrong))
                                          ]
                                      )
                                  ),
                                  Text('${nameController.text.length}/30', style: const TextStyle(color: AppColors.gray, fontSize: 10)),
                              ]
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: nameController,
                            maxLength: 30,
                            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null, // Ẩn counter
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),

                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  const Text('Ghi chú ngắn (không bắt buộc)', style: TextStyle(color: AppColors.title, fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('${noteController.text.length}/60', style: const TextStyle(color: AppColors.gray, fontSize: 10)),
                              ]
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: noteController,
                            maxLength: 60,
                            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'Ví dụ: Tủ lạnh phòng ngủ',
                              hintStyle: const TextStyle(color: AppColors.muted),
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                      ]
                  )
              ),
              const SizedBox(height: 16),

              // XEM TRƯỚC
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
                          const Text('XEM TRƯỚC', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 12)),
                          const SizedBox(height: 12),
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border)
                              ),
                              child: Row(
                                  children: [
                                      Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: AppColors.greenBg,
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: FaIcon(_getIconForTemplate(template), size: 16, color: AppColors.brand)
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                  Text(nameController.text.trim().isEmpty ? template : nameController.text.trim(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.title)),
                                                  const Text('0 món đang lưu trữ', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                                              ]
                                          )
                                      ),
                                      Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: AppColors.accent.withOpacity(0.2), // Màu cam nhạt
                                              borderRadius: BorderRadius.circular(12)
                                          ),
                                          child: const Text('CHƯA CÓ ĐỒ', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold))
                                      )
                                  ]
                              )
                          )
                      ]
                  )
              ),
              const SizedBox(height: 16),

              // NHẮC HẠN DÙNG
              GestureDetector(
                onTap: _showReminderBottomSheet,
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border)
                    ),
                    child: Row(
                        children: [
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.2),
                                    shape: BoxShape.circle
                                ),
                                child: const Icon(Icons.notifications_active, color: AppColors.accent, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        const Text('Nhắc hạn dùng', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.title)),
                                        Text('Nhắc trước $remindDays ngày', style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ]
                                )
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: AppColors.gray)
                        ]
                    )
                ),
              ),

              const SizedBox(height: 24),
              // Nút Lưu
              FilledButton(
                onPressed: _isLoading ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: AppColors.brand.withOpacity(0.6), // Mờ đi khi disable
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Lưu không gian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}