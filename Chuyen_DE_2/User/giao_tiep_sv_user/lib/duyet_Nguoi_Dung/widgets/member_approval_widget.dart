import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/MemberApprovalModel.dart';

class MemberApprovalWidget extends StatelessWidget {
  final MemberApprovalModel user;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const MemberApprovalWidget({
    Key? key,
    required this.user,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(user.avatar_member),
                    ),
                    const SizedBox(width: 10),
                    // Tên người dùng
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(user.reviewStatus),
              ],
            ),

            SizedBox(height: 8),

            // Actions (chỉ hiện khi chờ duyệt)
            if (user.reviewStatus == 'pending') ...[
              Row(
                children: [
                  _buildActionButton('Duyệt', Colors.green, onApprove),
                  SizedBox(width: 8),
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
}
