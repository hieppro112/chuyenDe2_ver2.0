import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/Profile_Service.dart';
import 'dang_ki.dart';
import 'quen_mk.dart';
import 'package:giao_tiep_sv_user/Home_screen/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Data/global_state.dart';

class DangNhap extends StatefulWidget {
  const DangNhap({super.key});

  @override
  State<DangNhap> createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // TỰ ĐỘNG ĐIỀN KHI DEBUG (dành cho test)
    // if (kDebugMode) {
    //   _emailController.text = "23211TT9999@mail.tdc.edu.vn"; // User mẫu
    //   _passwordController.text = "123456";
    // }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ĐĂNG NHẬP CHỈ DÀNH CHO USER (role = 0)
  void _dangNhap(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showOverlayMessage(context, "Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    if (!email.endsWith("@mail.tdc.edu.vn")) {
      _showOverlayMessage(context, "Email phải thuộc TDC!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("BẮT ĐẦU ĐĂNG NHẬP USER: $email");

      // 1. ĐĂNG NHẬP FIREBASE AUTH
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = credential.user;
      if (user == null) {
        _showOverlayMessage(context, "Không lấy được thông tin người dùng!");
        setState(() => _isLoading = false);
        return;
      }

      // 2. LẤY ID TỪ EMAIL
      final id_user = email
          .split('@')
          .first
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z0-9]'), '');

      // 3. LẤY DỮ LIỆU TỪ FIRESTORE
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(id_user)
          .get();

      if (!doc.exists) {
        _showOverlayMessage(context, "Tài khoản chưa đăng ký trên hệ thống!");
        setState(() => _isLoading = false);
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      String name = data['fullname'] ?? "Người dùng";
      int role = data['role'] ?? 0;

      print("THÔNG TIN USER: $name, Role: $role");

      // KIỂM TRA ROLE: CHỈ CHO PHÉP role = 0
      if (role == 1) {
        _showOverlayMessage(
          context,
          "Tài khoản Admin không được dùng app này!\nVui lòng dùng app Admin riêng.",
          isError: true,
        );
        await FirebaseAuth.instance.signOut(); // Đăng xuất ngay
        setState(() => _isLoading = false);
        return;
      }

      if (role != 0) {
        _showOverlayMessage(context, "Loại tài khoản không hợp lệ!");
        await FirebaseAuth.instance.signOut();
        setState(() => _isLoading = false);
        return;
      }

      // 4. LƯU THÔNG TIN TOÀN CỤC
      _profileService.setUserId(id_user);
      GlobalState.currentUserId = id_user;
      GlobalState.currentFullname = name;

      _showOverlayMessage(context, "Xin chào $name!", isError: false);

      // 5. CHUYỂN SANG TRANG CHỦ
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } on FirebaseAuthException catch (e) {
      print("LỖI AUTH: ${e.code}");
      String msg = "Sai email hoặc mật khẩu!";
      if (e.code == 'user-not-found') msg = "Email chưa đăng ký!";
      if (e.code == 'wrong-password') msg = "Mật khẩu sai!";
      if (e.code == 'too-many-requests') msg = "Thử lại sau vài phút!";
      if (e.code == 'network-request-failed') msg = "Lỗi mạng! Kiểm tra kết nối";

      _showOverlayMessage(context, msg);
    } on FirebaseException catch (e) {
      print("LỖI FIRESTORE: ${e.code}");
      _showOverlayMessage(context, "Lỗi kết nối dữ liệu!");
    } catch (e) {
      print("LỖI KHÁC: $e");
      _showOverlayMessage(context, "Đã có lỗi xảy ra!");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // HIỂN THỊ THÔNG BÁO TRÊN MÀN HÌNH
  void _showOverlayMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: 40,
        right: 40,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade600 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3)).then((_) => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Container(
            color: Colors.white,
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
                        "ĐĂNG NHẬP",
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
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 10),
                      _buildForgotPassword(context),
                      const SizedBox(height: 10),
                      _buildLoginButton(context),
                      const SizedBox(height: 20),
                      _buildRegisterLink(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),
          ),
      ],
    );
  }

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
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          hintText: 'Mật khẩu',
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QuenMatKhau()),
          ),
          child: const Text("Quên mật khẩu?", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F65DE),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: () => _dangNhap(context),
        child: const Text(
          "Đăng nhập",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Bạn chưa có tài khoản? ", style: TextStyle(color: Colors.black)),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DangKi()),
          ),
          child: const Text(
            "Đăng ký ngay",
            style: TextStyle(color: Color(0xFF1F65DE), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}