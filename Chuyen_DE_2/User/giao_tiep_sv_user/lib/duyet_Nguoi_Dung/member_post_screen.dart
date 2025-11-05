import 'package:flutter/material.dart';
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
  String _memberFilter = 'Tất cả';

  // Dummy data
  final List<UserPostApprovalModel> _posts = [
    UserPostApprovalModel(
      id: '1',
      authorName: 'Cao Quang Khánh',
      content: 'Ngày đầu tiên đi học tại TDĐ',
      image:
          'https://occ-0-8407-2218.1.nflxso.net/dnm/api/v6/E8vDc_W8CLv7-yMQu8KMEC7Rrr8/AAAABZTsOmV9hdevbqR_nArY3CdINQlYz00L4zdYonWDx-zpqdajGBO5KLt6kazmy6DyFzDjQwp-GyaHQ-sWHOD0qc2ePVBZh47cPAdw.jpg',
      date: DateTime.now(),
      status: 'pending',
      reviewType: 'post',
    ),
    UserPostApprovalModel(
      id: '2',
      authorName: 'Cao Quang Khanh',
      content: 'Nội dung bài viết khác',
      image:
          'https://cafefcdn.com/203337114487263232/2025/1/21/1722591443-conan-2-7381-width645height387-17373707771021179015512-1737424828485-1737424828574151073796.jpg',
      date: DateTime.now(),
      status: 'pending',
      reviewType: 'post',
    ),
    UserPostApprovalModel(
      id: '3',
      authorName: 'Nguyễn Văn A',
      content: 'Bài viết đã được duyệt',
      image:
          'https://cafefcdn.com/203337114487263232/2025/1/21/1722591443-conan-2-7381-width645height387-17373707771021179015512-1737424828485-1737424828574151073796.jpg',
      date: DateTime.now(),
      status: 'approved',
      reviewType: 'post',
    ),
  ];

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

  // Lọc bài viết theo trạng thái
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

  // Lọc thành viên theo trạng thái
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

  // widget lọc bài viết
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
                  elevation: 2,
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
                  items: filterOptions.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
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

                    return DropdownMenuItem<String>(
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

  Widget _buildPostsList() {
    if (_filteredPosts.isEmpty) {
      return Center(child: Text('Không có bài viết nào'));
    }

    return ListView.builder(
      itemCount: _filteredPosts.length,
      itemBuilder: (context, index) {
        final post = _filteredPosts[index];
        return UserPostApproval(
          post: post,
          onApprove: () => _duyetBaiViet(post),
          onReject: () => _tuChoiBaiviet(post),
        );
      },
    );
  }

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

  void _duyetBaiViet(UserPostApprovalModel post) {
    _showConfirmationDialog(
      title: 'Duyệt bài viết',
      content: 'Bạn có chắc muốn duyệt bài viết này?',
      onConfirm: () {
        setState(() {
          // CÁCH 2: Tìm và cập nhật trực tiếp
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _posts[index].status = 'approved';
          }
        });
        _showSnackBar('Đã duyệt bài viết của ${post.authorName}');
      },
    );
  }

  void _tuChoiBaiviet(UserPostApprovalModel post) {
    _showConfirmationDialog(
      title: 'Từ chối bài viết',
      content: 'Bạn có chắc muốn từ chối bài viết này?',
      onConfirm: () {
        setState(() {
          // CÁCH 2: Tìm và cập nhật trực tiếp
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _posts[index].status = 'rejected';
          }
        });
        _showSnackBar('Đã từ chối bài viết của ${post.authorName}');
      },
    );
  }

  void _duyetThanhVien(MemberApprovalModel user) {
    _showConfirmationDialog(
      title: 'Duyệt thành viên',
      content: 'Bạn có chắc muốn duyệt thành viên này?',
      onConfirm: () {
        setState(() {
          // CÁCH 2: Tìm và cập nhật trực tiếp
          final index = _users.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            _users[index].reviewStatus = 'approved';
          }
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
          // Tìm và cập nhật trực tiếp
          final index = _users.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            _users[index].reviewStatus = 'rejected';
          }
        });
        _showSnackBar('Đã từ chối thành viên ${user.fullName}');
      },
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text('Xác nhận', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
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
          // Tabs
          Tabs_Member_Approval_Widget(
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
          ),
          // Bộ lọc
          _buildFilterSection(),
          // Content
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
