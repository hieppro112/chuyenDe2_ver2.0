class ViolationReport {
  final String name;
  final String id;
  final String reason;
  final String avatarUrl;
  final String department;
  final String email;
  final String reportTime;

  ViolationReport({
    required this.name,
    required this.id,
    required this.reason,
    required this.avatarUrl,
    required this.department,
    required this.email,
    required this.reportTime,
  });
}

final List<ViolationReport> mockReports = [
  ViolationReport(
    name: 'Lê Đình Thuận',
    id: '232111TT1371',
    reason: 'Nội dung phản cảm',
    avatarUrl: 'https://cdn-icons-png.flaticon.com/512/147/147142.png',
    department: 'Công nghệ thông tin',
    email: '232111TT1371@mail.tdc.edu.vn',
    reportTime: '22/9/2025 20:00',
  ),
  ViolationReport(
    name: 'Lê Đại Hiệp',
    id: '232111TT1371',
    reason: 'Spam tin nhắn',
    avatarUrl: 'https://cdn-icons-png.flaticon.com/512/147/147144.png',
    department: 'Quản trị kinh doanh',
    email: 'hiep.ld@mail.tdc.edu.vn',
    reportTime: '23/9/2025 10:30',
  ),
  ViolationReport(
    name: 'Cao Quang Khánh',
    id: '232111TT1371',
    reason: 'Ngôn từ không phù hợp',
    avatarUrl: 'https://cdn-icons-png.flaticon.com/512/147/147140.png',
    department: 'Marketing',
    email: 'khanh.cq@mail.tdc.edu.vn',
    reportTime: '24/9/2025 15:45',
  ),
  ViolationReport(
    name: 'Phạm Thắng',
    id: '232111TT1371',
    reason: 'Quảng cáo trái phép',
    avatarUrl: 'https://cdn-icons-png.flaticon.com/512/147/147141.png',
    department: 'Kế toán',
    email: 'thang.p@mail.tdc.edu.vn',
    reportTime: '25/9/2025 08:00',
  ),
  ViolationReport(
    name: 'Nguyễn Văn A',
    id: '232111TT1001',
    reason: 'Đe dọa người khác',
    avatarUrl: 'https://cdn-icons-png.flaticon.com/512/147/147133.png',
    department: 'Thiết kế đồ họa',
    email: 'vana@mail.tdc.edu.vn',
    reportTime: '26/9/2025 12:20',
  ),
  ViolationReport(
    name: 'Trần Thị B',
    id: '232111TT1002',
    reason: 'Spam tin nhắn',
    avatarUrl: 'https://cdn-icons-png.flaticon.com/512/147/147139.png',
    department: 'Tiếng Anh',
    email: 'thib@mail.tdc.edu.vn',
    reportTime: '27/9/2025 19:10',
  ),
];
