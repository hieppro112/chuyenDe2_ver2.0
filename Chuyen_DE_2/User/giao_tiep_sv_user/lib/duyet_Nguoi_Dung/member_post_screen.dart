// member_post_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/GroupMemberApprovalService.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/PostApprovalService.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/MemberApprovalModel.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/User_post_approval_model.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/widgets/member_approval_widget.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/widgets/tabs_member_post_widget.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/widgets/user_post_approval_widget.dart';

class MemberPostScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  const MemberPostScreen({
    Key? key,
    required this.groupId,
    this.groupName = "Duyệt",
  }) : super(key: key);

  @override
  _MemberPostScreenState createState() => _MemberPostScreenState();
}

class _MemberPostScreenState extends State<MemberPostScreen> {
  int _selectedTabIndex = 0;

  String _postFilter = 'Chờ duyệt';
  String _memberFilter = 'Chờ duyệt';

  final PostApprovalService _approvalService = PostApprovalService();
  final MemberApprovalService _memberService = MemberApprovalService();

  StreamSubscription<QuerySnapshot>? _memberStreamSubscription;
  StreamSubscription<QuerySnapshot>? _postStreamSubscription;

  final int _postLimit = 20;
  final int _memberLimit = 100;

  DocumentSnapshot? _lastPostDocument;
  DocumentSnapshot? _lastMemberDocument;
  bool _isLoadingPosts = false;
  bool _isLoadingMembers = false;
  bool _hasMorePosts = true;
  bool _hasMoreMembers = true;

  List<UserPostApprovalModel> _posts = [];
  List<MemberApprovalModel> _members = [];

  @override
  void initState() {
    super.initState();
    _loadPosts(isRefresh: true);
    _loadMembers(isRefresh: true);
  }

  @override
  void dispose() {
    _memberStreamSubscription?.cancel();
    _postStreamSubscription?.cancel();
    super.dispose();
  }

  // [SỬA - 15/11/2025 02:30] Dùng getMembersByStatus, hỗ trợ filter
  void _loadMembers({bool isRefresh = false}) {
    _memberStreamSubscription?.cancel();

    if (isRefresh || _members.isEmpty) {
      setState(() => _isLoadingMembers = true);
    }

    int statusId = -1;
    switch (_memberFilter) {
      case 'Chờ duyệt':
        statusId = 0;
        break;
      case 'Đã duyệt':
        statusId = 1;
        break;
      case 'Từ chối':
        statusId = 2;
        break;
    }

    _memberStreamSubscription = _memberService
        .getMembersByStatus(
          groupId: widget.groupId,
          limit: _memberLimit,
          startAfter: isRefresh ? null : _lastMemberDocument,
          statusId: statusId,
        )
        .listen(
          (snapshot) async {
            final List<MemberApprovalModel> updatedMembers = [];
            for (var doc in snapshot.docs) {
              final member = await _memberService.docToMemberModel(doc);
              updatedMembers.add(member);
            }

            if (!mounted) return;

            setState(() {
              if (isRefresh) {
                _members = updatedMembers;
              } else {
                final existingIds = _members.map((m) => m.id).toSet();
                final filtered = updatedMembers.where(
                  (m) => !existingIds.contains(m.id),
                );
                _members.addAll(filtered);
              }

              _lastMemberDocument = snapshot.docs.isNotEmpty
                  ? snapshot.docs.last
                  : null;
              _hasMoreMembers = snapshot.docs.length == _memberLimit;
              _isLoadingMembers = false;
            });
          },
          onError: (e) {
            if (mounted) {
              setState(() => _isLoadingMembers = false);
              _showSnackBar("Lỗi tải thành viên: $e");
            }
          },
        );
  }

