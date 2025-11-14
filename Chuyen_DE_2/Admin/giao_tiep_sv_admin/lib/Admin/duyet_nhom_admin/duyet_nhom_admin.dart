import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Admin/duyet_nhom_admin/model/duyet_nhom_model.dart';
import 'package:giao_tiep_sv_admin/Admin/duyet_nhom_admin/widget/groups_card.dart';

class DuyetNhomAdminScreen extends StatefulWidget {
  @override
  _DuyetNhomAdminScreenState createState() => _DuyetNhomAdminScreenState();
}

class _DuyetNhomAdminScreenState extends State<DuyetNhomAdminScreen> {
  List<DuyetNhomAdminModel> groups = [];
  StreamSubscription<QuerySnapshot>? _groupSubscription;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    _groupSubscription = FirebaseFirestore.instance
        .collection('Groups')
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) {
            final List<DuyetNhomAdminModel> loadedGroups = snapshot.docs.map((
              doc,
            ) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return DuyetNhomAdminModel.fromMap(data);
            }).toList();
            if (mounted) {
              setState(() {
                groups = loadedGroups;
              });
            }
          },
          onError: (error) {
            print('Lỗi lấy dữ liệu nhóm: $error');
            if (mounted) {
              _showSnackBar('Lỗi kết nối: Vui lòng kiểm tra mạng');
            }
          },
        );
  }

  @override
  void dispose() {
    _groupSubscription?.cancel();
    super.dispose();
  }

  // Bộ lọc
  GroupFilterType _currentFilter = GroupFilterType.all;

  void _duyetNhom(String groupId, String groupName) {
    FirebaseFirestore.instance
        .collection('Groups')
        .doc(groupId)
        .update({'status_id': 1}) // Đổi thành status_id
        .then((_) {
          _showSnackBar('Đã duyệt nhóm "$groupName"');
        })
        .catchError((error) {
          _showSnackBar('Lỗi khi duyệt nhóm: $error');
        });
  }

  // Từ chối nhóm theo ID
  void _tuChoiNhom(String groupId, String groupName) {
    FirebaseFirestore.instance
        .collection('Groups')
        .doc(groupId)
        .update({'status_id': 2}) // Đổi thành status_id
        .then((_) {
          _showSnackBar('Đã từ chối nhóm "$groupName"');
        })
        .catchError((error) {
          _showSnackBar('Lỗi khi từ chối nhóm: $error');
        });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Lọc nhóm
  List<DuyetNhomAdminModel> get filteredGroups {
    switch (_currentFilter) {
      case GroupFilterType.pending:
        return groups.where((g) => g.status == GroupStatus.pending).toList();
      case GroupFilterType.approved:
        return groups.where((g) => g.status == GroupStatus.approved).toList();
      case GroupFilterType.rejected:
        return groups.where((g) => g.status == GroupStatus.rejected).toList();
      case GroupFilterType.all:
        return groups;
    }
  }

  int get pendingGroupsCount =>
      groups.where((g) => g.status == GroupStatus.pending).length;
  int get approvedGroupsCount =>
      groups.where((g) => g.status == GroupStatus.approved).length;
  int get rejectedGroupsCount =>
      groups.where((g) => g.status == GroupStatus.rejected).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Duyệt nhóm',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Bộ lọc
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // lọc duyệt nhóm
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<GroupFilterType>(
                          value: _currentFilter,
                          onChanged: (value) {
                            setState(() => _currentFilter = value!);
                          },
                          isExpanded: true,
                          underline: SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: GroupFilterType.all,
                              child: Text('Tất cả (${groups.length})'),
                            ),
                            DropdownMenuItem(
                              value: GroupFilterType.pending,
                              child: Text('Chờ duyệt ($pendingGroupsCount)'),
                            ),
                            DropdownMenuItem(
                              value: GroupFilterType.approved,
                              child: Text('Đã duyệt ($approvedGroupsCount)'),
                            ),
                            DropdownMenuItem(
                              value: GroupFilterType.rejected,
                              child: Text('Từ chối ($rejectedGroupsCount)'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                //hiển thị số lượng group
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Có ${filteredGroups.length} nhóm phù hợp',
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
          // Danh sách nhóm
          Expanded(
            child: filteredGroups.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = filteredGroups[index];
                      return GroupCard(
                        group: group,
                        onApprove: () => _duyetNhom(group.id, group.name),
                        onReject: () => _tuChoiNhom(group.id, group.name),
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
        Icon(Icons.group_outlined, size: 64, color: Colors.grey[300]),
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
      case GroupFilterType.pending:
        return 'Không có nhóm nào đang chờ duyệt';
      case GroupFilterType.approved:
        return 'Không có nhóm nào đã được duyệt';
      case GroupFilterType.rejected:
        return 'Không có nhóm nào bị từ chối';
      case GroupFilterType.all:
        return 'Không có nhóm nào';
    }
  }
}

enum GroupFilterType { all, pending, approved, rejected }
