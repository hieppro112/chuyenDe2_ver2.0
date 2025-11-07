import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Widget/headerWidget.dart';
import 'TieuDe.dart';
import 'OThongBao.dart';

class ManHinhThongBao extends StatelessWidget {
  ManHinhThongBao({super.key});
  // dữ liệu giả
  final List<Map<String, String>> danhSachThongBao = [
    {
      "tieuDe": "Thông báo lịch thi học kỳ",
      "noiDung":
          "Lịch thi học kỳ 1 năm học 2025-2026 đã được cập nhật. Sinh viên vui lòng kiểm tra và thực hiện đúng lịch thi.",
    },
    {
      "tieuDe": "Đăng ký học bổng",
      "noiDung":
          "Thông báo về việc đăng ký xét học bổng khuyến khích học tập học kỳ 1 năm học 2025-2026. Hạn chót: 30/11/2025.",
    },
    {
      "tieuDe": "Chuyên đề",
      "noiDung":
          "Mời sinh viên tham dự buổi seminar 'Trí tuệ nhân tạo trong phát triển phần mềm' vào ngày 25/10/2025.",
    },
    {
      "tieuDe": "Thông báo mượn sách",
      "noiDung":
          "Nhắc nhở sinh viên trả sách đúng hạn. Các sách mượn quá hạn sẽ bị phạt theo quy định.",
    },
    {
      "tieuDe": "Thông báo học phí",
      "noiDung":
          "Thông báo đóng học phí học kỳ 1 năm học 2025-2026. Hạn đóng học phí: 15/11/2025.",
    },
    {
      "tieuDe": "Khảo sát ý kiến sinh viên",
      "noiDung":
          "Mời sinh viên tham gia khảo sát ý kiến về chất lượng giảng dạy và dịch vụ hỗ trợ sinh viên. Link khảo sát đã được gửi qua email.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Headerwidget(
                myUs: Users(
                  id_user: "abc",
                  email: "email",
                  fullname: "Le Dai Hiep",
                  url_avt: "https://media-cdn-v2.laodong.vn/Storage/NewsPortal/2021/10/30/969136/Cristiano-Ronaldo4.jpg",
                  role: 1,
                  faculty_id: "TT",
                ),
                width: widthScreen,
                chucnang: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/icons/ic_back.png",
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const TieuDeThongBao(),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: danhSachThongBao.length,
                  itemBuilder: (context, index) {
                    final thongBao = danhSachThongBao[index];
                    return OThongBao(
                      tieuDe: thongBao["tieuDe"]!,
                      noiDung: thongBao["noiDung"]!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
