import 'package:flutter/material.dart';

class ChiTietTaiKhoan extends StatelessWidget {
  final String ten;
  final String mssv;
  final String khoa;
  final String email;

  const ChiTietTaiKhoan({
    super.key,
    required this.ten,
    required this.mssv,
    required this.khoa,
    required this.email,
  });

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
          'Chi Tiết Tài Khoản',
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
            // Ảnh đại diện
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/user.png'),
              backgroundColor: Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 15),
            //  Tên và MSSV
            Text(
              ten,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            Text(
              mssv,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Thông tin chi tiết
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.school, "Khoa", khoa),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.email, "Email", email),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo dòng thông tin
  static Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF1F65DE)),
        const SizedBox(width: 10),
        Text(
          "$title: ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 17),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
