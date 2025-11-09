import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Profile/Widget/avatarWidget.dart';
import '../models/personal_post_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class PersonalPostItemWidget extends StatefulWidget {
  final PersonalPostModel post;
  final void Function(String postId, List<String> imageUrls) onDelete;
  final String avatarUrl;
  final File? avatarFile;
  final String currentUserName;

  const PersonalPostItemWidget({
    super.key,
    required this.post,
    required this.onDelete,
    required this.avatarUrl,
    this.avatarFile,
    required this.currentUserName,
  });

  @override
  State<PersonalPostItemWidget> createState() => _PersonalPostItemWidgetState();
}

class _PersonalPostItemWidgetState extends State<PersonalPostItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  void _showDeleteConfirmation(BuildContext itemContext) {
    print('MỞ DIALOG TỪ ITEM - postId: ${widget.post.id}');

    showDialog(
      context: itemContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        // context này là của dialog
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xóa bài viết'),
          ],
        ),
        content: const Text('Bài viết sẽ bị xóa vĩnh viễn. Bạn có chắc chắn?'),
        actions: [
          TextButton(
            onPressed: () {
              print('DIALOG: NHẤN HỦY');
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              print('DIALOG: NHẤN XÓA → GỌI onDelete');
              widget.onDelete(widget.post.id, widget.post.imageUrls);
              Navigator.pop(dialogContext, true); // Đóng dialog
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
                      radius: 25,
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
                      print('MENU: CHỌN XÓA → MỞ DIALOG');
                      _showDeleteConfirmation(context);
                    }
                  },
                  itemBuilder: (context) => [
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
            if (widget.post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              // 1 ảnh: full width và >2 ảnh: cuộn ngang
              widget.post.imageUrls.length == 1
                  ? _buildSingleImage(widget.post.imageUrls[0])
                  : _buildMultipleImages(widget.post.imageUrls),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 1 ảnh: full width, bo góc, chiều cao cố định
  Widget _buildSingleImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        memCacheWidth: 1000,
        memCacheHeight: 1000,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 240,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.error_outline, color: Colors.red, size: 40),
          ),
        ),
      ),
    );
  }

  // Nhiều ảnh: cuộn ngang
  Widget _buildMultipleImages(List<String> urls) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        itemBuilder: (context, index) {
          final url = urls[index];
          return Padding(
            padding: EdgeInsets.only(right: index < urls.length - 1 ? 8 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: url,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                memCacheHeight: 600,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