  Future<void> _loadPosts({bool isRefresh = false}) async {
    _postStreamSubscription?.cancel();

    if (isRefresh) {
      _lastPostDocument = null;
      _hasMorePosts = true;
      _posts.clear();
    }

    int statusId = -1;
    switch (_postFilter) {
      case 'Chờ duyệt':
        statusId = 0;
        break;
      case 'Đã duyệt':
        statusId = 1;
        break;
      case 'Từ chối':
        statusId = 2;
        break;
    }

    _postStreamSubscription = _approvalService
        .getPostsByStatus(
          limit: _postLimit,
          startAfter: _lastPostDocument,
          statusId: statusId,
        )
        .listen((snapshot) async {
          if (!mounted) return;

          final newPosts = await _approvalService.docsToPostModels(
            snapshot.docs,
          );

          setState(() {
            if (isRefresh || _lastPostDocument == null) {
              _posts = newPosts;
            } else {
              final existingIds = _posts.map((p) => p.id).toSet();
              final filtered = newPosts.where(
                (p) => !existingIds.contains(p.id),
              );
              _posts.addAll(filtered);
            }

            _lastPostDocument = snapshot.docs.isNotEmpty
                ? snapshot.docs.last
                : null;
            _hasMorePosts = snapshot.docs.length == _postLimit;
            _isLoadingPosts = false;
          });
        }, onError: (e) => _showSnackBar("Lỗi realtime: $e"));
  }

