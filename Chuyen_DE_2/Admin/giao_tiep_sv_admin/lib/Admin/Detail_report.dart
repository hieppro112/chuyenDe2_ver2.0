import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/FirebaseFirestore/admin_action_service.dart';
import 'package:giao_tiep_sv_admin/data/violation_report.dart';
import 'duyet_nhom_admin/widget/post_card.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  final ViolationReport report;
  final AdminActionService _service = AdminActionService();

  DetailScreen({super.key, required this.report});

  // Chuyển đổi Timestamp sang chuỗi format
  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
    return 'Không rõ thời gian';
  }

  // ------- Lấy dữ liệu bài viết -------
  Future<Map<String, dynamic>?> _fetchPostDetails() async {
    if (report.postId == null || report.postId!.isEmpty) return null;
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('Post')
          .doc(report.postId!)
          .get();

      if (postDoc.exists) return postDoc.data();
    } catch (e) {
      print('Lỗi tải bài viết: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String recipientId = report.recipientId ?? '232xxxxxxx';
    final String senderId = report.senderId ?? 'Không rõ';
    final String reportedUserName =
        report.recipientId ?? 'Người dùng bị báo cáo';
    final String createdAt = _formatDate(report.createdAt);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi Tiết',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 1. Avatar
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(report.avatarUrl),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 15),

            // 2. Info người bị báo cáo
            Text(
              reportedUserName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              recipientId,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            _buildInfoRow('Người gửi:', senderId),

            const SizedBox(height: 20),

            // 3. Khung thông tin báo cáo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bị báo cáo lúc: $createdAt',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Title : ${report.title}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Lý do : ${report.content}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  _buildViolatingPostWidget(context),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 4. Nút hành động
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildActionButton(
                    text: 'Cảnh báo',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.amber,
                    onPressed: () {
                      _showActionDialog(
                        context,
                        'Cảnh báo',
                        report.title,
                        recipientId: recipientId,
                        reportDocId: report.docId,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionButton(
                    text: 'Khóa tài khoản',
                    icon: Icons.close,
                    color: Colors.red.shade400,
                    onPressed: () {
                      _showActionDialog(
                        context,
                        'Khóa tài khoản',
                        report.title,
                        recipientId: recipientId,
                        reportDocId: report.docId,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------- Widget hiển thị bài viết -------
  Widget _buildViolatingPostWidget(BuildContext context) {
    if (report.postId == null || report.postId!.isEmpty) {
      return const Text(
        "Không có ID bài viết vi phạm.",
        style: TextStyle(color: Colors.grey),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchPostDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Không thể tải bài viết (ID: ${report.postId})');
        }

        final postData = snapshot.data!;
        dynamic fileData = postData['file_url'];

        List<Map<String, String>> filesList = [];
        if (fileData is List) {
          filesList = fileData
              .map((item) => Map<String, String>.from(item))
              .toList();
        } else if (fileData is String && fileData.isNotEmpty) {
          filesList = [
            {'name': 'Tệp đính kèm', 'path': fileData},
          ];
        }

        final adaptedPostData = {
          'id': report.postId,
          'title': postData['content'],
          'content': postData['content'],
          'images': postData['image_urls'] is List
              ? postData['image_urls']
              : (postData['image_urls'] is String
                    ? [postData['image_urls']]
                    : []),
          'files': filesList,
          'date': postData['date_created']?.toString(),
          'user_id': postData['user_id'],
          'group_id': postData['group_id'],
          'fullname': 'Người đăng bài',
          'avatar':
              'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg',
          'group_name': 'Không rõ nhóm',
          'likes': postData['likes'] ?? 0,
          'comments': postData['comments'] ?? 0,
          'isLiked': false,
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 20, thickness: 1, color: Colors.black26),
            const Text(
              "Bài viết bị báo cáo:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            PostCard(
              post: adaptedPostData,
              onCommentPressed: () {},
              onLikePressed: () {},
              onMenuSelected: (value) {},
            ),

            _buildInfoRow('ID Bài viết:', report.postId!),
          ],
        );
      },
    );
  }

  // ------- UI tiện ích -------
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
    );
  }

  // ------- Dialog xử lý hành động -------
  void _showActionDialog(
    BuildContext context,
    String action,
    String userName, {
    String? recipientId,
    String? reportDocId,
  }) {
    final AdminActionService service = AdminActionService();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('$action người dùng'),
          content: Text(
            'Bạn có chắc chắn muốn $action tài khoản $userName không?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(
                action,
                style: TextStyle(
                  color: action == 'Khóa tài khoản' ? Colors.red : Colors.amber,
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                bool success = false;
                String message = 'Đã thực hiện hành động.';

                if (action == 'Cảnh báo' &&
                    recipientId != null &&
                    reportDocId != null) {
                  success = await service.sendWarningAndMarkResolved(
                    context,
                    recipientId,
                    reportDocId,
                  );
                  message = success
                      ? '✅ Đã gửi cảnh báo và đánh dấu báo cáo.'
                      : '❌ Lỗi khi gửi cảnh báo.';
                } else if (action == 'Khóa tài khoản' && recipientId != null) {
                  success = await service.lockUserAccount(
                    recipientId,
                    reportDocId ?? '',
                  );
                  message = success
                      ? '✅ Đã khóa tài khoản thành công.'
                      : '❌ Lỗi khi khóa tài khoản.';

                  if (success && reportDocId != null) {
                    await service.sendWarningAndMarkResolved(
                      context,
                      recipientId,
                      reportDocId,
                    );
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
