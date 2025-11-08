// profile_header_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String avatarUrl;
  final File? avatarFile;
  final String name;
  final String major; // ← Truyền từ ngoài vào
  final String schoolYear; // ← Truyền từ ngoài vào
  final int postCount;

  const ProfileHeaderWidget({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.major,
    required this.schoolYear,
    required this.postCount,
    this.avatarFile,
  });

  Widget _buildAvatar() {
    if (avatarFile != null) {
      return CircleAvatar(radius: 35, backgroundImage: FileImage(avatarFile!));
    } else if (avatarUrl.isNotEmpty) {
      return CircleAvatar(radius: 30, backgroundImage: NetworkImage(avatarUrl));
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
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "• $postCount bài viết",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  _buildInfoItem("Ngành học: ", major),
                  const SizedBox(height: 4),
                  _buildInfoItem("Niên khóa: ", schoolYear),
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
