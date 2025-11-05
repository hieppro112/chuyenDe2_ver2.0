import 'package:flutter/material.dart';
import '../models/User_post_approval_model.dart';

class UserPostApproval extends StatelessWidget {
  final UserPostApprovalModel post;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const UserPostApproval({
    Key? key,
    required this.post,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với tên tác giả và trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        "https://i.pinimg.com/736x/d4/38/25/d43825dd483d634e59838d919c3cf393.jpg",
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      post.authorName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(post.status),
              ],
            ),

            SizedBox(height: 8),
            // Nội dung bài viết
            Text(post.content, style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),

            // Ngày đăng
            Text(
              'Ngày ${_formatDate(post.date)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 8),

            // ảnh duyệt bài
            if (post.image.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.image,
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
              SizedBox(height: 8),
            ],

            // Nút hành động (chỉ hiện khi chờ duyệt)
            if (post.status == 'pending') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton('Duyệt', Colors.green, onApprove),
                  SizedBox(width: 50),
                  _buildActionButton('Từ chối', Colors.red, onReject),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'Đã duyệt';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Từ chối';
        break;
      default:
        color = Colors.orange;
        text = 'Chờ duyệt';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
