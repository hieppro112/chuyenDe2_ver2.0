import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/models/saved_item_model.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/widgets/filter_dropdown_widget.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/widgets/saved_item_card_widget.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/SavedPostsService.dart'; // Import service
import 'package:giao_tiep_sv_user/Data/global_state.dart'; // Lấy userId

class SavedItemsProfileScreen extends StatefulWidget {
  const SavedItemsProfileScreen({super.key});

  @override
  State<SavedItemsProfileScreen> createState() =>
      _SavedItemsProfileScreenState();
}

class _SavedItemsProfileScreenState extends State<SavedItemsProfileScreen> {
  final SavedPostsService _savedService = SavedPostsService();
  String selectedFilter = "Tất cả";

  @override
  Widget build(BuildContext context) {
    // ---- LẤY studentId ----
    final String studentId = _getCurrentStudentId();

    print("StudentId dùng để query: '$studentId'"); // ← DEBUG
    if (studentId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mục đã lưu')),
        body: const Center(child: Text('Vui lòng đăng nhập')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mục đã lưu", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown filter
            FilterDropdownWidget(
              selectedValue: selectedFilter,
              items: const ["Tất cả", "Bài viết", "Video"],
              onChanged: (newFilter) {
                setState(() => selectedFilter = newFilter);
              },
            ),
            const SizedBox(height: 10),

            // StreamBuilder để lấy dữ liệu realtime
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _savedService.streamSavedPosts(studentId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Lỗi tải dữ liệu"));
                  }

                  final List<Map<String, dynamic>> posts = snapshot.data ?? [];
                  // Chuyển đổi sang SavedItemModel
                  final List<SavedItemModel> savedItems = posts.map((post) {
                    return SavedItemModel.fromMap(post);
                  }).toList();

                  // Lọc theo filter
                  final filteredItems = _filterItems(savedItems);

                  if (filteredItems.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có mục nào được lưu',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${filteredItems.length} mục đã lưu',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return SavedItemCardWidget(
                              item: item,
                              index: index,
                              onDelete: (postId) {
                                _savedService.unsavePost(studentId, postId);
                              },
                              onTap: () {
                                print(
                                  "Tap on post: ${item.id}, group: ${item.group}",
                                );
                                _navigateToPost(item.id, item.group);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPost(String postId, String group) {
    Navigator.pop(context, {'postId': postId, 'group': group});
  }

  String _getCurrentStudentId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return '';

    // Chuẩn hóa: viết hoa + loại bỏ ký tự lạ
    return user!.email!
        .split('@')
        .first
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  List<SavedItemModel> _filterItems(List<SavedItemModel> items) {
    if (selectedFilter == "Tất cả") return items;
    if (selectedFilter == "Bài viết") {
      return items.where((i) => i.type == 'post').toList();
    }
    if (selectedFilter == "Video") {
      return items.where((i) => i.type == 'video').toList();
    }
    return items;
  }
}
