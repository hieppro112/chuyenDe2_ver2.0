import 'package:flutter/material.dart';
import 'dang_nhap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DangKi extends StatefulWidget {
  const DangKi({super.key});

  @override
  State<DangKi> createState() => _DangKiState();
}

class _DangKiState extends State<DangKi> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? tenNganh;
  String? maNganh;

  void _kiemTraEmail() async {
    String email = emailController.text.trim();

    final RegExp pattern = RegExp(
      r'^[0-9]{5}([A-Za-z]{2})[0-9]{4}@mail\.tdc\.edu\.vn$',
      caseSensitive: false,
    );

    final match = pattern.firstMatch(email);
    if (match != null) {
      String ma = match.group(1)!.toUpperCase();
      setState(() {
        maNganh = ma;
        tenNganh = "Đang kiểm tra...";
      });

      try {
        final query = await FirebaseFirestore.instance
            .collection("Faculty")
            .where("id", isEqualTo: ma)
            .get();

        setState(() {
          tenNganh = query.docs.isNotEmpty
              ? query.docs.first['name']
              : "Không tìm thấy mã ngành";
        });
      } catch (e) {
        setState(() => tenNganh = "Lỗi kết nối");
      }
    } else {
      setState(() {
        maNganh = null;
        tenNganh = null;
      });
    }
  }

  Future<void> _dangKy(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();
    final name = nameController.text.trim();

    // Kiểm tra rỗng
    if (email.isEmpty || password.isEmpty || confirm.isEmpty || name.isEmpty) {
      _showSnackBar(context, "Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    if (password != confirm) {
      _showSnackBar(context, "Mật khẩu không khớp!");
      return;
    }

    // LẤY id_user
    final id_user = email.split('@').first.toUpperCase();

    // Kiểm tra định dạng email + mã ngành
    final RegExp pattern = RegExp(
      r'^[0-9]{5}([A-Za-z]{2})[0-9]{4}@mail\.tdc\.edu\.vn$',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(email);
    if (match == null) {
      _showSnackBar(context, "Email sai định dạng!");
      return;
    }

    final ma = match.group(1)!.toUpperCase();

    // Kiểm tra mã ngành
    final query = await FirebaseFirestore.instance
        .collection("Faculty")
        .where("id", isEqualTo: ma)
        .get();

    if (query.docs.isEmpty) {
      _showSnackBar(context, "Mã ngành $ma không tồn tại!", isError: true);
      return;
    }

    final nganh = query.docs.first['name'];

    try {
      // Tạo tài khoản Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance.collection("Users").doc(id_user).set({
        "email": email,
        "fullname": name,
        "phone": "",
        "address": "",
        "avt":
            "https://www.homepaylater.vn/static/091138555b138c04878fa60cea715e28/7b48c/tdc_computer_logo_68b779e149.jpg", // ảnh mặc định
        "role": 1,
        "faculty_id": ma,
      });

      // Đăng nhập ngay
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showSnackBar(context, "Đăng ký thành công!", isError: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DangNhap()),
      );
    } on FirebaseAuthException catch (e) {
      _showSnackBar(
        context,
        "Đăng ký thất bại! Tài khoản đã tồn tại.",
        isError: true,
      );
    } catch (e) {
      _showSnackBar(context, "Lỗi kết nối. Vui lòng thử lại!", isError: true);
    }
  }

  // Hiển thị thông báo
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
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
                  Image.asset('assets/images/logo.png', width: 150),
                  const SizedBox(height: 20),
                  const Text(
                    "TẠO TÀI KHOẢN",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 31),
                  _buildEmailField(),
                  if (tenNganh != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      tenNganh!,
                      style: TextStyle(
                        color:
                            tenNganh!.contains("Không") ||
                                tenNganh!.contains("Lỗi")
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildNameField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 15),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 20),
                  _buildRegisterButton(context),
                  const SizedBox(height: 20),
                  _buildLoginLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() => _textField(
    emailController,
    Icons.email,
    'Email sinh viên',
    onChanged: (_) => _kiemTraEmail(),
  );
  Widget _buildNameField() =>
      _textField(nameController, Icons.person, 'Họ và tên');
  Widget _buildPasswordField() => _textField(
    passwordController,
    Icons.lock,
    'Mật khẩu',
    obscure: true,
    isPassword: true,
  );
  Widget _buildConfirmPasswordField() => _textField(
    confirmController,
    Icons.lock_outline,
    'Xác nhận mật khẩu',
    obscure: true,
    isConfirm: true,
  );

  Widget _textField(
    TextEditingController controller,
    IconData icon,
    String hint, {
    Function(String)? onChanged,
    bool obscure = false,
    bool isPassword = false,
    bool isConfirm = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscure
            ? (isPassword ? _obscurePassword : _obscureConfirm)
            : false,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          suffixIcon: (isPassword || isConfirm)
              ? IconButton(
                  icon: Icon(
                    (isPassword ? _obscurePassword : _obscureConfirm)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: () => setState(() {
                    if (isPassword) _obscurePassword = !_obscurePassword;
                    if (isConfirm) _obscureConfirm = !_obscureConfirm;
                  }),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F65DE),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () => _dangKy(context),
        child: const Text(
          "Đăng ký",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Bạn đã có tài khoản? ",
          style: TextStyle(color: Colors.black),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DangNhap()),
          ),
          child: const Text(
            "Đăng nhập",
            style: TextStyle(
              color: Color(0xFF1F65DE),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
