import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/Notifycation.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/notifycationFirebase.dart';
import 'package:giao_tiep_sv_user/ThongBao/chi_tiet_thong_bao.dart';
import 'package:giao_tiep_sv_user/Widget/headerWidget.dart';
import 'TieuDe.dart';
import 'OThongBao.dart';

class ManHinhThongBao extends StatefulWidget {
  final Users currentUser;
  final Notifycationfirebase notifyService = Notifycationfirebase();

  ManHinhThongBao({required this.currentUser, super.key});

  @override
  State<ManHinhThongBao> createState() => _ManHinhThongBaoState();
}

class _ManHinhThongBaoState extends State<ManHinhThongBao> {
  void _handleNotificationTap(Notifycation tb) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChiTietThongBao(
          tieuDe: tb.title,
          noiDung: tb.content,
        ),
      ),
    );
  }

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
                myUs: widget.currentUser,
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

              Expanded(
                child: StreamBuilder<List<Notifycation>>(
                  stream: widget.notifyService.getAllNotifycation(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Lỗi: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Không có thông báo nào"));
                    }

                    final allNotify = snapshot.data!;
                    final userId = widget.currentUser.id_user;
                    final facultyId = widget.currentUser.faculty_id;

                    // Lọc thông báo cho user hiện tại
                    final notifyForUser = allNotify.where((tb) {
                      final recipients = tb.user_recipient_ID.keys.toSet();
                      final matchUser = recipients.contains(userId);
                      final matchFaculty = facultyId != null && recipients.contains(facultyId);
                      return matchUser || matchFaculty;
                    }).toList()
                      // Sort mới nhất lên đầu dựa theo id Firestore
                      ..sort((a, b) => b.id.compareTo(a.id));

                    if (notifyForUser.isEmpty) {
                      return const Center(
                        child: Text("Không có thông báo dành cho bạn"),
                      );
                    }

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
                            onTap: () => _handleNotificationTap(tb),
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
