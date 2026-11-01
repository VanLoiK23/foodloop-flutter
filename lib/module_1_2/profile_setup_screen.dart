import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_session.dart';

class Screen09ProfileSetup extends StatefulWidget {
  const Screen09ProfileSetup({super.key});

  @override
  State<Screen09ProfileSetup> createState() =>
      _Screen09ProfileSetupState();
}

class _Screen09ProfileSetupState
    extends State<Screen09ProfileSetup> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _nameController =
      TextEditingController();

  String? _userId;

  String _fullName = '';
  String _dietPreference = 'unrestricted';

  List<String> _allergies = [];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isNavigating = false;

  static const Color primaryColor =
      Color(0xFF2E7D32);

  static const Color textColor =
      Color(0xFF2B3A35);

  static const Color hintColor =
      Color(0xFF6B7280);

  static const Color backgroundColor =
      Color(0xFFFFF8E7);

  final List<Map<String, String>> _dietOptions = [
    {
      'value': 'vegetarian',
      'label': 'Chay',
    },
    {
      'value': 'non_vegetarian',
      'label': 'Mặn',
    },
    {
      'value': 'unrestricted',
      'label': 'Không giới hạn',
    },
  ];

  final List<String> _allergyOptions = [
    'Sữa',
    'Trứng',
    'Hải sản',
    'Thịt',
    'Khác',
  ];

  // =========================
  // LẤY UID TỪ SESSION
  // =========================

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Lấy UID từ SharedPreferences Session
      final sessionUserId =
          await UserSession.getUserId();

      if (sessionUserId == null ||
          sessionUserId.trim().isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        _showMessage(
          'Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.',
          isError: true,
        );

        return;
      }

      // Lưu UID hiện tại vào biến
      _userId = sessionUserId;

      // Lấy users/{uid}
      final snapshot = await _firestore
          .collection('users')
          .doc(sessionUserId)
          .get();

      if (!snapshot.exists) {
        throw Exception(
          'Không tìm thấy thông tin tài khoản.',
        );
      }

      final data = snapshot.data() ?? {};

      final name =
          data['fullName']?.toString() ?? '';

      final diet =
          data['dietPreference']?.toString() ??
              'unrestricted';

      final allergiesData =
          data['allergies'];

      final validDiet = _dietOptions.any(
        (option) =>
            option['value'] == diet,
      );

      final loadedAllergies =
          allergiesData is List
              ? allergiesData
                  .whereType<String>()
                  .where(
                    (item) =>
                        _allergyOptions
                            .contains(item),
                  )
                  .toList()
              : <String>[];

      if (!mounted) return;

      setState(() {
        _fullName = name;
        _nameController.text = name;

        _dietPreference =
            validDiet
                ? diet
                : 'unrestricted';

        _allergies = loadedAllergies;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Không thể tải hồ sơ: ${_errorMessage(e)}',
        isError: true,
      );
    }
  }

  // =========================
  // LƯU DATA FIRESTORE
  // =========================

  Future<void> _saveData(
    Map<String, dynamic> data,
  ) async {
    if (_userId == null ||
        _userId!.trim().isEmpty) {
      _showMessage(
        'Không xác định được tài khoản.',
        isError: true,
      );
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Lưu vào users/{UID}
      await _firestore
          .collection('users')
          .doc(_userId!)
          .update({
        ...data,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showMessage(
        'Đã lưu thông tin thành công.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Lưu thông tin thất bại: ${_errorMessage(e)}',
        isError: true,
      );

      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // =========================
  // CHỈNH SỬA TÊN
  // =========================

  Future<void> _editName() async {
    _nameController.text = _fullName;

    final result =
        await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            'Chỉnh sửa tên hiển thị',
            style: TextStyle(
              color: textColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: 60,
            decoration: InputDecoration(
              hintText:
                  'Nhập tên hiển thị',
              counterText: '',
              filled: true,
              fillColor: backgroundColor,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
                borderSide:
                    const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
                borderSide:
                    const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
                borderSide:
                    const BorderSide(
                  color: primaryColor,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: hintColor,
                ),
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final name =
                    _nameController.text
                        .trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Vui lòng nhập tên hiển thị.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  name,
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (result == null ||
        result.isEmpty ||
        !mounted) {
      return;
    }

    if (result == _fullName) return;

    final oldName = _fullName;

    setState(() {
      _fullName = result;
    });

    try {
      await _saveData({
        'fullName': result,
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _fullName = oldName;
        _nameController.text = oldName;
      });
    }
  }

  // =========================
  // CHỌN CHẾ ĐỘ ĂN
  // =========================

  Future<void> _selectDiet(
    String value,
  ) async {
    if (_isSaving ||
        value == _dietPreference) {
      return;
    }

    final oldValue =
        _dietPreference;

    setState(() {
      _dietPreference = value;
    });

    try {
      await _saveData({
        'dietPreference': value,
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _dietPreference = oldValue;
      });
    }
  }

  // =========================
  // DỊ ỨNG
  // =========================

  Future<void> _toggleAllergy(
    String allergy,
  ) async {
    if (_isSaving) return;

    final oldAllergies =
        List<String>.from(
      _allergies,
    );

    setState(() {
      if (_allergies.contains(allergy)) {
        _allergies.remove(allergy);
      } else {
        _allergies.add(allergy);
      }
    });

    try {
      await _saveData({
        'allergies': _allergies,
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _allergies = oldAllergies;
      });
    }
  }

  // =========================
  // TIẾP TỤC HOME
  // =========================

  Future<void> _continueToHome() async {
    if (_isNavigating ||
        _isSaving) {
      return;
    }

    // Kiểm tra lại Session
    final sessionUserId =
        await UserSession.getUserId();

    if (!mounted) return;

    if (sessionUserId == null ||
        sessionUserId.trim().isEmpty) {
      _showMessage(
        'Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.',
        isError: true,
      );
      return;
    }

    // Đồng bộ UID từ Session
    _userId = sessionUserId;

    setState(() {
      _isNavigating = true;
    });

    try {
      // Lưu lại toàn bộ profile vào users/{UID}
      await _firestore
          .collection('users')
          .doc(sessionUserId)
          .update({
        'fullName': _fullName,
        'dietPreference':
            _dietPreference,
        'allergies': _allergies,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Không truyền arguments nữa.
      // Home nếu cần UID cũng lấy từ Session.
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/system_permissions',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Không thể lưu hồ sơ: ${_errorMessage(e)}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  // =========================
  // BỎ QUA PROFILE
  // =========================

  Future<void> _skipProfile() async {
    if (_isNavigating ||
        _isSaving) {
      return;
    }

    final sessionUserId =
        await UserSession.getUserId();

    if (!mounted) return;

    if (sessionUserId == null ||
        sessionUserId.trim().isEmpty) {
      _showMessage(
        'Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.',
        isError: true,
      );
      return;
    }

    _userId = sessionUserId;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  // =========================
  // FIREBASE ERROR
  // =========================

  String _errorMessage(
    Object error,
  ) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Bạn không có quyền truy cập dữ liệu.';

        case 'unavailable':
          return 'Không có kết nối mạng. Vui lòng thử lại.';

        case 'not-found':
          return 'Không tìm thấy hồ sơ người dùng.';

        default:
          return error.message ??
              'Đã xảy ra lỗi Firebase.';
      }
    }

    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }

  // =========================
  // THÔNG BÁO
  // =========================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError
                  ? Colors.red.shade700
                  : primaryColor,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // =========================
  // DIET OPTION
  // =========================

  Widget _buildDietOption(
    Map<String, String> option,
  ) {
    final value =
        option['value']!;

    final label =
        option['label']!;

    final isSelected =
        _dietPreference == value;

    return InkWell(
      onTap: _isSaving
          ? null
          : () => _selectDiet(value),
      borderRadius:
          BorderRadius.circular(10),
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration:
            BoxDecoration(
          color: isSelected
              ? const Color(
                  0xFFE8F5E9,
                )
              : Colors.white,
          border:
              Border.all(
            color: isSelected
                ? primaryColor
                : const Color(
                    0xFFE5E7EB,
                  ),
            width:
                isSelected
                    ? 1.5
                    : 1,
          ),
          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight:
                      isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                ),
              ),
            ),

            if (isSelected) ...[
              const SizedBox(
                width: 5,
              ),
              const Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // ALLERGY OPTION
  // =========================

  Widget _buildAllergyOption(
    String allergy,
  ) {
    final isSelected =
        _allergies.contains(
      allergy,
    );

    return InkWell(
      onTap: _isSaving
          ? null
          : () =>
              _toggleAllergy(
                allergy,
              ),
      borderRadius:
          BorderRadius.circular(20),
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration:
            BoxDecoration(
          color: isSelected
              ? const Color(
                  0xFFE8F5E9,
                )
              : Colors.white,
          border:
              Border.all(
            color: isSelected
                ? primaryColor
                : const Color(
                    0xFFE5E7EB,
                  ),
          ),
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(
              allergy,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight:
                    isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
              ),
            ),

            if (isSelected) ...[
              const SizedBox(
                width: 5,
              ),
              const Icon(
                Icons.check,
                color: primaryColor,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: const TextStyle(
        color: textColor,
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight:
            FontWeight.w700,
        height: 1.43,
      ),
    );
  }

  // =========================
  // PROFILE CONTENT
  // =========================

  Widget _buildProfileContent() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration:
          ShapeDecoration(
        color: Colors.white,
        shape:
            RoundedRectangleBorder(
          side:
              const BorderSide(
            width: 1,
            color:
                Color(0xFFE5E7EB),
          ),
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
      ),
      child:
          SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Ảnh đại diện
            Center(
              child: Container(
                width: 81,
                height: 81,
                decoration:
                    const ShapeDecoration(
                  color: Colors.white,
                  shape:
                      OvalBorder(
                    side:
                        BorderSide(
                      width: 2,
                      color:
                          Color(0x45000000),
                    ),
                  ),
                ),
                child:
                    const Icon(
                  Icons.person,
                  size: 40,
                  color: textColor,
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // Tên hiển thị
            InkWell(
              onTap: _isSaving
                  ? null
                  : _editName,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
              child: Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration:
                    ShapeDecoration(
                  color:
                      backgroundColor,
                  shape:
                      RoundedRectangleBorder(
                    side:
                        const BorderSide(
                      width: 1,
                      color:
                          Color(0x3F2E7D32),
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Tên hiển thị :',
                      style:
                          TextStyle(
                        color:
                            textColor,
                        fontSize: 14,
                        fontFamily:
                            'Inter',
                        fontWeight:
                            FontWeight.w700,
                        height: 1.43,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        _fullName
                                .isEmpty
                            ? 'Chưa thiết lập'
                            : _fullName,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              textColor,
                          fontSize:
                              16,
                          fontFamily:
                              'Inter',
                          fontWeight:
                              FontWeight.w500,
                          height:
                              1.25,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.edit_outlined,
                      size: 19,
                      color:
                          primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // Chế độ ăn
            _buildSectionTitle(
              'Chế độ ăn uống :',
            ),

            const SizedBox(
              height: 8,
            ),

            Wrap(
              spacing: 8,
              runSpacing: 10,
              children:
                  _dietOptions
                      .map(
                        _buildDietOption,
                      )
                      .toList(),
            ),

            const SizedBox(
              height: 20,
            ),

            // Dị ứng
            _buildSectionTitle(
              'Dị ứng thực phẩm :',
            ),

            const SizedBox(
              height: 8,
            ),

            Wrap(
              spacing: 10,
              runSpacing: 12,
              children:
                  _allergyOptions
                      .map(
                        _buildAllergyOption,
                      )
                      .toList(),
            ),

            if (_isSaving) ...[
              const SizedBox(
                height: 16,
              ),

              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          primaryColor,
                    ),
                  ),

                  SizedBox(
                    width: 10,
                  ),

                  Text(
                    'Đang lưu thông tin...',
                    style:
                        TextStyle(
                      color:
                          hintColor,
                      fontSize: 12,
                      fontFamily:
                          'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(
          gradient:
              LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E7),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 24.0,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                // Bỏ qua
                Align(
                  alignment:
                      Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                        (_isLoading ||
                                _isSaving ||
                                _isNavigating)
                            ? null
                            : _skipProfile,
                    child:
                        const Text(
                      'Bỏ qua',
                      style:
                          TextStyle(
                        color:
                            hintColor,
                        fontSize:
                            14,
                        fontFamily:
                            'Inter',
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                // Tiêu đề
                const Text(
                  'Thiết lập hồ sơ',
                  style:
                      TextStyle(
                    color:
                        textColor,
                    fontSize:
                        24,
                    fontFamily:
                        'Inter',
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Cá nhân hóa trải nghiệm FoodLoop của bạn',
                  style:
                      TextStyle(
                    color:
                        hintColor,
                    fontSize:
                        16,
                    fontFamily:
                        'Inter',
                    fontWeight:
                        FontWeight.w700,
                    height: 1.50,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // Nội dung
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(
                            color:
                                primaryColor,
                          ),
                        )
                      : _buildProfileContent(),
                ),

                const SizedBox(
                  height: 16,
                ),

                // Indicator
                Center(
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration:
                            const ShapeDecoration(
                          color:
                              Color(0xFFE5E7EB),
                          shape:
                              OvalBorder(),
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Container(
                        width: 6,
                        height: 6,
                        decoration:
                            const ShapeDecoration(
                          color:
                              primaryColor,
                          shape:
                              OvalBorder(),
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Container(
                        width: 6,
                        height: 6,
                        decoration:
                            const ShapeDecoration(
                          color:
                              Color(0xFFE5E7EB),
                          shape:
                              OvalBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // Nút tiếp tục
                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child:
                      ElevatedButton(
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          primaryColor,
                      disabledBackgroundColor:
                          primaryColor
                              .withValues(
                        alpha: 0.5,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                      ),
                      elevation: 0,
                    ),
                    onPressed:
                        (_isLoading ||
                                _isSaving ||
                                _isNavigating)
                            ? null
                            : _continueToHome,
                    child:
                        _isNavigating
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Tiếp tục',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      16,
                                  fontFamily:
                                      'Inter',
                                  fontWeight:
                                      FontWeight.w600,
                                  height:
                                      1.50,
                                ),
                              ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}