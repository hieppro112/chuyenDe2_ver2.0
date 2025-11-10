class SavedItemModel {
  final String id;
  final String title;
  final String? image;
  final String userId; // GIỮ LẠI user_id ĐỂ TIỆN THEO DÕI
  final String userName; // THÊM TÊN USER
  final String userFaculty; // THÊM KHOA
  final DateTime? savedAt;
  final String type;
  final String group;

  SavedItemModel({
    required this.id,
    required this.title,
    this.image,
    required this.userId,
    required this.userName, // REQUIRED
    required this.userFaculty, // REQUIRED
    this.savedAt,
    required this.type,
    required this.group,
  });

  factory SavedItemModel.fromMap(Map<String, dynamic> map) {
    final imageUrls = map['image_urls'] as List<dynamic>?;
    return SavedItemModel(
      id: map['id'] as String,
      title: map['content'] as String? ?? 'Không có tiêu đề',
      image: imageUrls != null && imageUrls.isNotEmpty
          ? imageUrls[0] as String?
          : null,
      userId: map['user_id'] as String? ?? 'Ẩn danh',
      userName: map['user_name'] as String? ?? 'Ẩn danh', // LẤY TÊN USER
      userFaculty:
          map['user_faculty'] as String? ?? 'Chưa cập nhật', // LẤY KHOA
      savedAt: map['saved_at'] as DateTime?,
      type: 'post',
      group: map['group'] as String? ?? 'Tất cả',
    );
  }
}
