import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/get_joined_groups.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/search_service.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/port_card.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/wiget/user_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  final GetJoinedGroupsService _groupsService = GetJoinedGroupsService();

  String selectedCategory = 'Người dùng';
  final List<String> categories = ['Người dùng', 'Bài viết'];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  final String _currentUserId = GlobalState.currentUserId;

  List<String> _currentUserGroupIds = [];
  Map<String, String> _groupIdToName = {}; // Lưu mapping id -> name
  bool _isGroupsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchGroups() async {
    if (_currentUserId.isEmpty) {
      setState(() {
        _isGroupsLoading = false;
      });
      return;
    }

    setState(() => _isGroupsLoading = true);

    final groups = await _groupsService.fetchJoinedGroups(_currentUserId);

    final groupIds = groups
        .map((g) => g["id"] as String)
        .where((id) => id != "ALL")
        .toList();

    setState(() {
      _currentUserGroupIds = groupIds;

      // Tạo Map id -> name
      _groupIdToName = {
        for (var g in groups)
          if (g["id"] != "ALL") g["id"]: g["name"] as String,
      };

      _isGroupsLoading = false;
    });

    if (_searchController.text.length > 1 && selectedCategory == 'Bài viết') {
      _performSearch(_searchController.text.trim());
    }
  }

  void _onSearchChanged() {
    if (!_isGroupsLoading && _searchController.text.length > 1) {
      _performSearch(_searchController.text.trim());
    } else if (_searchController.text.isEmpty) {
      setState(() => _searchResults = []);
    }
  }

  Future<void> _performSearch(String query) async {
    if (_isLoading || _isGroupsLoading) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    List<Map<String, dynamic>> results;
    if (selectedCategory == 'Người dùng') {
      results = await _searchService.searchUsers(query);
    } else {
      results = await _searchService.searchPosts(query, _currentUserGroupIds);

      // Chuyển group_id -> group_name
      results = results.map((post) {
        return {
          ...post,
          "group_name": _groupIdToName[post["group"]] ?? "Không rõ",
        };
      }).toList();
    }

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Widget _buildResultList() {
    if (_isGroupsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedCategory == 'Bài viết' && _currentUserGroupIds.isEmpty) {
      return Center(
        child: Text('Bạn chưa tham gia nhóm nào. Không thể tìm kiếm bài viết.'),
      );
    }

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Nhập từ khóa để tìm kiếm...'
              : 'Không tìm thấy kết quả cho "${_searchController.text}"',
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];

        if (selectedCategory == 'Người dùng') {
          return UserCard(user: item, onTap: () {});
        } else {
          return PostCard(
            post: item,
            onCommentPressed: () {},
            onLikePressed: () {},
            // Trong PostCard, hiển thị post["group_name"] thay vì group_id
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tìm kiếm', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    onSubmitted: (value) => _performSearch(value.trim()),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: categories
                      .map(
                        (String value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                      if (_searchController.text.length > 1) {
                        _performSearch(_searchController.text.trim());
                      } else {
                        _searchResults = [];
                      }
                    });
                  },
                  underline: Container(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildResultList()),
          ],
        ),
      ),
    );
  }
}
