import 'package:flutter/material.dart';
import '../data/ViolationReport.dart';

class DetailScreen extends StatelessWidget {
  final ViolationReport report;

  const DetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

            // 2. TÊN & ID
            Text(
              report.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            Text(
              report.id,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // 3. THÔNG TIN CÁ NHÂN
            _buildInfoRow('Khoa:', report.department),
            _buildInfoRow('Email:', report.email),
            const SizedBox(height: 20),

            // 4. CHI TIẾT BÁO CÁO (Container màu hồng)
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
                    'Bị báo cáo lúc: ${report.reportTime}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Lý do : ${report.reason}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 5. NÚT HÀNH ĐỘNG
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
                      _showActionDialog(context, 'Cảnh báo', report.name);
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
                      _showActionDialog(context, 'Khóa tài khoản', report.name);
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
