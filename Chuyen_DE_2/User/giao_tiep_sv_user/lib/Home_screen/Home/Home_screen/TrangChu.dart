import 'package:flutter/material.dart';
import '../../../FireBase_Service/get_posts.dart';
import 'port_card.dart';
import 'dang_bai_dialog.dart';
import 'left_panel.dart';
import 'group_info_dialog.dart';
import 'search_page.dart';
import '../../../FireBase_Service/get_joined_groups.dart';
import '../../../Data/global_state.dart';

class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  State<TrangChu> createState() => TrangChuState();
}

class TrangChuState extends State<TrangChu> {
  final GetPosts _postService = GetPosts();
  final GetJoinedGroupsService _groupService = GetJoinedGroupsService();

  bool _isOpen = false;
  String currentGroupId = "ALL";
  String currentGroupName = "Tất cả";

  List<Map<String, dynamic>> allPosts = [];
  List<Map<String, dynamic>> filteredPosts = [];

  List<Map<String, dynamic>> _joinedGroupsData = [];

  //Hàm chuyển nhóm nhận vào cả ID và Name
  void _changeGroup(String newGroupId, String newGroupName) {
    setState(() {
      currentGroupId = newGroupId; // Cập nhật ID nhóm
      currentGroupName = newGroupName; // Cập nhật Tên nhóm
      _isOpen = false;
      _filterPosts();
    });
  }

  Future<void> _fetchPosts() async {
    final fetchedPosts = await _postService.fetchPosts();

    if (mounted) {
      setState(() {
        allPosts = fetchedPosts;
        _filterPosts();
      });
    }
  }

  // LẤY DANH SÁCH DATA NHÓM (ID, Name, Avatar)
  Future<void> _fetchJoinedGroupNames() async {
    final userId = GlobalState.currentUserId.isNotEmpty
        ? GlobalState.currentUserId
        : "23211TT4679";

    final groups = await _groupService.fetchJoinedGroups(userId);

    setState(() {
      // 	Lưu DATA NHÓM ĐẦY ĐỦ (bao gồm "Tất cả" với id:"ALL")
      _joinedGroupsData = groups;
      // CẬP NHẬT NHÓM HIỂN THỊ MẶC ĐỊNH
      // Nếu chưa chọn nhóm nào (mặc định là "ALL") và danh sách có nhóm khác "Tất cả"
      if (currentGroupId == "ALL" && groups.length > 1) {
        final defaultGroup = groups[1]; // Nhóm đầu tiên sau "Tất cả"
        currentGroupId = defaultGroup["id"] as String;
        currentGroupName = defaultGroup["name"] as String;
      }
      _filterPosts();
    });
  }

  void _filterPosts() {
    if (currentGroupId == "ALL") {
      filteredPosts = allPosts.map((post) {
        return {
          ...post,
          "group_name":
              _joinedGroupsData.firstWhere(
                (g) => g['id'] == post['group_id'],
                orElse: () => {"name": "Không rõ"},
              )['name'] ??
              "Không rõ",
        };
      }).toList();
    } else {
      filteredPosts = allPosts
          .where((post) => post["group_id"] == currentGroupId)
          .map((post) {
            return {
              ...post,
              "group_name":
                  _joinedGroupsData.firstWhere(
                    (g) => g['id'] == post['group_id'],
                    orElse: () => {"name": "Không rõ"},
                  )['name'] ??
                  "Không rõ",
            };
          })
          .toList();
    }
  }

  // ĐÃ XÓA: Hàm savePostOnce(String postId)

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
    _fetchJoinedGroupNames();
    _fetchPosts();
  }

  // Hàm tra cứu URL Avatar của nhóm đang hiển thị (Sử dụng currentGroupId)
  String _getCurrentGroupAvatar() {
    final currentGroupData = _joinedGroupsData.firstWhere(
      (group) => group['id'] == currentGroupId, // ✅ Tra cứu bằng ID
      orElse: () => {"avatar_url": null},
    );
    // URL mặc định
    return currentGroupData['avatar_url'] ??
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTaXZWZglx63-gMfBzslxSUQdqqvCp0QJiOA&s";
  }

  // Hàm tra cứu tên nhóm từ ID (dùng cho Comment Sheet)
  String _getGroupNameFromId(String groupId) {
    if (groupId == "ALL") return "Tất cả";
    final groupData = _joinedGroupsData.firstWhere(
      (group) => group['id'] == groupId,
      orElse: () => {"name": "Không rõ"},
    );
    return groupData['name'] ?? "Không rõ";
  }

  // ĐÃ XÓA: Map _postKeys và String _highlightPostId

  // THÊM: Các hàm public để Home.dart có thể gọi nếu cần
  String get currentGroup => currentGroupName;

  void changeGroup(String groupName) {
    final group = _joinedGroupsData.firstWhere(
      (g) => g['name'] == groupName,
      orElse: () => {"id": "ALL", "name": "Tất cả"},
    );
    _changeGroup(group["id"] as String, group["name"] as String);
  }

  void scrollToPost(String postId) {
    // ĐÃ XÓA: Logic cuộn tới bài viết
  }

  @override
  Widget build(BuildContext context) {
    final groupAvatarUrl = _getCurrentGroupAvatar();

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
                              horizontal: 18,
                              vertical: 12,
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
                                  color: Colors.blue.withOpacity(0.5),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ), // Icon to hơn
                                SizedBox(width: 8),
                                Text(
                                  "Đăng Bài",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Thông tin nhóm (AVATAR NHÓM HIỂN THỊ Ở ĐÂY)
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
                            // SỬ DỤNG AVATAR CỦA NHÓM ĐANG HIỂN THỊ (tra cứu bằng ID)
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(groupAvatarUrl),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentGroupName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        // Chỉ hiện nút info nếu KHÔNG phải "Tất cả"
                        if (currentGroupId != "ALL")
                          IconButton(
                            icon: const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => GroupInfoDialog(
                                  groupName: currentGroupName,
                                ),
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
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, i) {
                      final post = filteredPosts[i];

                      return PostCard(
                        post: post,
                        onCommentPressed: () => _showCommentSheet(post),
                        onLikePressed: () => _toggleLike(post),
                        onMenuSelected: (value) {},
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Overlay mờ khi mở menu
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
    final isSuccess = await showDialog<bool>(
      context: context,
      builder: (_) => DangBaiDialog(availableGroupsData: _joinedGroupsData),
    );

    if (isSuccess == true) {
      await _fetchPosts();
    }
  }

  // Hàm hiển thị BOTTOM SHEET BÌNH LUẬN MỚI
  void _showCommentSheet(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              child: Column(
                children: [
                  // Bài đăng tóm tắt
                  ListTile(
                    subtitle: Text(
                      post["title"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Text(
                      // ✅ SỬA: Tra cứu tên nhóm dựa trên group_id
                      "trong ${_getGroupNameFromId(post["group_id"])}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  // THIẾU: Logic hiện Comments và trường nhập Comment (giả sử nằm ở dưới)
                ],
              ),
            );
          },
        );
      },
    );
  }
}
