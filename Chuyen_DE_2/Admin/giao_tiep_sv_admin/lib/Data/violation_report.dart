// lib/data/violation_report.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ViolationReport {
  final String docId;
  final String title;
  final String content;
  final String department;
  final int typeNotify;
  final String avatarUrl =
      'https://cdn-icons-png.flaticon.com/512/147/147142.png';

  ViolationReport({
    required this.docId,
    required this.title,
    required this.content,
    required this.department,
    required this.typeNotify,
  });

  factory ViolationReport.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    // BƯỚC QUAN TRỌNG: DÙNG GENERIC <Map<String, dynamic>>
    final data = doc.data();

    // Nếu data == null → trả về mặc định
    if (data == null) {
      return ViolationReport(
        docId: doc.id,
        title: 'Dữ liệu trống',
        content: '',
        department: '',
        typeNotify: 0,
      );
    }

    return ViolationReport(
      docId: doc.id,
      title: data['title']?.toString() ?? 'Không có tiêu đề',
      content: data['content']?.toString() ?? 'Không có nội dung',
      department: data['TT']?.toString() ?? 'Không rõ khoa',
      typeNotify: (data['type_notify'] is int) ? data['type_notify'] as int : 0,
    );
  }
}
