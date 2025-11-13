import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/data/violation_report.dart';

class DetailScreen extends StatelessWidget {
  final ViolationReport report;

  const DetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
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
            // 1. AVATAR
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(report.avatarUrl),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 15),

            // 2. TÊN (Title) & ID người nhận
            Text(
              report.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 30),

            _buildInfoRow('Khoa:', report.department),

            const SizedBox(height: 20),

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
                    'Document ID: ${report.docId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    // Hiển thị Lý do (content)
                    'Lý do : ${report.content}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // Nút Cảnh báo
                Expanded(
                  child: _buildActionButton(
                    text: 'Cảnh báo',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.amber,
                    onPressed: () {
                      _showActionDialog(context, 'Cảnh báo', report.title);
                    },
                  ),
                ),
                const SizedBox(width: 15),
                // Nút Khóa tài khoản
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

  // Hàm tiện ích tạo hàng thông tin
  Widget _buildInfoRow(String title, String value) {
    // ... (Giữ nguyên)
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

  // Hàm tiện ích tạo nút hành động
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    // ... (Giữ nguyên)
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

  // Hàm tiện ích hiển thị Dialog xác nhận
  void _showActionDialog(BuildContext context, String action, String userName) {
    // ... (Giữ nguyên)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$action người dùng'),
          content: Text(
            'Bạn có chắc chắn muốn $action tài khoản $userName không?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                action,
                style: TextStyle(
                  color: action == 'Khóa tài khoản' ? Colors.red : Colors.amber,
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã thực hiện hành động "$action" với $userName',
                    ),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
