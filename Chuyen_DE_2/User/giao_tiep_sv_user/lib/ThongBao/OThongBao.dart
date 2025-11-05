import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Widget/headerWidget.dart';
import 'chi_tiet_thong_bao.dart';

class OThongBao extends StatelessWidget {
  final String tieuDe;
  final String noiDung;

  const OThongBao({
    super.key,
    required this.tieuDe,
    required this.noiDung,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChiTietThongBao(
              tieuDe: tieuDe,
              noiDung: noiDung,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFDDE8FF),
              child: Icon(Icons.person, color: Colors.blue),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tieuDe,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
               
                  Text(
                    noiDung,
                    style: const TextStyle(color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.circle, color: Colors.red, size: 10),
          ],
        ),
      ),
    );
  }
}
