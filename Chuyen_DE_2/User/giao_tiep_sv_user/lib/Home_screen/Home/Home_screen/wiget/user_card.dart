import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onTap;

  const UserCard({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            user["avatar"] ?? "https://default-avatar-url.jpg",
          ),
        ),
        title: Text(
          user["fullname"] ?? "Ẩn danh",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          user["email"] ?? user["faculty_id"] ?? "Không rõ thông tin",
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
