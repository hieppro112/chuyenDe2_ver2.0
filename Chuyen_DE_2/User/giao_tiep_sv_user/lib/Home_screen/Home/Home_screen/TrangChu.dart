import 'package:flutter/material.dart';
import '../../../FireBase_Service/get_posts.dart';
import 'port_card.dart';
import 'dang_bai_dialog.dart';
import 'left_panel.dart';
import 'group_info_dialog.dart';
import 'search_page.dart';
// Import service lấy nhóm và global state
import '../../../FireBase_Service/get_joined_groups.dart';
import '../../../Data/global_state.dart';

class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  State<TrangChu> createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  final GetPosts _postService = GetPosts();
  final GetJoinedGroupsService _groupService = GetJoinedGroupsService();

  bool _isOpen = false;
  // ✅ currentGroup: Đặt nhóm mặc định là nhóm đầu tiên người dùng thấy
  String currentGroup = "CNTT";

  List<Map<String, dynamic>> allPosts = [];
  List<Map<String, dynamic>> filteredPosts = [];

  // Nơi lưu trữ danh sách nhóm đã tham gia (name)
  List<String> _joinedGroupNames = [];

  void _changeGroup(String newGroup) {
    setState(() {
      currentGroup = newGroup;
      _isOpen = false;
      _filterPosts();
    });
  }

  // Hàm lấy bài viết (giữ nguyên)
  Future<void> _fetchPosts() async {
    final fetchedPosts = await _postService.fetchPosts();

    setState(() {
      allPosts = fetchedPosts;
      _filterPosts();
    });
  }

  // HÀM MỚI: LẤY DANH SÁCH TÊN NHÓM ĐÃ THAM GIA
  Future<void> _fetchJoinedGroupNames() async {
    final userId = GlobalState.currentUserId.isNotEmpty
        ? GlobalState.currentUserId
        : "23211TT4679"; // ID mặc định nếu chưa đăng nhập

    final groups = await _groupService.fetchJoinedGroups(userId);

    // Lọc ra chỉ lấy TÊN nhóm và loại bỏ "Tất cả"
    final names = groups
        .map((g) => g['name'].toString())
        .where((name) => name != "Tất cả")
        .toList();

    setState(() {
      _joinedGroupNames = names;

      // ✅ CẬP NHẬT NHÓM HIỂN THỊ MẶC ĐỊNH LÀ NHÓM ĐẦU TIÊN ĐÃ THAM GIA
      if (names.isNotEmpty) {
        currentGroup = names.first;
      }
      _filterPosts();
    });
  }

  //  HÀM LỌC BÀI VIẾT DỰA TRÊN currentGroup
  void _filterPosts() {
    // ✅ LOẠI BỎ LOGIC LỌC TẤT CẢ (chỉ lọc theo tên nhóm cụ thể)
    if (currentGroup == "Tất cả") {
      // Nếu currentGroup vẫn là "Tất cả" (chưa load được nhóm), hiển thị rỗng hoặc tất cả (tạm thời)
      filteredPosts = allPosts;
    } else {
      filteredPosts = allPosts
          .where((post) => post["group"] == currentGroup)
          .toList();
    }
  }

  void _toggleLike(Map<String, dynamic> post) {
    setState(() {
      post["isLiked"] = !(post["isLiked"] ?? false);
      if (post["isLiked"]) {
        post["likes"] = (post["likes"] ?? 0) + 1;
      } else {
        post["likes"] = (post["likes"] ?? 1) - 1;
        if (post["likes"]! < 0) post["likes"] = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo nhóm trước khi tải bài viết
    _fetchJoinedGroupNames();
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Nút mở menu trái
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            setState(() => _isOpen = !_isOpen);
                          },
                        ),

                        // Ô tìm kiếm
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.search, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    "Tìm kiếm",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Nút đăng bài
                        GestureDetector(
                          onTap: _openDangBaiDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  offset: const Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  "Đăng bài",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Thông tin nhóm
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTaXZWZglx63-gMfBzslxSUQdqqvCp0QJiOA&s",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentGroup,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        //  Chỉ hiện nút info nếu KHÔNG phải "Tất cả"
                        if (currentGroup != "Tất cả")
                          IconButton(
                            icon: const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    GroupInfoDialog(groupName: currentGroup),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Text(
                      "Bảng tin",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // Danh sách bài viết
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPosts.length, // Sử dụng danh sách đã lọc
                    itemBuilder: (context, i) {
                      final post = filteredPosts[i];
                      return PostCard(
                        post: post,
                        onCommentPressed: () => _showCommentSheet(post),
                        onLikePressed: () => _toggleLike(post),
                        onMenuSelected: (value) {
                          debugPrint("Đã chọn: $value");
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          //  Overlay mờ khi mở menu
          if (_isOpen)
            GestureDetector(
              onTap: () => setState(() => _isOpen = false),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          // Panel menu trái
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: _isOpen ? 0 : -260,
            child: LeftPanel(
              onClose: () => setState(() => _isOpen = false),
              // TRUYỀN HÀM CẬP NHẬT NHÓM
              onGroupSelected: _changeGroup,
            ),
          ),
        ],
      ),
    );
  }

  // Mở dialog đăng bài
  void _openDangBaiDialog() async {
    // ✅ TRUYỀN DANH SÁCH NHÓM ĐÃ THAM GIA (KHÔNG BAO GỒM "Tất cả")
    final isSuccess = await showDialog<bool>(
      context: context,
      builder: (_) => DangBaiDialog(availableGroups: _joinedGroupNames),
    );

    if (isSuccess == true) {
      await _fetchPosts();
    }
  }

  // Hàm hiển thị BOTTOM SHEET BÌNH LUẬN MỚI (giữ nguyên)
  void _showCommentSheet(Map<String, dynamic> post) {
    TextEditingController commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final double screenHeight = MediaQuery.of(context).size.height;
            final double sheetHeight = screenHeight * 0.85;
            return Container(
              height: sheetHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // Thanh kéo và Tiêu đề
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Bình luận",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Bài đăng tóm tắt
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        post["avatar"] ?? // Dùng key 'avatar'
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTaXZWZglx63-gMfBzslxSUQdqqvCp0QJiOA&s",
                      ),
                    ),
                    title: Text(
                      post["fullname"] ??
                          post["user"] ??
                          "Ẩn danh", // Dùng key 'fullname'
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      post["title"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Text(
                      "trong ${post["group"]}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const Divider(height: 1),

                  // Danh sách Bình luận
                  Expanded(
                    child: ListView.builder(
                      itemCount: post["comments"].length,
                      itemBuilder: (context, index) {
                        final comment = post["comments"][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 15,
                                backgroundImage: NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTaXZWZglx63-gMfBzslxSUQdqqvCp0QJiOA&s",
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment["name"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        comment["text"],
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Ô nhập liệu Bình luận (luôn ở dưới cùng)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 8,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    ),
                    child: TextField(
                      controller: commentCtrl,
                      decoration: InputDecoration(
                        hintText: "Viết bình luận...",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: () {
                            String val = commentCtrl.text.trim();
                            if (val.isNotEmpty) {
                              // Cập nhật dữ liệu tạm thời
                              setModalState(() {
                                post["comments"].add({
                                  "name": "Cao Quang Khánh",
                                  "text": val,
                                });
                              });
                              //  Cập nhật giao diện trang chủ
                              this.setState(() {});
                              commentCtrl.clear();
                              FocusScope.of(context).unfocus(); // Đóng bàn phím
                            }
                          },
                        ),
                      ),
                      onSubmitted: (val) {},
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
