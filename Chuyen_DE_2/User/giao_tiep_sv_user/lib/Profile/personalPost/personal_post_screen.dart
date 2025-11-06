import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/post_user.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/Profile_Service.dart';
import 'package:giao_tiep_sv_user/Profile/editProflie/models/profile_model.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/models/personal_post_model.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/widgets/personal_post_item.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/widgets/profile_header_widget.dart';

class PersonalPostScreen extends StatefulWidget {
  final String currentUserId;
  final String userName;
  final String avatarUrl;
  final File? avatarFile;

  const PersonalPostScreen({
    super.key,
    required this.currentUserId,
    this.userName = "",
    this.avatarUrl = "",
    this.avatarFile,
  });

  @override
  State<PersonalPostScreen> createState() => _PersonalPostScreenState();
}

class _PersonalPostScreenState extends State<PersonalPostScreen> {
  late final PostRepository _postRepository;
  late final ProfileService _profileService;
  List<PersonalPostModel> _posts = [];
  ProfileModel? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _postRepository = PostRepository();
    _profileService = ProfileService();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải thông tin: $e")));
    }
  }

  void _handleLike(int index) {
    setState(() {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _posts[index].isLiked ? "Đã thả tim [heart]" : "Đã bỏ thả tim",
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleComment(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Chuyển đến màn hình bình luận")),
    );
  }

  void _handleDelete(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa bài viết"),
        content: const Text("Bạn có chắc muốn xóa bài viết này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('Post')
            .doc(postId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã xóa bài viết"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Bài viết"),
      ),
      body: StreamBuilder<List<PersonalPostModel>>(
        stream: _postRepository.personalPostsStream(widget.currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoadingProfile) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          _posts = snapshot.data ?? [];

          final displayName = _profile?.name?.isNotEmpty == true
              ? _profile!.name
              : widget.userName;
          final displayAvatarUrl = _profile?.avatarUrl?.isNotEmpty == true
              ? _profile!.avatarUrl
              : widget.avatarUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với thông tin đầy đủ
                if (_profile != null)
                  ProfileHeaderWidget(
                    avatarUrl: displayAvatarUrl,
                    avatarFile: widget.avatarFile,
                    name: displayName,
                    email: _profile!.email,
                    facultyId: _profile!.faculty.faculty_id,
                    postCount: _posts.length,
                  )
                else
                  const Center(
                    child: Text("Không tải được thông tin người dùng"),
                  ),

                const SizedBox(height: 16),
                const Text(
                  "Bài viết",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Danh sách bài viết
                _posts.isEmpty
                    ? const Center(
                        child: Text(
                          "Chưa có bài viết nào",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return PersonalPostItemWidget(
                            post: post,
                            onComment: () => _handleComment(index),
                            onLike: () => _handleLike(index),
                            onDelete: () => _handleDelete(post.id),
                            onEdit: null,
                            avatarUrl: displayAvatarUrl,
                            avatarFile: widget.avatarFile,
                            currentUserName: displayName,
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
