import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Sửa: thêm import còn thiếu
import 'package:image_picker/image_picker.dart';

import 'import_success_screen.dart'; 

class FigmaColors {
  static const Color background = Color(0xFFFBF9F1);
  static const Color brand = Color(0xFF2E7D32);
  static const Color brandLight = Color(0xFFE8F5E9);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color inputFill = Color(0xFFF9FAFB);
  static const Color danger = Color(0xFFEF4444);
}

class ProductItem {
  TextEditingController nameController = TextEditingController();
  String? category;
  int quantity = 1;
  String unit = 'Hộp';
  DateTime? expiryDate;
  DateTime? purchaseDate;
  String location = 'Ngăn mát';
  
  File? imageFile; 
  String? imageBase64;

  void dispose() {
    nameController.dispose();
  }
}

class AddProductManual extends StatefulWidget {
  const AddProductManual({super.key});

  @override
  State<AddProductManual> createState() => _AddProductManualState();
}

class _AddProductManualState extends State<AddProductManual> {
  List<ProductItem> products = [ProductItem()];

  final List<String> categories = ['Thịt cá', 'Rau củ', 'Sữa', 'Gia vị', 'Khác'];
  final List<String> units = ['Hộp', 'Kg', 'Chai', 'Gói', 'Quả'];

  final List<Map<String, dynamic>> locations = [
    {'name': 'Ngăn mát', 'icon': FontAwesomeIcons.temperatureLow},
    {'name': 'Ngăn đông', 'icon': FontAwesomeIcons.snowflake},
    {'name': 'Tủ bếp', 'icon': FontAwesomeIcons.kitchenSet},
    {'name': 'Kho khác', 'icon': FontAwesomeIcons.boxOpen},
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    for (var product in products) {
      product.dispose();
    }
    super.dispose();
  }

  void _addNewProduct() {
    setState(() {
      products.add(ProductItem());
    });
  }

  void _removeProduct(int index) {
    setState(() {
      products[index].dispose();
      products.removeAt(index);
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chọn ngày';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context, int index, bool isExpiry) async {
    final initialDate = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: isExpiry && products[index].expiryDate != null ? products[index].expiryDate! : initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isExpiry) {
          products[index].expiryDate = picked;
        } else {
          products[index].purchaseDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage(int index, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        File image = File(pickedFile.path);
        List<int> imageBytes = await image.readAsBytes();
        String base64String = base64Encode(imageBytes);

        setState(() {
          products[index].imageFile = image;
          products[index].imageBase64 = 'data:image/jpeg;base64,$base64String'; 
        });
      }
    } catch (e) {
      _showError('Không thể chọn ảnh: $e');
    }
  }

  void _showImagePickerOptions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: FigmaColors.brand),
                title: const Text('Chụp ảnh mới'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(index, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: FigmaColors.brand),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(index, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _validateAndSubmit() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < products.length; i++) {
      var p = products[i];
      if (p.nameController.text.trim().isEmpty) {
        _showError('Vui lòng nhập tên sản phẩm ở Panel ${i + 1}');
        return;
      }
      if (p.expiryDate == null) {
        _showError('Vui lòng chọn ngày hết hạn cho sản phẩm "${p.nameController.text}"');
        return;
      }
      
      DateTime exp = DateTime(p.expiryDate!.year, p.expiryDate!.month, p.expiryDate!.day);
      if (exp.isBefore(today) || exp.isAtSameMomentAs(today)) {
        _showError('Ngày hết hạn của "${p.nameController.text}" phải lớn hơn ngày hiện tại!');
        return;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: FigmaColors.brand)),
    );

