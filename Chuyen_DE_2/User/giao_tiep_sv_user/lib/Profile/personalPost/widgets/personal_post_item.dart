import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Profile/Widget/avatarWidget.dart';
import '../models/personal_post_model.dart';
import '../widgets/comment_section_widget.dart'; // THÊM: import widget bình luận

class PersonalPostItemWidget extends StatefulWidget {
  final PersonalPostModel post;
  final VoidCallback onComment;
  final VoidCallback onLike;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final String avatarUrl;
  final File? avatarFile;
  final String currentUserName; // THÊM: tên user hiện tại cho bình luận

  const PersonalPostItemWidget({
    super.key,
    required this.post,
    required this.onComment,
    required this.onLike,
    required this.onDelete,
    this.onEdit,
    required this.avatarUrl,
    this.avatarFile,
    required this.currentUserName, // THÊM: tham số mới
  });

  @override
  State<PersonalPostItemWidget> createState() => _PersonalPostItemWidgetState();
}

class _PersonalPostItemWidgetState extends State<PersonalPostItemWidget> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc muốn xóa bài viết này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete();
                Navigator.of(context).pop();
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // THÊM: Phương thức hiển thị bottom sheet bình luận
  void _showCommentSheet() {
    // Chuyển đổi PersonalPostModel sang Map để tương thích với widget bình luận
    final postMap = _convertPostToMap(widget.post);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final double screenHeight = MediaQuery.of(context).size.height;
            final double sheetHeight = screenHeight * 0.85;

            return Container(
              height: sheetHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: CommentSectionWidget(
                post: postMap,
                // truyền tên user hiện tại
                currentUserName: widget.currentUserName,
                // truyền avatar
                currentUserAvatar: widget.avatarUrl,
                onCommentSubmitted: (commentText) {
                  // Cập nhật dữ liệu tạm thời
                  setModalState(() {
                    postMap["comments"].add({
                      "name": widget.currentUserName,
                      "text": commentText,
                    });
                  });
                  // Cập nhật số lượng bình luận trong post
                  // setState(() {
                  //   widget.post.commentsCount++;
                  // });
                  // Gọi callback từ parent nếu cần
                  widget.onComment();
                },
              ),
            );
          },
        );
      },
    );
  }

  // bình luận dummy
  Map<String, dynamic> _convertPostToMap(PersonalPostModel post) {
    return {
      "user": post.userName,
      "title": post.title,
      "group": post.groupId,
      "comments": [
        {
          "name": "Nguyễn Văn A",
          "text": "Bài viết rất hay và ý nghĩa!",
          "time": DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          "name": "Trần Thị B",
          "text": "Cảm ơn bạn đã chia sẻ thông tin hữu ích này",
          "time": DateTime.now().subtract(const Duration(hours: 1)),
        },
        {
          "name": "Lê Văn C",
          "text":
              "Mình cũng đang tìm hiểu về vấn đề này, có thể trao đổi thêm không?",
          "time": DateTime.now().subtract(const Duration(minutes: 30)),
        },
      ], // Bạn có thể thêm comments thực tế nếu có
      "avatar": widget.avatarUrl,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với thông tin người đăng và menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AvatarWidget(
                      avatarUrl: widget.avatarUrl,
                      avatarFile: widget.avatarFile,
                      radius: 35,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName ?? "Ẩn danh",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Khoa: ${widget.post.groupId}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatDate(widget.post.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(context);
                      // } else if (value == 'edit' && widget.onEdit != null) {
                      //   widget.onEdit!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (widget.onEdit != null)
                      // const PopupMenuItem(
                      //   value: 'edit',
                      //   child: Row(
                      //     children: [
                      //       Icon(Icons.edit, size: 18),
                      //       SizedBox(width: 8),
                      //       Text('Chỉnh sửa'),
                      //     ],
                      //   ),
                      // ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tiêu đề bài viết
            Text(
              widget.post.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 12),

            // Ảnh minh họa
            if (widget.post.image.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.post.image,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Không thể tải ảnh'),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Thống kê và hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Thống kê
                Row(
                  children: [
                    Text(
                      '${widget.post.likesCount} lượt thích',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${widget.post.commentsCount} bình luận',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                // Nút hành động
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: _showCommentSheet, // SỬA: gọi phương thức mới
                      child: const Text("Bình luận"),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                        widget.onLike();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
