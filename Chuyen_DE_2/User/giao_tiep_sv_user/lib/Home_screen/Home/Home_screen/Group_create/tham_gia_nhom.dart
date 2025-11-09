import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/Group_create/nhom_cua_toi.dart';
import '../left_panel.dart';
import 'tao_nhom_page.dart';

class ThamGiaNhomPage extends StatefulWidget {
  const ThamGiaNhomPage({super.key});

  @override
  State<ThamGiaNhomPage> createState() => _ThamGiaNhomPageState();
}

class _ThamGiaNhomPageState extends State<ThamGiaNhomPage> {
  bool _isOpen = false; // trạng thái menu trái

  final List<Map<String, dynamic>> groups = [
    {
      "name": "Mạng máy tính Khóa 23",
      "image": "https://cdn-icons-png.flaticon.com/512/888/888859.png",
    },
    {
      "name": "Giao lưu Java",
      "image": "https://cdn-icons-png.flaticon.com/512/226/226777.png",
    },
  ];

  void toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // 🔹 Nội dung chính
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.5,
                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: toggleMenu,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Tham Gia Nhóm",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.group, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NhomCuaToi(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TaoNhomPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // 🔹 Danh sách nhóm
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Ảnh nhóm
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    group["image"],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Tên nhóm và nút tham gia
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group["name"],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Đã gửi yêu cầu tham gia "${group["name"]}"',
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.handshake),
                                        label: const Text("Tham Gia"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.lightBlueAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 LeftPanel (menu trái)
          if (_isOpen)
            GestureDetector(
              onTap: toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Row(
                  children: [
                    LeftPanel(
                      onClose: toggleMenu,
                      isGroupPage: true,
                      // ✅ Callback nhận đủ (id, name)
                      onGroupSelected: (id, name) {
                        // Do đây là màn hình ThamGiaNhom, không cần xử lý gì thêm.
                      },
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
