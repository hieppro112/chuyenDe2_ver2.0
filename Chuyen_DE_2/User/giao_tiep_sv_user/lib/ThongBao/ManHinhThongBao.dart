import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/Notifycation.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/notifycationFirebase.dart';
import 'package:giao_tiep_sv_user/ThongBao/chi_tiet_thong_bao.dart';
import 'package:giao_tiep_sv_user/Widget/headerWidget.dart';
import 'TieuDe.dart';
import 'OThongBao.dart';

class ManHinhThongBao extends StatelessWidget {
  final Users currentUser;
  final Notifycationfirebase notifyService = Notifycationfirebase();

  ManHinhThongBao({required this.currentUser, super.key});

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
              // Header với nút back
              Headerwidget(
                myUs: currentUser,
                width: widthScreen,
                chucnang: GestureDetector(
                  onTap: () => Navigator.pop(context),
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

              // Danh sách thông báo
              Expanded(
                child: StreamBuilder<List<Notifycation>>(
                  stream: notifyService.getAllNotifycation(),
                  builder: (context, snapshot) {
                    // 1. Đang tải
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 2. Lỗi kết nối
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Lỗi: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    // 3. Không có dữ liệu
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Không có thông báo nào"));
                    }

                    final allNotify = snapshot.data!;
                    print("Tổng số thông báo từ Firestore: ${allNotify.length}");
                    print("User ID: ${currentUser.id_user}, Faculty ID: ${currentUser.faculty_id}");

                    // 4. Lọc thông báo dành cho user hiện tại
                    final notifyForUser = allNotify.where((tb) {
                      final recipientKeys = tb.user_recipient_ID.keys.toSet();

                      final matchUser = recipientKeys.contains(currentUser.id_user);
                      final matchFaculty = currentUser.faculty_id != null &&
                          recipientKeys.contains(currentUser.faculty_id);

                      // Debug từng thông báo
                      print(
                        "TB: '${tb.title}' → Có trong user: $matchUser | Có trong khoa: $matchFaculty "
                        "| Recipients: ${recipientKeys.join(', ')}",
                      );

                      return matchUser || matchFaculty;
                    }).toList();

                    // 5. Không có thông báo phù hợp
                    if (notifyForUser.isEmpty) {
                      return const Center(
                        child: Text("Không có thông báo dành cho bạn"),
                      );
                    }

                    // 6. Hiển thị danh sách
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: notifyForUser.length,
                      itemBuilder: (context, index) {
                        final tb = notifyForUser[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OThongBao(
                            tieuDe: tb.title,
                            noiDung: tb.content,
                            onTap : () {
                              // Có thể mở chi tiết thông báo
                             Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChiTietThongBao(
                                    tieuDe: tb.title,
                                    noiDung: tb.content,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
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