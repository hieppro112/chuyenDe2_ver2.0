// models/MemberApprovalModel.dart
class MemberApprovalModel {
  final String id;
  final String fullName;
  final String avatar_member;
  String reviewStatus; // THAY ĐỔI: bỏ final để có thể cập nhật
  final String reviewType;

  MemberApprovalModel({
    required this.id,
    required this.fullName,
    // ignore: non_constant_identifier_names
    required this.avatar_member,
    required this.reviewStatus,
    required this.reviewType,
  });

  // THÊM: Phương thức copyWith để cập nhật trạng thái
  MemberApprovalModel copyWith({
    String? id,
    String? fullName,
    String? avatar_member,
    String? reviewStatus,
    String? reviewType,
  }) {
    return MemberApprovalModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatar_member: avatar_member ?? this.avatar_member,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewType: reviewType ?? this.reviewType,
    );
  }
}
