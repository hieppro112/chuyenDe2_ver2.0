import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/Admin/Home.dart';
import 'quen_mk.dart';

class DangNhap extends StatefulWidget {
  const DangNhap({super.key});

  @override
  State<DangNhap> createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _dangNhap(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Kiểm tra rỗng
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    // Kiểm tra domain TDC
    if (!email.endsWith("@mail.tdc.edu.vn")) {
      _showSnackBar("Email phải thuộc TDC!");
      return;
    }

    // MẬT KHẨU MẶC ĐỊNH: 123456
    if (password != "123456") {
      _showSnackBar("Mật khẩu không đúng!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Tìm user theo email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showSnackBar("Tài khoản không tồn tại!");
        return;
      }

      final userData = querySnapshot.docs.first.data();

      // KIỂM TRA ROLE = 1 → ADMIN
      if (userData['role'] == 1) {
        _showSnackBar("Xin chào Admin");

        // Đi đến trang Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
      } else {
        _showSnackBar("Tài khoản không có quyền Admin!");
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Hiển thị thông báo
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains("Xin chào") ? Colors.green : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset('assets/images/logo.png', width: 150),
                  const SizedBox(height: 20),

                  // Tiêu đề
                  const Text(
                    "ĐĂNG NHẬP ADMIN",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Ô Email
                  _buildEmailField(),
                  const SizedBox(height: 20),

                  // Ô Mật khẩu (có gợi ý)
                  _buildPasswordField(),
                  const SizedBox(height: 10),

                  // Quên mật khẩu
                  _buildForgotPassword(context),
                  const SizedBox(height: 20),

                  // Nút đăng nhập
                  _isLoading
                      ? const CircularProgressIndicator()
                      : _buildLoginButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Ô nhập Email
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.email, color: Colors.black),
          hintText: 'Email sinh viên',
          hintStyle: TextStyle(color: Colors.black54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  // Ô nhập Mật khẩu
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.black),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black54,
            ),
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
          hintText: 'Mật khẩu',
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  // Nút quên mật khẩu
  Widget _buildForgotPassword(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuenMatKhau()),
            );
          },
          child: const Text(
            "Quên mật khẩu?",
            style: TextStyle(color: Colors.red, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // Nút Đăng nhập
  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F65DE),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () => _dangNhap(context),
        child: const Text(
          "Đăng nhập",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