  Future<void> _loadMoreMembers() async {
    if (_isLoadingMembers || !_hasMoreMembers) return;
    setState(() => _isLoadingMembers = true);

    int statusId = -1;
    switch (_memberFilter) {
      case 'Chờ duyệt':
        statusId = 0;
        break;
      case 'Đã duyệt':
        statusId = 1;
        break;
      case 'Từ chối':
        statusId = 2;
        break;
    }

    final snapshot = await _memberService
        .getMembersByStatus(
          groupId: widget.groupId,
          limit: _memberLimit,
          startAfter: _lastMemberDocument,
          statusId: statusId,
        )
        .first;

    final newMembers = <MemberApprovalModel>[];
    for (var doc in snapshot.docs) {
      final member = await _memberService.docToMemberModel(doc);
      newMembers.add(member);
    }

    setState(() {
      _members.addAll(newMembers);
      _lastMemberDocument = snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : null;
      _hasMoreMembers = snapshot.docs.length == _memberLimit;
      _isLoadingMembers = false;
    });
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingPosts || !_hasMorePosts) return;
    setState(() => _isLoadingPosts = true);
    await _loadPosts();
  }

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

  List<MemberApprovalModel> get _filteredMembers {
    if (_memberFilter == 'Tất cả') return _members;
    return _members.where((member) {
      switch (_memberFilter) {
        case 'Chờ duyệt':
          return member.status == 'pending';
        case 'Đã duyệt':
          return member.status == 'approved';
        case 'Từ chối':
          return member.status == 'rejected';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildFilterSection() {
    final currentFilter = _selectedTabIndex == 0 ? _postFilter : _memberFilter;
    final options = ['Tất cả', 'Chờ duyệt', 'Đã duyệt', 'Từ chối'];

    final Map<String, IconData> icons = {
      'Tất cả': Icons.filter_list,
      'Chờ duyệt': Icons.hourglass_empty_outlined,
      'Đã duyệt': Icons.check_circle_outline,
      'Từ chối': Icons.cancel_outlined,
    };

    final Map<String, Color> colors = {
      'Tất cả': Colors.blueGrey,
      'Chờ duyệt': Colors.orange,
      'Đã duyệt': Colors.green,
      'Từ chối': Colors.red,
    };

    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade100,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentFilter,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: options.map((opt) {
                    final icon = icons[opt]!;
                    final color = colors[opt]!;
                    return DropdownMenuItem(
                      value: opt,
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            opt,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      if (_selectedTabIndex == 0) {
                        _postFilter = value!;
                        _loadPosts(isRefresh: true);
                      } else {
                        _memberFilter = value!;
                        _loadMembers(
                          isRefresh: true,
                        ); // [SỬA - 15/11/2025 02:30]
                      }
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsList() {
    final posts = _filteredPosts;
    if (posts.isEmpty && !_isLoadingPosts) {
      return Center(
        child: Text(
          _postFilter == 'Tất cả'
              ? 'Không có bài viết nào'
              : 'Không có bài viết $_postFilter',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: posts.length + (_hasMorePosts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          _loadMorePosts();
          return Center(child: CircularProgressIndicator());
        }
        final post = posts[index];
        return UserPostApproval(
          post: post,
          onApprove: () => _approvePost(post),
          onReject: () => _rejectPost(post),
        );
      },
    );
  }

  Widget _buildMemberList() {
    final members = _filteredMembers;

    if (_isLoadingMembers && members.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (members.isEmpty) {
      return Center(
        child: Text(
          _memberFilter == 'Tất cả'
              ? 'Không có thành viên nào'
              : 'Không có thành viên $_memberFilter',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: members.length + (_hasMoreMembers ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == members.length) {
          _loadMoreMembers();
          return Center(child: CircularProgressIndicator());
        }
        final member = members[index];
        return MemberApprovalWidget(
          user: member,
          onApprove: () => _approveMember(member),
          onReject: () => _rejectMember(member),
        );
      },
    );
  }

  Future<void> _approvePost(UserPostApprovalModel post) async {
    if (!await _showConfirm(
      'Duyệt bài viết',
      'Bạn có chắc muốn duyệt bài viết này?',
    ))
      return;
    try {
      await _approvalService.approvePost(post.id);
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) _posts[index] = post.copyWith(status: 'approved');
      });
      _showSnackBar('Đã duyệt bài viết');
    } catch (e) {
      _showSnackBar('Lỗi duyệt bài viết');
    }
  }

  Future<void> _rejectPost(UserPostApprovalModel post) async {
    if (!await _showConfirm(
      'Từ chối bài viết',
      'Bạn có chắc muốn từ chối bài viết này?',
    ))
      return;
    try {
      await _approvalService.rejectPost(post.id);
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) _posts[index] = post.copyWith(status: 'rejected');
      });
      _showSnackBar('Đã từ chối bài viết');
    } catch (e) {
      _showSnackBar('Lỗi từ chối bài viết');
    }
  }

  Future<void> _approveMember(MemberApprovalModel member) async {
    if (!await _showConfirm('Duyệt thành viên', 'Bạn có chắc muốn duyệt?'))
      return;
    try {
      await _memberService.approveMember(member.id);
      setState(() {
        final index = _members.indexWhere((m) => m.id == member.id);
        if (index != -1) _members[index] = member.copyWith(status: 'approved');
      });
      _showSnackBar('Đã duyệt thành viên');
    } catch (e) {
      _showSnackBar('Lỗi duyệt thành viên');
    }
  }

  Future<void> _rejectMember(MemberApprovalModel member) async {
    if (!await _showConfirm('Từ chối thành viên', 'Bạn có chắc muốn từ chối?'))
      return;
    try {
      await _memberService.rejectMember(member.id);
      setState(() {
        final index = _members.indexWhere((m) => m.id == member.id);
        if (index != -1) _members[index] = member.copyWith(status: 'rejected');
      });
      _showSnackBar('Đã từ chối thành viên');
    } catch (e) {
      _showSnackBar('Lỗi từ chối thành viên');
    }
  }

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
            onTabSelected: (index) {
              setState(() => _selectedTabIndex = index);
              if (index == 1) {
                _loadMembers(isRefresh: true);
              }
            },
          ),
          _buildFilterSection(),
          Expanded(
            child: _selectedTabIndex == 0
                ? RefreshIndicator(
                    onRefresh: () => _loadPosts(isRefresh: true),
                    child: _buildPostsList(),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _loadMembers(isRefresh: true),
                    child: _buildMemberList(),
                  ),
          ),
        ],
      ),
    );
  }
}
