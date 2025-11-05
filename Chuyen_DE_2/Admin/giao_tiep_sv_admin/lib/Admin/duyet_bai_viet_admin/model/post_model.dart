import 'package:giao_tiep_sv_admin/Data/faculty.dart';

enum PostStatus { pending, approved, rejected }

class Post {
  final String id;
  final String author;
  late final Faculty faculty;
  final String title;
  final String content;
  final String? imageUrl; // Thêm trường ảnh
  PostStatus status;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.author,
    required this.faculty,
    required this.title,
    required this.content,
    this.imageUrl, // Ảnh có thể null
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'faculty': faculty,
      'title': title,
      'content': content,
      'imageUrl': imageUrl, // Thêm imageUrl
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Post from Map
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      author: map['author'],
      faculty: map['faculty'],
      title: map['title'],
      content: map['content'],
      imageUrl: map['imageUrl'], // Thêm imageUrl
      status: _parseStatus(map['status']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static PostStatus _parseStatus(String status) {
    switch (status) {
      case 'PostStatus.approved':
        return PostStatus.approved;
      case 'PostStatus.rejected':
        return PostStatus.rejected;
      default:
        return PostStatus.pending;
    }
  }

  // Copy with method for immutability
  Post copyWith({
    String? id,
    String? author,
    Faculty? faculty,
    String? group,
    String? title,
    String? content,
    String? imageUrl, // Thêm imageUrl
    PostStatus? status,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      faculty: faculty ?? this.faculty,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl, // Thêm imageUrl
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, author: $author, group: $faculty, title: $title, imageUrl: $imageUrl, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        other.id == id &&
        other.author == author &&
        other.faculty == faculty &&
        other.title == title &&
        other.content == content &&
        other.imageUrl == imageUrl && // Thêm imageUrl
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        author.hashCode ^
        faculty.hashCode ^
        title.hashCode ^
        content.hashCode ^
        imageUrl.hashCode ^ // Thêm imageUrl
        status.hashCode ^
        createdAt.hashCode;
  }
}
