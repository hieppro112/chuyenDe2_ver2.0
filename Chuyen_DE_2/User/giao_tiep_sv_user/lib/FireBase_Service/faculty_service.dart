// faculty_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tra cứu tên Khoa dựa trên facultyId.
  Future<String> getFacultyName(String facultyId) async {
    if (facultyId.isEmpty) {
      return "Không rõ";
    }
    try {
      final doc = await _firestore.collection('Faculty').doc(facultyId).get();
      if (doc.exists && doc.data() != null) {
        // Dựa trên cấu trúc ảnh Firebase bạn cung cấp, tên khoa là trường 'name'
        final name = doc.data()!['name'];
        return name ?? "Không rõ";
      }
      return "Không tìm thấy";
    } catch (e) {
      print("Lỗi tra cứu tên Khoa: $e");
      return "Lỗi dữ liệu";
    }
  }
}
