// models/User_post_approval_model.dart
class UserPostApprovalModel {
  final String id;
  final String authorName;
  final String content;
  final String image;
  final DateTime date;
  String status; // THAY ĐỔI: bỏ final để có thể cập nhật
  final String reviewType;

  UserPostApprovalModel({
    required this.id,
    required this.authorName,
    required this.content,
    required this.image,
    required this.date,
    required this.status,
    required this.reviewType,
  });

  // THÊM: Phương thức copyWith để cập nhật trạng thái
  UserPostApprovalModel copyWith({
    String? id,
    String? authorName,
    String? content,
    String? image,
    DateTime? date,
    String? status,
    String? reviewType,
  }) {
    return UserPostApprovalModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      image: image ?? this.image,
      date: date ?? this.date,
      status: status ?? this.status,
      reviewType: reviewType ?? this.reviewType,
    );
  }
}
