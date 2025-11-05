import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Admin/duyet_bai_viet_admin/model/post_model.dart';
import 'package:giao_tiep_sv_admin/Admin/duyet_bai_viet_admin/widget/post_card.dart';
import 'package:giao_tiep_sv_admin/Data/faculty.dart';

class AdminPostManagementScreen extends StatefulWidget {
  @override
  _AdminPostManagementScreenState createState() =>
      _AdminPostManagementScreenState();
}

class _AdminPostManagementScreenState extends State<AdminPostManagementScreen> {
  // Danh sách các khoa từ Firebase
  List<Faculty> facultys = [];
  StreamSubscription<QuerySnapshot>? _facultySubscription;
  List<Post> posts = [
    Post(
      id: '1',
      author: 'Cao Quang Khanh',
      faculty: Faculty(id: 'KT', name_faculty: 'Kế toán'),
      title: 'Ngày đầu tiên đi học tại TDC',
      content:
          'Hôm nay là ngày đầu tiên tôi đi học tại trường TDC. Mọi thứ thật mới mẻ và thú vị...',
      imageUrl:
          'https://static.chotot.com/storage/chotot-kinhnghiem/nha/2024/10/3f900290-cong-nghe-thu-duc.jpeg',
      status: PostStatus.pending,
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    Post(
      id: '2',
      author: 'Lê Đình Thuận',
      faculty: Faculty(id: 'TT', name_faculty: 'Công nghệ thông tin'),
      title: 'Tìm người đi xem phim chung',
      content: ' Tôi đã gặp nhiều bạn bè mới...',
      imageUrl:
          'https://sm.pcmag.com/t/pcmag_au/help/h/how-to-wat/how-to-watch-dragon-ball-z-and-the-entire-franchise-in-order_xs33.1920.jpg',
      status: PostStatus.pending,
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
    Post(
      id: '3',
      author: 'Lê Đại Hiệp',
      faculty: Faculty(id: 'OT', name_faculty: 'Otô1'),
      title: 'Trải nghiệm học tập tại TDC',
      content: 'Môi trường học tập tại TDC rất chuyên nghiệp và thân thiện...',
      imageUrl:
          'https://nghenghiepcuocsong.vn/wp-content/uploads/2024/06/11.jpg',
      status: PostStatus.pending,
      createdAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    Post(
      id: '4',
      author: 'Phạm Thắng ',
      faculty: Faculty(id: 'DT', name_faculty: 'Điện - Điện tử'),
      title: 'Hoạt động ngoại khóa tại TDC',
      content: 'Các hoạt động ngoại khóa tại trường rất đa dạng và bổ ích...',
      imageUrl:
          'https://topxephang.com/wp-content/uploads/2017/11/truong-cao-dang-cong-nghe-thu-duc.png',
      status: PostStatus.pending,
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadFaculty();
  }

  void _loadFaculty() {
    _facultySubscription = FirebaseFirestore.instance
        .collection('Faculty')
        .orderBy('name')
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) {
            // Cập nhật danh sách khoa mỗi khi có thay đổi
            facultys = snapshot.docs.map((doc) {
              return Faculty(
                id: doc.id,
                name_faculty: doc['name'] ?? 'Không xác định',
              );
            }).toList();
          },
          onError: (error) {
            print('Lỗi lấy dữ liệu khoa: $error');
          },
        );
  }

  @override
  void dispose() {
    _facultySubscription?.cancel();
    super.dispose();
  }

  // Hàm chuyển đổi string sang PostStatus
  PostStatus _parsePostStatus(String status) {
    switch (status) {
      case 'approved':
        return PostStatus.approved;
      case 'rejected':
        return PostStatus.rejected;
      case 'pending':
      default:
        return PostStatus.pending;
    }
  }

  // Biến quản lý bộ lọc theo tên của khoa
  PostFilterType _currentFilter = PostFilterType.all;
  String? _currentFacultyFilter;

  void _approvePost(int index) {
    setState(() {
      posts[index].status = PostStatus.approved;
    });
    _showSnackBar('Đã duyệt bài viết của ${posts[index].author}');
  }

  void _rejectPost(int index) {
    setState(() {
      posts[index].status = PostStatus.rejected;
    });
    _showSnackBar('Đã từ chối bài viết của ${posts[index].author}');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  // Lấy danh sách tên khoa cho dropdown
  List<String> get uniqueFaculties {
    final facultyNames = facultys.map((f) => f.name_faculty).toList()..sort();
    return ['Tất cả khoa', ...facultyNames];
  }

  // Lọc bài viết
  List<Post> get filteredPosts {
    List<Post> result = posts;

    // Lọc theo trạng thái
    switch (_currentFilter) {
      case PostFilterType.pending:
        result = result
            .where((post) => post.status == PostStatus.pending)
            .toList();
        break;
      case PostFilterType.approved:
        result = result
            .where((post) => post.status == PostStatus.approved)
            .toList();
        break;
      case PostFilterType.rejected:
        result = result
            .where((post) => post.status == PostStatus.rejected)
            .toList();
        break;
      case PostFilterType.all:
        break;
    }

    // Lọc theo nhóm theo tên khoa
    if (_currentFacultyFilter != null &&
        _currentFacultyFilter != 'Tất cả khoa') {
      result = result
          .where((post) => post.faculty.name_faculty == _currentFacultyFilter)
          .toList();
    }

    return result;
  }

  int get pendingPostsCount =>
      posts.where((post) => post.status == PostStatus.pending).length;
  int get approvedPostsCount =>
      posts.where((post) => post.status == PostStatus.approved).length;
  int get rejectedPostsCount =>
      posts.where((post) => post.status == PostStatus.rejected).length;

  @override
  Widget build(BuildContext context) {
    final safeFacultyValue = uniqueFaculties.contains(_currentFacultyFilter)
        ? _currentFacultyFilter
        : 'Tất cả khoa';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Duyệt bài viết',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header và Dropdown cùng hàng
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Hai dropdown
                Row(
                  children: [
                    // Dropdown trạng thái
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<PostFilterType>(
                          value: PostFilterType.values.contains(_currentFilter)
                              ? _currentFilter
                              : PostFilterType.all,
                          onChanged: (PostFilterType? newValue) {
                            setState(() => _currentFilter = newValue!);
                          },
                          isExpanded: true,
                          underline: SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: PostFilterType.all,
                              child: Text('Tất cả (${posts.length})'),
                            ),
                            DropdownMenuItem(
                              value: PostFilterType.pending,
                              child: Text('Chờ duyệt ($pendingPostsCount)'),
                            ),
                            DropdownMenuItem(
                              value: PostFilterType.approved,
                              child: Text('Đã duyệt ($approvedPostsCount)'),
                            ),
                            DropdownMenuItem(
                              value: PostFilterType.rejected,
                              child: Text('Từ chối ($rejectedPostsCount)'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Dropdown khoa
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: safeFacultyValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              _currentFacultyFilter = newValue == 'Tất cả khoa'
                                  ? null
                                  : newValue;
                            });
                          },
                          isExpanded: true,
                          underline: SizedBox(),
                          items: uniqueFaculties.map((String faculty) {
                            return DropdownMenuItem<String>(
                              value: faculty,
                              child: Text(faculty),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // hien thi ket qua
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Có ${filteredPosts.length} bài viết phù hợp',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Danh sách bài viết
          Expanded(
            child: filteredPosts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      final originalIndex = posts.indexWhere(
                        (p) => p.id == post.id,
                      );
                      return PostCard(
                        post: post,
                        onApprove: () => _approvePost(originalIndex),
                        onReject: () => _rejectPost(originalIndex),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.article_outlined, size: 64, color: Colors.grey[300]),
        SizedBox(height: 16),
        Text(
          _getEmptyStateMessage(),
          style: TextStyle(color: Colors.grey[500], fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  String _getEmptyStateMessage() {
    switch (_currentFilter) {
      case PostFilterType.pending:
        return 'Không có bài viết nào đang chờ duyệt';
      case PostFilterType.approved:
        return 'Không có bài viết nào đã được duyệt';
      case PostFilterType.rejected:
        return 'Không có bài viết nào bị từ chối';
      case PostFilterType.all:
        return 'Không có bài viết nào';
    }
  }
}

// Enum cho các loại bộ lọc
enum PostFilterType { all, pending, approved, rejected }
