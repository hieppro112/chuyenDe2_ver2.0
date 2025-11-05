import 'dart:io';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/models/profile_model.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/widgets/confirm_button_widget.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/widgets/profile_text_field_widget.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Function(String, String, String, String)? onProfileUpdated;
  final String currentName; // THÊM: nhận tên hiện tại
  final String currentAvatarUrl; // THÊM: nhận avatar hiện tại
  final String currentAddress; // THÊM: nhận địa chỉ hiện tại
  final String currentPhone; // THÊM: nhận số điện thoại hiện tại
  final File? currentAvatarFile; // THÊM: nhận file avatar hiện tại

  const EditProfileScreen({
    super.key,
    this.onProfileUpdated,
    required this.currentName,
    required this.currentAvatarUrl,
    required this.currentAddress,
    required this.currentPhone,
    this.currentAvatarFile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Sử dụng Model để quản lý dữ liệu - KHỞI TẠO VỚI DỮ LIỆU HIỆN TẠI
  late ProfileModel _profile;

  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  static const Color _primaryColor = Color.fromARGB(255, 0, 85, 150);

  // Biến để kiểm tra có thay đổi dữ liệu không
  bool _hasChanges = false;

  // Controllers để liên kết với TextField
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // KHỞI TẠO PROFILE VỚI DỮ LIỆU TỪ WIDGET
    _profile = ProfileModel(
      name: widget.currentName,
      email:
          "23211TT1718@mail.tdc.edu.vn", // Giữ nguyên vì không chỉnh sửa được
      address: widget.currentAddress,
      phone: widget.currentPhone,
      avatarUrl: widget.currentAvatarUrl,
    );

    // KHỞI TẠO AVATAR IMAGE TỪ WIDGET
    _avatarImage = widget.currentAvatarFile;

    // Khởi tạo controllers với dữ liệu từ widget (dữ liệu hiện tại)
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: _profile.email);
    _addressController = TextEditingController(text: widget.currentAddress);
    _phoneController = TextEditingController(text: widget.currentPhone);

    // Lắng nghe sự thay đổi trong text fields
    _nameController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasTextChanges =
        _nameController.text !=
            widget.currentName || // SO SÁNH VỚI DỮ LIỆU BAN ĐẦU
        _addressController.text != widget.currentAddress ||
        _phoneController.text != widget.currentPhone;

    final hasImageChanges =
        _avatarImage != widget.currentAvatarFile; // SO SÁNH VỚI FILE BAN ĐẦU

    setState(() {
      _hasChanges = hasTextChanges || hasImageChanges;
    });
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi không dùng nữa
    _nameController.removeListener(_checkForChanges);
    _addressController.removeListener(_checkForChanges);
    _phoneController.removeListener(_checkForChanges);
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSaveProfile() {
    final full_name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    // Kiểm tra nếu không có thay đổi
    if (!_hasChanges) {
      _showInfoSnackBar('Không có thay đổi nào để lưu!');
      return;
    }
    // Kiểm tra trường tên
    //--------------------------------------------------------------------------
    if (full_name.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập họ và tên!');
      return;
    } else if (full_name.length < 8) {
      _showErrorSnackBar('Họ và tên phải có ít nhất 8 ký tự!');
      return;
    } else if (full_name.length > 50) {
      _showErrorSnackBar('Họ và tên không được vượt quá 50 ký tự!');
      return;
    }
    // Kiểm tra trường địa chỉ
    //--------------------------------------------------------------------------
    if (address.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập địa chỉ!');
      return;
    } else if (address.length < 20) {
      _showErrorSnackBar('Địa chỉ phải có ít nhất 20 ký tự!');
      return;
    } else if (address.length > 70) {
      _showErrorSnackBar('Địa chỉ không được vượt quá 70 ký tự!');
      return;
    }
    // Kiểm tra trường số điện thoại
    //--------------------------------------------------------------------------
    if (phone.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập số điện thoại!');
      return;
    }
    if (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showErrorSnackBar('Số điện thoại phải có đúng 10 chữ số!');
      return;
    }

    // Cập nhật dữ liệu từ controllers vào model
    final updatedProfile = _profile.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      address: _addressController.text,
      phone: phone,
    );

    // TODO: Lưu dữ liệu vào database/API
    if (_avatarImage != null) {
      print('Có ảnh đại diện mới cần upload: ${_avatarImage!.path}');
    }

    print('Profile saved: $updatedProfile');

    // Gọi callback để cập nhật ProfileScreen
    if (widget.onProfileUpdated != null) {
      widget.onProfileUpdated!(
        _nameController.text,
        _avatarImage?.path ?? _profile.avatarUrl,
        _addressController.text,
        _phoneController.text,
      );
    }

    _showSuccessSnackBar('Cập nhật thông tin thành công! ✅');

    // Trả về kết quả cho ProfileScreen
    Navigator.pop(context, {
      'name': _nameController.text,
      'avatarUrl': _avatarImage != null
          ? _avatarImage!.path
          : _profile.avatarUrl,
      'hasNewImage': _avatarImage != null, // Thêm flag để biết có ảnh mới
      'address': _addressController.text,
      'phone': _phoneController.text,
    });
  }

  Future<void> _handleChangeAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
          // Đánh dấu có thay đổi
          _hasChanges = true;
        });
        //print('Đã chọn ảnh đại diện mới: ${image.path}');
        _showSuccessSnackBar('Đã thay đổi ảnh đại diện! 📷');
      }
    } catch (e) {
      print('Lỗi khi chọn ảnh: $e');
      _showErrorSnackBar('Lỗi khi chọn ảnh: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          height: 60, // chỉnh chiều cao tùy ý
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16, // chỉnh kích thước chữ
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 1),
    );
  }

  void _showSuccessSnackBar(String message) {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 1),
    );
  }

  void _showInfoSnackBar(String message) {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          height: 60, // 👈 chỉnh chiều cao tùy ý
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16, // chỉnh kích thước chữ
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 1),
    );
  }

  Widget _buildDefaultAvatar() {
    return Stack(
      children: [
        ClipOval(
          child: Image.network(
            _profile.avatarUrl,
            fit: BoxFit.cover,
            width: 130,
            height: 130,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 60, color: Colors.grey),
              );
            },
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa thông tin",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar widget với thiết kế mới
              GestureDetector(
                onTap: _handleChangeAvatar,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _hasChanges ? Colors.orange : _primaryColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _avatarImage != null
                      ? ClipOval(
                          child: Image.file(
                            _avatarImage!,
                            fit: BoxFit.cover,
                            width: 130,
                            height: 130,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              const SizedBox(height: 10),
              if (_hasChanges)
                Text(
                  'Có thay đổi chưa lưu',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 30),

              // Các trường thông tin
              ProfileTextFieldWidget(
                controller: _nameController,
                labelText: "Họ và tên",
                icon: Icons.person_outline,
              ),

              ProfileTextFieldWidget(
                controller: _emailController,
                labelText: "Email",
                icon: Icons.email_outlined,
                isReadOnly: true,
              ),

              ProfileTextFieldWidget(
                controller: _addressController,
                labelText: "Địa chỉ",
                icon: Icons.location_on_outlined,
              ),

              ProfileTextFieldWidget(
                controller: _phoneController,
                labelText: "Số điện thoại",
                icon: Icons.call,
              ),

              const SizedBox(height: 40),
              // Nút xác nhận
              ConfirmButtonWidget(
                onPressed: _handleSaveProfile,
                isActive: _hasChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
