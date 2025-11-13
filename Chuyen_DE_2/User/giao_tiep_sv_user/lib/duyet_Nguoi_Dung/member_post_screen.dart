import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/PostApprovalService.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/MemberApprovalModel.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/User_post_approval_model.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/widgets/member_approval_widget.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/widgets/tabs_member_post_widget.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/widgets/user_post_approval_widget.dart';

class MemberPostScreen extends StatefulWidget {
  const MemberPostScreen({Key? key}) : super(key: key);

  @override
  _MemberPostScreenState createState() => _MemberPostScreenState();
}

class _MemberPostScreenState extends State<MemberPostScreen> {
  int _selectedTabIndex = 0;
  String _postFilter = 'Tất cả';
  String _memberFilter = 'Tất cả'; // Thêm biến này

  final PostApprovalService _approvalService = PostApprovalService();

  // Phân trang
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;

  List<UserPostApprovalModel> _posts = [];

  // === DUMMY DATA CHO THÀNH VIÊN (GIỮ NGUYÊN) ===
  final List<MemberApprovalModel> _users = [
    MemberApprovalModel(
      id: '1',
      fullName: 'Cao Quang Khánh',
      avatar_member:
          "https://jbagy.me/wp-content/uploads/2025/03/Hinh-anh-avatar-dragon-ball-super-cool-ngau-5.jpg",
      reviewStatus: 'pending',
      reviewType: 'user',
    ),
    MemberApprovalModel(
      id: '2',
      fullName: 'Phạm Thắng',
      avatar_member:
          "https://i.pinimg.com/736x/d4/38/25/d43825dd483d634e59838d919c3cf393.jpg",
      reviewStatus: 'pending',
      reviewType: 'user',
    ),
    MemberApprovalModel(
      id: '3',
      fullName: 'Lê Đình Thuận',
      avatar_member:
          "https://i.pinimg.com/736x/9a/92/88/9a9288733b745cf4563ecdbe0e3ddb1e.jpg",
      reviewStatus: 'approved',
      reviewType: 'user',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts(); // Chỉ load bài viết từ Firebase
  }

  // === LOAD BÀI VIẾT TỪ FIREBASE ===
  Future<void> _loadPosts({bool isRefresh = false}) async {
    if (_isLoading || (!_hasMore && !isRefresh)) return;

    setState(() => _isLoading = true);

    try {
      final snapshot = await _approvalService
          .getPendingPosts(
            limit: _limit,
            startAfter: isRefresh ? null : _lastDocument,
          )
          .first;

      final newPosts = <UserPostApprovalModel>[];
      for (var doc in snapshot.docs) {
        final post = await _approvalService.docToPostModel(doc);
        newPosts.add(post);
      }

      if (isRefresh) _posts.clear();

      setState(() {
        _posts.addAll(newPosts);
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMore = snapshot.docs.length == _limit;
      });
    } catch (e) {
      print("Lỗi load bài viết: $e");
      _showSnackBar("Lỗi tải dữ liệu");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // === LỌC BÀI VIẾT ===
  List<UserPostApprovalModel> get _filteredPosts {
    if (_postFilter == 'Tất cả') return _posts;
    return _posts.where((post) {
      switch (_postFilter) {
        case 'Chờ duyệt':
          return post.status == 'pending';
        case 'Đã duyệt':
          return post.status == 'approved';
        case 'Từ chối':
          return post.status == 'rejected';
        default:
          return true;
      }
    }).toList();
  }

  // === LỌC THÀNH VIÊN (DUMMY) ===
  List<MemberApprovalModel> get _filteredUsers {
    if (_memberFilter == 'Tất cả') return _users;
    return _users.where((user) {
      switch (_memberFilter) {
        case 'Chờ duyệt':
          return user.reviewStatus == 'pending';
        case 'Đã duyệt':
          return user.reviewStatus == 'approved';
        case 'Từ chối':
          return user.reviewStatus == 'rejected';
        default:
          return true;
      }
    }).toList();
  }

  // === BỘ LỌC ===
  Widget _buildFilterSection() {
    final currentFilter = _selectedTabIndex == 0 ? _postFilter : _memberFilter;
    final filterOptions = ['Tất cả', 'Chờ duyệt', 'Đã duyệt', 'Từ chối'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 20, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            'Lọc theo:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentFilter,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  dropdownColor: Colors.white,
                  onChanged: (String? newValue) {
                    setState(() {
                      if (_selectedTabIndex == 0) {
                        _postFilter = newValue!;
                      } else {
                        _memberFilter = newValue!;
                      }
                    });
                  },
                  items: filterOptions.map((value) {
                    IconData icon;
                    Color color;
                    switch (value) {
                      case 'Chờ duyệt':
                        icon = Icons.access_time;
                        color = Colors.orange;
                        break;
                      case 'Đã duyệt':
                        icon = Icons.check_circle;
                        color = Colors.green;
                        break;
                      case 'Từ chối':
                        icon = Icons.cancel;
                        color = Colors.red;
                        break;
                      default:
                        icon = Icons.all_inclusive_rounded;
                        color = Colors.blue;
                    }
                    return DropdownMenuItem(
                      value: value,
                      child: Row(
                        children: [
                          Icon(icon, size: 18, color: color),
                          SizedBox(width: 8),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === DANH SÁCH BÀI VIẾT ===
  Widget _buildPostsList() {
    if (_posts.isEmpty && !_isLoading) {
      return Center(child: Text('Không có bài viết chờ duyệt'));
    }

    return RefreshIndicator(
      onRefresh: () => _loadPosts(isRefresh: true),
      child: ListView.builder(
        itemCount: _filteredPosts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredPosts.length) {
            _loadPosts();
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final post = _filteredPosts[index];
          return UserPostApproval(
            post: post,
            onApprove: () => _approvePost(post),
            onReject: () => _rejectPost(post),
          );
        },
      ),
    );
  }

  // === DANH SÁCH THÀNH VIÊN (DUMMY) ===
  Widget _buildMemberList() {
    if (_filteredUsers.isEmpty) {
      return Center(child: Text('Không có thành viên nào'));
    }

    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return MemberApprovalWidget(
          user: user,
          onApprove: () => _duyetThanhVien(user),
          onReject: () => _tuChoiThanhvien(user),
        );
      },
    );
  }

  // === DUYỆT BÀI VIẾT (CẬP NHẬT FIRESTORE) ===
  Future<void> _approvePost(UserPostApprovalModel post) async {
    final confirm = await _showConfirm(
      'Duyệt bài viết',
      'Bạn có chắc muốn duyệt?',
    );
    if (!confirm) return;

    try {
      await _approvalService.approvePost(post.id);
      setState(() {
        _posts.removeWhere((p) => p.id == post.id);
      });
      _showSnackBar('Đã duyệt bài viết');
    } catch (e) {
      _showSnackBar('Lỗi duyệt bài viết');
    }
  }

  // === TỪ CHỐI BÀI VIẾT ===
  Future<void> _rejectPost(UserPostApprovalModel post) async {
    final confirm = await _showConfirm(
      'Từ chối bài viết',
      'Bạn có chắc muốn từ chối?',
    );
    if (!confirm) return;

    try {
      await _approvalService.rejectPost(post.id);
      setState(() {
        _posts.removeWhere((p) => p.id == post.id);
      });
      _showSnackBar('Đã từ chối bài viết');
    } catch (e) {
      _showSnackBar('Lỗi từ chối bài viết');
    }
  }

  // === DUYỆT/TỪ CHỐI THÀNH VIÊN (DUMMY - GIỮ NGUYÊN) ===
  void _duyetThanhVien(MemberApprovalModel user) {
    _showConfirmationDialog(
      title: 'Duyệt thành viên',
      content: 'Bạn có chắc muốn duyệt thành viên này?',
      onConfirm: () {
        setState(() {
          final index = _users.indexWhere((u) => u.id == user.id);
          if (index != -1) _users[index].reviewStatus = 'approved';
        });
        _showSnackBar('Đã duyệt thành viên ${user.fullName}');
      },
    );
  }

  void _tuChoiThanhvien(MemberApprovalModel user) {
    _showConfirmationDialog(
      title: 'Từ chối thành viên',
      content: 'Bạn có chắc muốn từ chối thành viên này?',
      onConfirm: () {
        setState(() {
          final index = _users.indexWhere((u) => u.id == user.id);
          if (index != -1) _users[index].reviewStatus = 'rejected';
        });
        _showSnackBar('Đã từ chối thành viên ${user.fullName}');
      },
    );
  }

  // === DIALOG XÁC NHẬN ===
  Future<bool> _showConfirm(String title, String content) async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Xác nhận', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text('Xác nhận', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Duyệt'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Tabs_Member_Approval_Widget(
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) => setState(() => _selectedTabIndex = index),
          ),
          _buildFilterSection(),
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildPostsList()
                : _buildMemberList(),
          ),
        ],
      ),
    );
  }
}
