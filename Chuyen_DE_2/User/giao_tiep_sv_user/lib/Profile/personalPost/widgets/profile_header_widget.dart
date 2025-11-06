// profile_header_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/Profile_Service.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/models/profile_model.dart';

class ProfileHeaderWidget extends StatefulWidget {
  final String avatarUrl;
  final File? avatarFile;
  final String name;
  final String email; // Cần email để tính niên khóa
  final String facultyId; // Cần faculty_id để lấy tên ngành
  final int postCount;

  const ProfileHeaderWidget({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.email,
    required this.facultyId,
    required this.postCount,
    this.avatarFile,
  });

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  final ProfileService _profileService = ProfileService();
  String _faculty = 'Đang tải...';
  String _academicYear = 'Đang tải...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacultyAndYear();
  }

  Future<void> _loadFacultyAndYear() async {
    try {
      final result = await _profileService.layNganhVaNienKhoa(
        widget.email,
        widget.facultyId,
      );
      if (mounted) {
        setState(() {
          _faculty = result['major'] ?? 'Không xác định';
          _academicYear = result['schoolYear'] ?? 'Không xác định';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _faculty = 'Lỗi tải';
          _academicYear = 'Lỗi tải';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatar() {
    if (widget.avatarFile != null) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: FileImage(widget.avatarFile!),
      );
    } else if (widget.avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(widget.avatarUrl),
      );
    } else {
      return const CircleAvatar(
        radius: 30,
        child: Icon(Icons.person, size: 30),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_isLoading)
                    const SizedBox(
                      height: 16,
                      child: LinearProgressIndicator(minHeight: 2),
                    )
                  else
                    Row(
                      children: [
                        _buildInfoItem("Ngành học: ", _faculty),
                        const SizedBox(width: 20),
                        _buildInfoItem("Niên khóa: ", _academicYear),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.postCount} bài viết",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