    try {
      for (var p in products) {
        String name = p.nameController.text.trim();
        int daysLeft = p.expiryDate!.difference(today).inDays;
        
        // 1. Lưu sản phẩm vào collection 'products'
        await FirebaseFirestore.instance.collection('products').add({
          'name': name,
          'category': p.category,
          'quantity': p.quantity, // Firebase chỉ lưu 1 bản ghi sản phẩm nhưng có trường quantity
          'unit': p.unit,
          'space': p.location,
          'expiry': '${p.expiryDate!.day}/${p.expiryDate!.month}/${p.expiryDate!.year}',
          'purchased': p.purchaseDate == null ? null : '${p.purchaseDate!.day}/${p.purchaseDate!.month}/${p.purchaseDate!.year}',
          'noExpiry': false,
          'daysLeft': daysLeft,
          'badge': daysLeft < 0 ? 'Quá hạn ${daysLeft.abs()} ngày' : 'Còn $daysLeft ngày',
          'imageUrl': p.imageBase64 ?? 'https://picsum.photos/200', 
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 2. Lưu lịch sử hoạt động
        await FirebaseFirestore.instance.collection('activities').add({
          'text': 'Đã thêm $name vào ${p.location}',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3. LOGIC TĂNG ITEMCOUNT CHO NGĂN LƯU TRỮ
        // Lấy document của không gian (ngăn) có tên trùng với p.location
        final spaceQuery = await FirebaseFirestore.instance
            .collection('spaces')
            .where('name', isEqualTo: p.location)
            .limit(1)
            .get();

        // Nếu tìm thấy không gian đó
        if (spaceQuery.docs.isNotEmpty) {
          final spaceDocId = spaceQuery.docs.first.id;
          
          await FirebaseFirestore.instance
              .collection('spaces')
              .doc(spaceDocId)
              .update({
            // Tăng itemCount lên 1 cho mỗi item panel được lưu (hoặc dùng FieldValue.increment(p.quantity) nếu bạn muốn tính tổng theo số lượng hộp/cái)
            'itemCount': FieldValue.increment(1), 
            // Cập nhật trạng thái không gian (xóa chữ CHƯA CÓ ĐỒ)
            'status': 'ĐANG SỬ DỤNG', 
          });
        }
      }

      if (mounted) Navigator.pop(context); 

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ImportSuccessScreen(addedProducts: products)),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError('Đã xảy ra lỗi khi lưu: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: FigmaColors.danger, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: FigmaColors.border)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: FigmaColors.brand),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Thêm thực phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FigmaColors.textMain)),
                        Text('Nhập thông tin thực phẩm vào kho', style: TextStyle(fontSize: 12, color: FigmaColors.textMuted)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: products.length + 1,
                itemBuilder: (context, index) {
                  if (index == products.length) return _buildAddMoreButton();
                  return _buildProductCard(index);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng: ${products.length} sản phẩm', style: const TextStyle(color: FigmaColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _validateAndSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FigmaColors.brand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Tiến hành nhập kho', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(int index) {
    ProductItem item = products[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FigmaColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Sản phẩm', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: index == 0 ? FigmaColors.brand : FigmaColors.textMain)),
                  if (index == 0) const Text(' *', style: TextStyle(color: FigmaColors.danger, fontWeight: FontWeight.bold)),
                ],
              ),
              if (index > 0)
                InkWell(onTap: () => _removeProduct(index), child: const Icon(Icons.delete_outline, color: FigmaColors.danger, size: 22))
            ],
          ),
          const Divider(height: 24, color: FigmaColors.border),

          _buildLabel('TÊN SẢN PHẨM'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(controller: item.nameController, hint: 'Ví dụ: Sữa tươi TH True Milk'),
              ),
              const SizedBox(width: 12),
              
              InkWell(
                onTap: () => _showImagePickerOptions(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 52,
                  width: 65,
                  decoration: BoxDecoration(
                    color: FigmaColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: FigmaColors.border, width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
                  ),
                  child: item.imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.5),
                          child: Image.file(item.imageFile!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, color: FigmaColors.textMuted, size: 20),
                            SizedBox(height: 2),
                            Text('Thêm ảnh', style: TextStyle(fontSize: 9, color: FigmaColors.textMuted)),
                          ],
                        ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          _buildLabel('DANH MỤC'),
          _buildDropdown(
            value: item.category,
            hint: 'Chọn danh mục',
            items: categories,
            onChanged: (val) => setState(() => item.category = val),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('SỐ LƯỢNG'),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(color: FigmaColors.inputFill, borderRadius: BorderRadius.circular(12), border: Border.all(color: FigmaColors.border)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(icon: const Icon(Icons.remove, color: FigmaColors.brand, size: 20), onPressed: () {
                            if (item.quantity > 1) setState(() => item.quantity--);
                          }),
                          Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(icon: const Icon(Icons.add, color: FigmaColors.brand, size: 20), onPressed: () => setState(() => item.quantity++)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('ĐƠN VỊ'),
                    _buildDropdown(value: item.unit, hint: '', items: units, onChanged: (val) => setState(() => item.unit = val!)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('NGÀY HẾT HẠN'),
                    _buildDatePicker(text: _formatDate(item.expiryDate), icon: FontAwesomeIcons.calendarCheck, onTap: () => _selectDate(context, index, true), isHighlight: item.expiryDate != null),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('NGÀY MUA'),
                    _buildDatePicker(text: _formatDate(item.purchaseDate), icon: FontAwesomeIcons.calendarDay, onTap: () => _selectDate(context, index, false), isHighlight: item.purchaseDate != null),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildLabel('VỊ TRÍ CẤT GIỮ'),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 44, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: locations.length,
            itemBuilder: (context, locIndex) {
              final loc = locations[locIndex];
              final isSelected = item.location == loc['name'];
              return InkWell(
                onTap: () => setState(() => item.location = loc['name'] as String),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: isSelected ? FigmaColors.brandLight : Colors.white, border: Border.all(color: isSelected ? FigmaColors.brand : FigmaColors.border), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      // Sửa: dùng FaIcon cho icon FontAwesome, bỏ ép kiểu `as IconData`
                      FaIcon(loc['icon'], size: 18, color: isSelected ? FigmaColors.brand : FigmaColors.textMuted),
                      const SizedBox(width: 8),
                      Expanded(child: Text(loc['name'] as String, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? FigmaColors.brand : FigmaColors.textMain))),
                      if (isSelected) const Icon(Icons.check_circle, size: 16, color: FigmaColors.brand),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      child: InkWell(
        onTap: _addNewProduct,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          decoration: BoxDecoration(color: FigmaColors.brandLight.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: FigmaColors.brand.withOpacity(0.5), width: 1.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: FigmaColors.brand, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 16)),
              const SizedBox(width: 8),
              const Text('Thêm sản phẩm khác', style: TextStyle(color: FigmaColors.brand, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FigmaColors.textMuted, letterSpacing: 0.5)));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: FigmaColors.textMuted, fontSize: 14),
          filled: true, fillColor: FigmaColors.inputFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: FigmaColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: FigmaColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: FigmaColors.brand)),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String? value, required String hint, required List<String> items, required Function(String?) onChanged}) {
    return SizedBox(
      height: 52,
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint, style: const TextStyle(color: FigmaColors.textMuted, fontSize: 14)),
        icon: const Icon(Icons.keyboard_arrow_down, color: FigmaColors.textMuted),
        decoration: InputDecoration(
          filled: true, fillColor: FigmaColors.inputFill, contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: FigmaColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: FigmaColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: FigmaColors.brand)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker({required String text, required IconData icon, required VoidCallback onTap, required bool isHighlight}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: FigmaColors.inputFill, borderRadius: BorderRadius.circular(12), border: Border.all(color: FigmaColors.border)),
        child: Row(
          children: [
            Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: isHighlight ? FigmaColors.textMain : FigmaColors.textMuted))),
            FaIcon(icon, size: 18, color: isHighlight ? FigmaColors.brand : FigmaColors.textMuted),
          ],
        ),
      ),
    );
  }
}