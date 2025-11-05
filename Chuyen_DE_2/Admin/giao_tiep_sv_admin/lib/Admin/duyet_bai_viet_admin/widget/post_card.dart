import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Admin/duyet_bai_viet_admin/model/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PostCard({
    Key? key,
    required this.post,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
        border: Border.all(color: _getStatusColor(post.status), width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // thong tin bai viet
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.blue[800], size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Nhóm: ${post.faculty.name_faculty}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(post.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(post.status)),
                  ),
                  child: Text(
                    _getStatusText(post.status),
                    style: TextStyle(
                      color: _getStatusColor(post.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),
            // tieu de bai viet
            Text(
              post.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: 8),
            // Post Image (nếu có)
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              _buildPostImage(),
              SizedBox(height: 8),
            ],

            // Post Content Preview
            Text(
              post.content.length > 100
                  ? '${post.content.substring(0, 100)}...'
                  : post.content,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),

            SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.check_circle,
                  label: 'Duyệt',
                  color: Colors.green,
                  onTap: onApprove,
                  isEnabled: post.status == PostStatus.pending,
                ),
                _buildActionButton(
                  icon: Icons.cancel,
                  label: 'Từ chối',
                  color: Colors.red,
                  onTap: onReject,
                  isEnabled: post.status == PostStatus.pending,
                ),
              ],
            ),

            SizedBox(height: 8),

            // Post Date
            Text(
              'Đăng ngày: ${_formatDate(post.createdAt)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          post.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 50,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Không thể tải ảnh',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isEnabled
                  ? color.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.rectangle,
              border: Border.all(color: isEnabled ? color : Colors.grey),
            ),
            child: Icon(icon, color: isEnabled ? color : Colors.grey, size: 24),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isEnabled ? color : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PostStatus status) {
    switch (status) {
      case PostStatus.pending:
        return Colors.orange;
      case PostStatus.approved:
        return Colors.green;
      case PostStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(PostStatus status) {
    switch (status) {
      case PostStatus.pending:
        return 'Chờ duyệt';
      case PostStatus.approved:
        return 'Đã duyệt';
      case PostStatus.rejected:
        return 'Từ chối';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
