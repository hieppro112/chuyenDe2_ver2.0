// duyet_nhom_model.dart
class DuyetNhomAdminModel {
  final String id;
  final String name;
  final String description;
  final String avt;
  final Map<String, dynamic> createdBy;
  final Map<String, dynamic> facultyId;
  final int statusId;
  final int typeGroup;
  final bool approvalMode;

  DuyetNhomAdminModel({
    required this.id,
    required this.name,
    required this.description,
    required this.avt,
    required this.createdBy,
    required this.facultyId,
    required this.statusId,
    required this.typeGroup,
    required this.approvalMode,
  });

  factory DuyetNhomAdminModel.fromMap(Map<String, dynamic> map) {
    try {
      // Debug: in ra toàn bộ dữ liệu để kiểm tra
      print('Raw data from Firestore: $map');

      return DuyetNhomAdminModel(
        id: _parseString(map['id']),
        name: _parseString(map['name']),
        description: _parseString(map['description']),
        avt: _parseString(map['avt']),
        createdBy: _parseMap(map['created_by']),
        facultyId: _parseMap(map['faculty_id']),
        statusId: _parseInt(map['status_id']),
        typeGroup: _parseInt(map['type_group']),
        approvalMode: _parseBool(map['approval_mode']),
      );
    } catch (e) {
      print('Error parsing DuyetNhomAdminModel: $e');
      print('Problematic data: $map');
      rethrow;
    }
  }

  // Helper methods để xử lý các kiểu dữ liệu
  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    return {};
  }

  // Thêm getter để lấy thông tin hiển thị
  String get facultyName {
    if (facultyId.isNotEmpty) {
      // Lấy giá trị đầu tiên từ map facultyId
      final firstValue = facultyId.values.first;
      return firstValue is String ? firstValue : firstValue.toString();
    }
    return 'Không xác định';
  }

  List<String> get members {
    return createdBy.values.map((e) => e.toString()).toList();
  }

  GroupStatus get status {
    switch (statusId) {
      case 1:
        return GroupStatus.approved;
      case 2:
        return GroupStatus.rejected;
      default:
        return GroupStatus.pending;
    }
  }
}

enum GroupStatus { pending, approved, rejected }
