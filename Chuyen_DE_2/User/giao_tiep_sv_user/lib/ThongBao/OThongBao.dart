// File: OThongBao.dart
import 'package:flutter/material.dart';

class OThongBao extends StatelessWidget {
  final String tieuDe;
  final String noiDung;
  final VoidCallback? onTap;
  final bool isRead; // 👈 Thêm tham số trạng thái

  const OThongBao({
    super.key,
    required this.tieuDe,
    required this.noiDung,
    this.onTap,
    this.isRead = true, // 👈 Đặt giá trị mặc định là true (Đã đọc)
  });

  @override
  Widget build(BuildContext context) {
    // 1. Xác định giao diện dựa trên isRead
    final Color backgroundColor = isRead ? Colors.white : Colors.lightBlue.shade50; 
    final FontWeight titleFontWeight = isRead ? FontWeight.w500 : FontWeight.w700; 
    final Color titleColor = isRead ? Colors.black87 : Colors.blue.shade800; 

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor, // 👈 Áp dụng màu nền
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isRead ? 0.08 : 0.12),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: isRead
              ? null
              : Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1.0), // Viền nhẹ cho chưa đọc
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon thông báo
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.blueAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Nội dung thông báo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tieuDe,
                    style: TextStyle(
                      fontWeight: titleFontWeight, // 👈 Áp dụng độ đậm
                      fontSize: 16,
                      color: titleColor, // 👈 Áp dụng màu chữ
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    noiDung,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Dấu chấm tròn (Indicator) cho thông báo chưa đọc
            if (!isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 5),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // Mũi tên
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}