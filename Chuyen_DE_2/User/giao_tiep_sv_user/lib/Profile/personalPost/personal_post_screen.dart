import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/models/personal_post_model.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/widgets/personal_post_item.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/widgets/profile_header_widget.dart';

class PersonalPostScreen extends StatefulWidget {
  final String userName;
  final String avatarUrl;
  final File? avatarFile;
  const PersonalPostScreen({
    super.key,
    this.userName = "Phạm Thắng", // Giá trị mặc định
    this.avatarUrl =
        "https://i.pinimg.com/736x/d4/38/25/d43825dd483d634e59838d919c3cf393.jpg",
    this.avatarFile,
  });

  @override
  State<PersonalPostScreen> createState() => _PersonalPostScreenState();
}

class _PersonalPostScreenState extends State<PersonalPostScreen> {
  // Sử dụng Model thay vì Map
  List<PersonalPostModel> _posts = [];

  @override
  void initState() {
    super.initState();
    _initializePosts(); // THÊM DÒNG NÀY
  }

  void _initializePosts() {
    _posts = [
      PersonalPostModel(
        id: '1',
        name: widget.userName, // Sử dụng tên từ widget
        faculty: "CNTT",
        title: "Em xin tài liệu tiếng anh như này",
        image:
            "https://cdn2.tuoitre.vn/thumb_w/480/471584752817336320/2025/10/8/screenshot20240421at090524-17599639007531328622673.jpeg",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 15,
        commentsCount: 3,
      ),
      PersonalPostModel(
        id: '2',
        name: widget.userName, // Sử dụng tên từ widget
        faculty: "CNTT",
        title: "Cần tuyển thành viên lập trình ứng dụng đi giải cứu thế giới",
        image:
            "https://cdn2.tuoitre.vn/thumb_w/480/471584752817336320/2025/10/8/screenshot20240421at090524-17599639007531328622673.jpeg",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 42,
        commentsCount: 7,
      ),
      PersonalPostModel(
        id: '3',
        name: widget.userName, // Sử dụng tên từ widget
        faculty: "CNTT",
        title: "Cần tuyển thành viên lập trình ứng dụng đi giải cứu thế giới",
        image:
            "https://cdn2.tuoitre.vn/thumb_w/480/471584752817336320/2025/10/8/screenshot20240421at090524-17599639007531328622673.jpeg",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        likesCount: 28,
        commentsCount: 5,
      ),
      PersonalPostModel(
        id: '4',
        name: widget.userName, // Sử dụng tên từ widget
        faculty: "CNTT",
        title: "Cần tuyển thành viên lập trình ứng dụng đi giải cứu thế giới",
        image:
            "https://cdn2.tuoitre.vn/thumb_w/480/471584752817336320/2025/10/8/screenshot20240421at090524-17599639007531328622673.jpeg",
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        likesCount: 36,
        commentsCount: 12,
      ),
    ];
  }

  @override
  void didUpdateWidget(covariant PersonalPostScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật lại posts khi widget thay đổi (tên người dùng thay đổi)
    if (oldWidget.userName != widget.userName) {
      setState(() {
        _initializePosts();
      });
    }
  }

  void _handleLike(int index) {
    setState(() {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _posts[index].isLiked ? "Đã thả tim ❤️" : "Đã bỏ thả tim",
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleComment(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Chuyển đến màn hình bình luận")),
    );
    // TODO: Navigate to comments screen
  }

  void _handleDelete(int index) {
    setState(() {
      _posts.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã xóa bài viết"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleEdit(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Chỉnh sửa bài viết: ${_posts[index].title}")),
    );
    // TODO: Navigate to edit post screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Bài viết"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header thông tin profile
            ProfileHeaderWidget(
              avatarUrl: widget.avatarUrl,
              avatarFile: widget.avatarFile,
              name: widget.userName,
              faculty: "CNTT",
              academicYear: "2023",
              postCount: _posts.length,
            ),

            const SizedBox(height: 16),

            // Tiêu đề phần bài viết
            const Text(
              "Bài viết",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Danh sách bài viết hoặc empty state
            _posts.isEmpty
                ? const Center(
                    child: Text(
                      "Chưa có bài viết nào",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return PersonalPostItemWidget(
                        post: post,
                        onComment: () => _handleComment(index),
                        onLike: () => _handleLike(index),
                        onDelete: () => _handleDelete(index),
                        onEdit: () => _handleEdit(index),
                        avatarUrl: widget.avatarUrl,
                        avatarFile: widget.avatarFile,
                        currentUserName: widget.userName,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
