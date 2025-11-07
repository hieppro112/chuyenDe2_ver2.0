// domain/models/personal_post_model.dart
class PersonalPostModel {
  final String id; // post document ID
  final String userId; // Users.id_user
  final String groupId; // Groups.id_group
  final String title; // content
  final String image;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  // UI‑only (sẽ được fill sau khi join)
  String? userName; // fullname từ Users
  String? groupName; // name từ Groups

  PersonalPostModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.title,
    required this.image,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.userName,
    this.groupName,
  });

  PersonalPostModel copyWith({
    String? id,
    String? userId,
    String? groupId,
    String? title,
    String? imageUrl,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    String? userName,
    String? groupName,
  }) {
    return PersonalPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      image: imageUrl ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      userName: userName ?? this.userName,
      groupName: groupName ?? this.groupName,
    );
  }
}
