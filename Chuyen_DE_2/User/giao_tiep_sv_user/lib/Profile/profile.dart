import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Login_register/dang_nhap.dart';
import 'package:giao_tiep_sv_user/Profile/Widget/avatarWidget.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/edit_profile_screen.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/personal_post_screen.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/saved_items_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dữ liệu profile - có thể cập nhật được
  String _userName = "Phạm Thắng";
  String _avatarUrl =
      "https://i.pinimg.com/736x/d4/38/25/d43825dd483d634e59838d919c3cf393.jpg";
  String _major = "CNTT";
  String _schoolYear = "2023";
  String _address = "115/16, Hồ Văn Tư, Thủ Đức";
  String _phone = "0393413787";
  File? _avatarFile; // Thêm biến để lưu ảnh local

  // Hàm để cập nhật dữ liệu từ EditProfileScreen
  void _updateProfile(
    String newName,
    String newAvatarPath,
    String newAdress,
    String newPhone,
  ) {
    setState(() {
      _userName = newName;
      _address = newAdress;
      _phone = newPhone;

      if (newAvatarPath.startsWith('/')) {
        // Đây là file local
        _avatarFile = File(newAvatarPath);
        _avatarUrl = "";
      } else {
        // Đây là URL network
        _avatarUrl = newAvatarPath;
        _avatarFile = null;
      }
    });
  }

  // Hàm mở liên kết web
  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://tdc.edu.vn/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Không thể mở liên kết $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin avatar + tên
              Row(
                children: [
                  AvatarWidget(
                    avatarUrl: _avatarUrl,
                    avatarFile: _avatarFile,
                    radius: 35,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            "Ngành học: ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            _major,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Niên khóa: ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            _schoolYear,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Thông tin chung
              const Text(
                "Thông tin chung",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.blue),
                title: const Text("Chỉnh sửa thông tin"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                onTap: () async {
                  // Chờ kết quả từ EditProfileScreen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      // lấy đa
                      builder: (context) => EditProfileScreen(
                        onProfileUpdated: _updateProfile,
                        currentName: _userName,
                        currentAvatarUrl: _avatarUrl,
                        currentAddress: _address,
                        currentPhone: _phone,
                        currentAvatarFile: _avatarFile,
                      ),
                    ),
                  );

                  // Nếu có kết quả trả về, cập nhật profile
                  if (result != null && result is Map) {
                    _updateProfile(
                      result['name'] ?? _userName,
                      result['avatarUrl'] ?? _avatarUrl,
                      result['address'] ?? _address,
                      result['phone'] ?? _phone,
                    );
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.article_outlined, color: Colors.blue),
                title: const Text("Bài viết"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalPostScreen(
                        userName: _userName,
                        avatarUrl: _avatarUrl,
                        avatarFile: _avatarFile,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border, color: Colors.blue),
                title: const Text("Mục đã lưu"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedItemsProfileScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              const Text(
                "Liên kết",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.language, color: Colors.blue),
                title: const Text("Website trường TDC"),
                onTap: _launchWebsite, // ✅ mở website khi click
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.blue),
                title: const Text("Đăng xuất"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const DangNhap();
                  }));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
