import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/TrangChu.dart';
import 'package:giao_tiep_sv_user/Profile/profile.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/saved_items_profile_screen.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/view/chatMemberScreens.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 1. Khai báo PageController
  late PageController _pageController;
  int _currentIndex = 0;

  // SỬA: Dùng TrangChuState (public)
  final GlobalKey<TrangChuState> _trangChuKey = GlobalKey<TrangChuState>();

  final List<Widget> _pages = [
    const TrangChu(),
    const ChatMemberScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 2. Khởi tạo PageController
    _pageController = PageController(initialPage: _currentIndex);
    // SỬA: Gán key cho TrangChu (vì const không cho phép gán key)
    _pages[0] = TrangChu(key: _trangChuKey);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigate(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300), // Thời gian trượt
      curve: Curves.easeInOut, // Đường cong chuyển động
    );
  }

  // SỬA: Hàm mở SavedItems và cuộn tới bài viết
  Future<void> _openSavedItems() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedItemsProfileScreen()),
    );

    // Kiểm tra result là Map
    if (result is Map<String, String>) {
      final postId = result['postId'];
      final group = result['group'] ?? 'Tất cả';

      if (postId == null) return;

      // 1. Chuyển về Home
      if (_currentIndex != 0) {
        _onNavigate(0);
        await Future.delayed(const Duration(milliseconds: 400));
      }

      // 2. Đổi nhóm (nếu cần)
      final trangChuState = _trangChuKey.currentState;
      if (trangChuState != null && trangChuState.currentGroup != group) {
        trangChuState.changeGroup(group); // Gọi hàm public
        await Future.delayed(
          const Duration(milliseconds: 600),
        ); // Đợi reload + filter
      }

      // 3. Cuộn tới bài
      trangChuState?.scrollToPost(postId);
    }
  }

  Widget _buildAnimatedNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavigate(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6A5AE0), Color(0xFF9B6DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                icon,
                size: 26,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFDFBFB), Color(0xFFEBEDEE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnimatedNavItem(Icons.home_filled, "Home", 0),
              _buildAnimatedNavItem(Icons.chat_bubble_rounded, "Chat", 1),
              _buildAnimatedNavItem(Icons.person_rounded, "Profile", 2),
            ],
          ),
        ),
      ),
    );
  }
}
