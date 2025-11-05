import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/models/saved_item_model.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/widgets/filter_dropdown_widget.dart';
import 'package:giao_tiep_sv_user/Profile/saveItemsProfile/widgets/saved_item_card_widget.dart';

class SavedItemsProfileScreen extends StatefulWidget {
  const SavedItemsProfileScreen({super.key});

  @override
  State<SavedItemsProfileScreen> createState() =>
      _SavedItemsProfileScreenState();
}

class _SavedItemsProfileScreenState extends State<SavedItemsProfileScreen> {
  String selectedFilter = "Tất cả";

  // Sử dụng Model thay vì Map
  final List<SavedItemModel> savedItems = [
    SavedItemModel(
      id: '1',
      title: "Team thiếu thuyền viên...",
      author: "Cao Quang Khánh",
      image: "https://watv.org/wp-content/uploads/2021/02/another-world-2.jpg",
      savedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SavedItemModel(
      id: '2',
      title: "Team thiếu thuyền viên...",
      author: "Lê Đại Hiệp",
      image:
          "https://cdn2.tuoitre.vn/471584752817336320/2024/6/3/one-piece-manga-remake-animepng-17174025179101502756813.jpg",
      savedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SavedItemModel(
      id: '3',
      title: "Team thiếu thuyền viên...",
      author: "Lê Đình thuận",
      image:
          "https://gamek.mediacdn.vn/zoom/600_315/133514250583805952/2020/1/14/avata-15790129992981461680642.jpg",
      savedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    SavedItemModel(
      id: '4',
      title: "Team thiếu thuyền viên...",
      author: "Cao Quang Khánh",
      image:
          "https://hoanghamobile.com/tin-tuc/wp-content/uploads/2023/07/anh-luffy.jpg",
      savedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  void _handleFilterChange(String newFilter) {
    setState(() {
      selectedFilter = newFilter;
    });
  }

  void _handleDeleteItem(int index, String action) {
    if (action == 'delete') {
      setState(() {
        savedItems.removeAt(index);
      });

      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa khỏi mục đã lưu'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Lọc items theo filter
  List<SavedItemModel> get _filteredItems {
    if (selectedFilter == "Tất cả") {
      return savedItems;
    } else if (selectedFilter == "Bài viết") {
      return savedItems.where((item) => item.type == 'post').toList();
    } else if (selectedFilter == "Video") {
      return savedItems.where((item) => item.type == 'video').toList();
    }
    return savedItems;
  }

  @override
  Widget build(BuildContext context) {
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
              onChanged: _handleFilterChange,
            ),
            const SizedBox(height: 10),

            // Thông số
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '${_filteredItems.length} mục đã lưu',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),

            // Danh sách mục đã lưu
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(
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
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final originalIndex = savedItems.indexOf(item);

                        return SavedItemCardWidget(
                          item: item,
                          index: originalIndex,
                          onDelete: (action) =>
                              _handleDeleteItem(originalIndex, action),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
