import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:giao_tiep_sv_user/FireBase_Service/create_group_service.dart'; // Import service mới
import 'package:giao_tiep_sv_user/Data/global_state.dart'; // Import GlobalState

class TaoNhomPage extends StatefulWidget {
  const TaoNhomPage({super.key});

  @override
  State<TaoNhomPage> createState() => _TaoNhomPageState();
}

class _TaoNhomPageState extends State<TaoNhomPage> {
  // --- Services ---
  final CreateGroupService _groupService = CreateGroupService();

  // --- Controllers và Utils ---
  final TextEditingController _tenNhomController = TextEditingController();
  final TextEditingController _moTaController = TextEditingController();
  File? _anhNhom; // lưu ảnh nhóm
  final ImagePicker _picker = ImagePicker();

  bool _isCreating = false; // Trạng thái loading
  // Giá trị tạm thời (Cần thay thế bằng dữ liệu lấy từ User Profile)
  final String _currentFacultyId = "CNTT";

  // Màu chủ đạo
  static const Color _primaryColor = Color.fromARGB(255, 0, 85, 150); // Teal
  static const Color _backgroundColor = Color(
    0xFFF0F4F8,
  ); // Light Blue-Gray Background

  // --- Functions ---
  Future<void> _chonAnh() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _anhNhom = File(image.path);
      });
    }
  }

  void _taoNhom() async {
    String ten = _tenNhomController.text.trim();
    String moTa = _moTaController.text.trim();

    // 1. Kiểm tra điều kiện đầu vào
    if (ten.isEmpty || moTa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ Tên và Mô tả nhóm! ⚠️"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Kiểm tra ID người dùng đã đăng nhập
    final userId = GlobalState.currentUserId;
    final fullname = GlobalState.currentFullname;

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi: Vui lòng đăng nhập để tạo nhóm."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    // 2. Gọi Service tạo nhóm (bao gồm upload ảnh và tạo document)
    final success = await _groupService.createGroup(
      creatorUserId: userId,
      creatorFullname: fullname,
      name: ten,
      description: moTa,
      groupImage: _anhNhom,
      facultyId: _currentFacultyId,
    );

    setState(() {
      _isCreating = false;
    });

    // 3. Xử lý kết quả
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Nhóm "$ten" đã được tạo thành công!'),
          duration: const Duration(seconds: 2),
          backgroundColor: _primaryColor,
        ),
      );
      // Quay lại màn hình trước
      Navigator.pop(
        context,
        true,
      ); // Trả về true để refresh danh sách nhóm nếu cần
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lỗi: Không thể tạo nhóm. Vui lòng thử lại.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Widgets ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Bo tròn hơn
              borderSide: BorderSide.none, // Bỏ đường viền mặc định
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupImagePicker() {
    return Center(
      child: Column(
        children: [
          const Text(
            "Ảnh nhóm:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _chonAnh,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle, // Thay đổi thành hình tròn
                border: Border.all(
                  color: _primaryColor,
                  width: 3,
                ), // Viền nổi bật
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _anhNhom != null
                  ? ClipOval(child: Image.file(_anhNhom!, fit: BoxFit.cover))
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 40, color: _primaryColor),
                        SizedBox(height: 4),
                        Text(
                          "Chọn ảnh",
                          style: TextStyle(color: _primaryColor),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Vô hiệu hóa nút khi đang tạo
        onPressed: _isCreating ? null : _taoNhom,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor, // Màu chủ đạo
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 5, // Thêm đổ bóng
        ),
        child: _isCreating
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                "TẠO NHÓM",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tạo Nhóm Mới",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupImagePicker(),
              const SizedBox(height: 30),

              _buildTextField(
                controller: _tenNhomController,
                labelText: "Tên nhóm:",
                hintText: "Nhập tên nhóm...",
              ),
              const SizedBox(height: 25),

              _buildTextField(
                controller: _moTaController,
                labelText: "Mô tả nhóm:",
                hintText: "Mô tả ngắn về mục đích của nhóm...",
                maxLines: 4,
              ),
              const SizedBox(height: 50),

              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }
}
