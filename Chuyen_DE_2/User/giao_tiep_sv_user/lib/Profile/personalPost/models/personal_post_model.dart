class PersonalPostModel {
  final String id;
  final String name;
  final String faculty;
  final String title;
  final String image;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  bool isLiked;

  PersonalPostModel({
    required this.id,
    required this.name,
    required this.faculty,
    required this.title,
    required this.image,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  // Factory method để tạo từ Map
  factory PersonalPostModel.fromMap(Map<String, dynamic> map) {
    return PersonalPostModel(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] ?? '',
      faculty: map['faculty'] ?? '',
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      createdAt: map['createdAt'] ?? DateTime.now(),
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
    );
  }

  // Copy with method để dễ dàng cập nhật
  PersonalPostModel copyWith({
    String? id,
    String? name,
    String? faculty,
    String? title,
    String? image,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return PersonalPostModel(
      id: id ?? this.id,
      name: name ?? this.name,
      faculty: faculty ?? this.faculty,
      title: title ?? this.title,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
