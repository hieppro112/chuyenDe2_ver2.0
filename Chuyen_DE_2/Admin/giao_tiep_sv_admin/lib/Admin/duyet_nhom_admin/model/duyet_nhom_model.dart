import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupStatus { pending, approved, rejected }

class DuyetNhomAdminModel {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final String facultyId;
  final String? avatarUrl;
  final bool approvalMode;
  final int typeGroup;
  GroupStatus status;
  final DateTime createdAt;

  DuyetNhomAdminModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.facultyId,
    this.avatarUrl,
    required this.approvalMode,
    required this.typeGroup,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'faculty_id': facultyId,
      'avt': avatarUrl,
      'approval_mode': approvalMode,
      'type_group': typeGroup,
      'id_status': _statusToInt(status),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DuyetNhomAdminModel.fromMap(Map<String, dynamic> map) {
    // Xử lý created_at: có thể là Timestamp hoặc String
    DateTime? createdAt;
    final createdAtData = map['created_at'];
    if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else if (createdAtData is String) {
      try {
        createdAt = DateTime.parse(createdAtData);
      } catch (e) {
        // Nếu parse lỗi, dùng thời gian hiện tại
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }
    return DuyetNhomAdminModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['created_by'] ?? '',
      facultyId: map['faculty_id'] ?? '',
      avatarUrl: map['avt'],
      approvalMode: map['approval_mode'] ?? true,
      typeGroup: map['type_group'] ?? 0,
      status: _parseStatus(map['id_status']),
      createdAt: createdAt,
    );
  }

  static GroupStatus _parseStatus(dynamic status) {
    if (status is int) {
      switch (status) {
        case 1:
          return GroupStatus.approved;
        case 2:
          return GroupStatus.rejected;
        default:
          return GroupStatus.pending;
      }
    }
    return GroupStatus.pending;
  }

  static int _statusToInt(GroupStatus status) {
    switch (status) {
      case GroupStatus.approved:
        return 1;
      case GroupStatus.rejected:
        return 2;
      case GroupStatus.pending:
        return 0;
    }
  }

  DuyetNhomAdminModel copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    String? facultyId,
    String? avatarUrl,
    bool? approvalMode,
    int? typeGroup,
    GroupStatus? status,
    DateTime? createdAt,
  }) {
    return DuyetNhomAdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      facultyId: facultyId ?? this.facultyId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      approvalMode: approvalMode ?? this.approvalMode,
      typeGroup: typeGroup ?? this.typeGroup,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Group(id: $id, name: $name, createdBy: $createdBy, status: $status)';
  }
}
