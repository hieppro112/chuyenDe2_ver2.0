import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalPostModel {
  final String id;
  final String userId;
  final String groupId;
  final String title;
  final List<String> imageUrls; // ĐỔI TỪ String → List<String>
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  // UI-only
  String? userName;
  String? groupName;

  PersonalPostModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.title,
    required this.imageUrls, // <-- List
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
    List<String>? imageUrls, // <-- List
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
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      userName: userName ?? this.userName,
      groupName: groupName ?? this.groupName,
    );
  }

  // THÊM: fromMap để convert từ Firestore
  factory PersonalPostModel.fromMap(Map<String, dynamic> map, String id) {
    final rawImages = map['image_urls'] ?? [];
    final List<String> imageUrls = rawImages is List
        ? rawImages.cast<String>()
        : (rawImages is String && rawImages.isNotEmpty)
        ? [rawImages]
        : <String>[];

    return PersonalPostModel(
      id: id,
      userId: map['userId'] ?? '',
      groupId: map['group_id'] ?? '',
      title: map['content'] ?? '',
      imageUrls: imageUrls,
      createdAt: (map['date_created'] as Timestamp).toDate(),
      likesCount: map['likes'] ?? 0,
      commentsCount: map['comments'] ?? 0,
    );
  }
}
