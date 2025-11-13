import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/wiget/comment_sheet_content.dart';
import '../../../FireBase_Service/get_posts.dart';
import 'port_card.dart';
import 'dang_bai_dialog.dart';
import 'left_panel.dart';
import 'group_info_dialog.dart';
import 'search_page.dart';
import '../../../FireBase_Service/get_joined_groups.dart';
import '../../../Data/global_state.dart';
import '../../../FireBase_Service/post_interaction_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  State<TrangChu> createState() => TrangChuState();
}

class TrangChuState extends State<TrangChu> {
  // Khởi tạo User ID và Fullname
  final String _currentUserId = GlobalState.currentUserId.isNotEmpty
      ? GlobalState.currentUserId
      : "23211TT4679";
  final String _currentFullname = GlobalState.currentFullname.isNotEmpty
      ? GlobalState.currentFullname
      : "Người dùng ẩn danh";

  final GetPosts _postService;
  final GetJoinedGroupsService _groupService = GetJoinedGroupsService();
  final PostInteractionService _interactionService = PostInteractionService(
    userId: GlobalState.currentUserId.isNotEmpty
        ? GlobalState.currentUserId
        : "23211TT4679",
    userFullname: GlobalState.currentFullname.isNotEmpty
        ? GlobalState.currentFullname
        : "Người dùng ẩn danh",
  );

  bool _isOpen = false;
  String currentGroupId = "ALL";
  String currentGroupName = "Tất cả";

  List<Map<String, dynamic>> allPosts = [];
  List<Map<String, dynamic>> filteredPosts = [];
  List<Map<String, dynamic>> _joinedGroupsData = [];

  // Constructor khởi tạo _postService
  TrangChuState()
    : _postService = GetPosts(
        currentUserId: GlobalState.currentUserId.isNotEmpty
            ? GlobalState.currentUserId
            : "23211TT4679",
      );

  // ---------------- FETCH DATA ----------------

  Future<void> _fetchPosts() async {
    final fetchedPosts = await _postService.fetchPosts();
    if (mounted) {
      setState(() {
        allPosts = fetchedPosts;
        _filterPosts();
      });
    }
  }

  Future<void> _fetchJoinedGroupNames() async {
    final userId = GlobalState.currentUserId.isNotEmpty
        ? GlobalState.currentUserId
        : "23211TT4679";

    final groups = await _groupService.fetchJoinedGroups(userId);

    if(mounted){
      setState(() {
      // 	Lưu DATA NHÓM ĐẦY ĐỦ (bao gồm "Tất cả" với id:"ALL")

      _joinedGroupsData = groups;
      if (currentGroupId == "ALL" && groups.length > 1) {
        final defaultGroup = groups[1];
        currentGroupId = defaultGroup["id"] as String;
        currentGroupName = defaultGroup["name"] as String;
      }
      _filterPosts();
    });
  
    }
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

  void _changeGroup(String newGroupId, String newGroupName) {
    setState(() {
      currentGroupId = newGroupId;
      currentGroupName = newGroupName;
      _isOpen = false;
      _filterPosts();
    });
  }

  void _toggleLike(Map<String, dynamic> post) async {
    final bool currentlyLiked = post["isLiked"] ?? false;
    final String postId = post["id"] as String;

    setState(() {
      post["isLiked"] = !currentlyLiked;
      post["likes"] = (post["likes"] ?? 0) + (currentlyLiked ? -1 : 1);
      if (post["likes"]! < 0) post["likes"] = 0;
    });

    try {
      final success = await _interactionService.toggleLike(
        postId,
        currentlyLiked,
      );
      if (!success) throw Exception("Cập nhật Firestore thất bại.");
    } catch (e) {
      print("Lỗi tương tác Like: $e");
      if (mounted) {
        setState(() {
          post["isLiked"] = currentlyLiked;
          post["likes"] = (post["likes"] ?? 0) + (currentlyLiked ? 1 : -1);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi cập nhật lượt thích!')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchJoinedGroupNames();
    _fetchPosts();
  }

  // ---------------- HÀM HỖ TRỢ ----------------

  String _getGroupNameFromId(String groupId) {
    if (groupId == "ALL") return "Tất cả";
    final groupData = _joinedGroupsData.firstWhere(
      (group) => group['id'] == groupId,
      orElse: () => {"name": "Không rõ"},
    );
    return groupData['name'] ?? "Không rõ";
  }

  String _getCurrentGroupAvatar() {
    final currentGroupData = _joinedGroupsData.firstWhere(
      (group) => group['id'] == currentGroupId,
      orElse: () => {"avatar_url": null},
    );
    return currentGroupData['avatar_url'] ??
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTq0u-w59YWMH2YXama4Hu6dNpdzg8Ra2ZfjQ&s";
  }

  String get currentGroup => currentGroupName;

  void changeGroup(String groupName) {
    final group = _joinedGroupsData.firstWhere(
      (g) => g['name'] == groupName,
      orElse: () => {"id": "ALL", "name": "Tất cả"},
    );
    _changeGroup(group["id"] as String, group["name"] as String);
  }

  void scrollToPost(String postId) {
    // Logic cuộn tới bài viết
  }

  // ---------------- BUILD ----------------
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
                  // Thanh trên
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => setState(() => _isOpen = !_isOpen),
                        ),
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
                                Icon(Icons.edit, color: Colors.white, size: 20),
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
          if (_isOpen)
            GestureDetector(
              onTap: () => setState(() => _isOpen = false),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: _isOpen ? 0 : -260,
            child: LeftPanel(
              onClose: () => setState(() => _isOpen = false),
              onGroupSelected: _changeGroup,
            ),
          ),
        ],
      ),
    );
  }

  void _openDangBaiDialog() async {
    final isSuccess = await showDialog<bool>(
      context: context,
      builder: (_) => DangBaiDialog(availableGroupsData: _joinedGroupsData),
    );

    if (isSuccess == true) {
      await _fetchPosts();
    }
  }

  void _showCommentSheet(Map<String, dynamic> post) {
    final String postId = post["id"] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return CommentSheetContent(
          postId: postId,
          post: post,
          interactionService: _interactionService,
          getGroupNameFromId: _getGroupNameFromId,
          onCommentsCountUpdate: (count) {
            setState(() {
              post["comments"] = count;
            });
          },
        );
      },
    );
  }
}
