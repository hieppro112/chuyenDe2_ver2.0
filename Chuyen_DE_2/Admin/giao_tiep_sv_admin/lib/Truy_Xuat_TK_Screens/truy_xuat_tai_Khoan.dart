import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/widget/customSearch.dart';
import 'chi_tiet_tai_khoan.dart';

class TruyXuatTaiKhoan extends StatefulWidget {
  const TruyXuatTaiKhoan({super.key});

  @override
  State<TruyXuatTaiKhoan> createState() => _TruyXuatTaiKhoanState();
}

class _TruyXuatTaiKhoanState extends State<TruyXuatTaiKhoan> {
  String selectedKhoa = "Khoa Công Nghệ Thông Tin";
  final TextEditingController _searchController = TextEditingController();

  final List<String> khoaList = [
    "Khoa Công Nghệ Thông Tin",
    "Khoa Kinh tế",
    "Khoa Cơ khí",
    "Khoa Điện - Điện tử",
    "Khoa Đông Phương",
    "Khoa Động Lực",
    "Khoa Quản trị kinh doanh",
    "Khoa Du lịch",
  ];

  final List<Map<String, String>> _accountData = [
    // Khoa Công Nghệ Thông Tin
    {
      "username": "Lê Đình Thuận",
      "id": "23211TT1371",
      "khoa": "Khoa Công Nghệ Thông Tin",
      "email": "23211TT1371@mail.tdc.edu.vn",
    },
    {
      "username": "Lê Đại Hiệp",
      "id": "23211TM1324",
      "khoa": "Khoa Công Nghệ Thông Tin",
      "email": "23211TM1324@mail.tdc.edu.vn",
    },
    {
      "username": "Nguyễn Văn Bình",
      "id": "23211DH1001",
      "khoa": "Khoa Công Nghệ Thông Tin",
      "email": "23211DH1001@mail.tdc.edu.vn",
    },

    // Khoa Kinh tế
    {
      "username": "Cao Quang Khánh",
      "id": "24211KT4567",
      "khoa": "Khoa Kinh tế",
      "email": "24211KT4567@mail.tdc.edu.vn",
    },
    {
      "username": "Phạm Thị Hương",
      "id": "24211KT4588",
      "khoa": "Khoa Kinh tế",
      "email": "24211KT4588@mail.tdc.edu.vn",
    },
    {
      "username": "Trần Văn Long",
      "id": "24211KT4599",
      "khoa": "Khoa Kinh tế",
      "email": "24211KT4599@mail.tdc.edu.vn",
    },

    // Khoa Cơ khí
    {
      "username": "Phạm Thắng",
      "id": "25211CK7890",
      "khoa": "Khoa Cơ khí",
      "email": "25211CK7890@mail.tdc.edu.vn",
    },
    {
      "username": "Ngô Minh Tuấn",
      "id": "25211CK7001",
      "khoa": "Khoa Cơ khí",
      "email": "25211CK7001@mail.tdc.edu.vn",
    },
    {
      "username": "Hoàng Thanh Tùng",
      "id": "25211CK7012",
      "khoa": "Khoa Cơ khí",
      "email": "25211CK7012@mail.tdc.edu.vn",
    },

    // Khoa Điện - Điện tử
    {
      "username": "Nguyễn Văn An",
      "id": "26211DD7890",
      "khoa": "Khoa Điện - Điện tử",
      "email": "26211DD7890@mail.tdc.edu.vn",
    },
    {
      "username": "Đỗ Quỳnh Anh",
      "id": "26211DD7013",
      "khoa": "Khoa Điện - Điện tử",
      "email": "26211DD7013@mail.tdc.edu.vn",
    },
    {
      "username": "Bùi Đức Huy",
      "id": "26211DD7024",
      "khoa": "Khoa Điện - Điện tử",
      "email": "26211DD7024@mail.tdc.edu.vn",
    },

    // Khoa Đông Phương
    {
      "username": "Võ Thị Hồng",
      "id": "27211TA7890",
      "khoa": "Khoa Đông Phương",
      "email": "27211TA7890@mail.tdc.edu.vn",
    },
    {
      "username": "Lê Thị Lan",
      "id": "27211TQ7005",
      "khoa": "Khoa Đông Phương",
      "email": "27211TQ7005@mail.tdc.edu.vn",
    },
    {
      "username": "Phan Minh Khoa",
      "id": "27211TN7016",
      "khoa": "Khoa Đông Phương",
      "email": "27211TN7016@mail.tdc.edu.vn",
    },

    // Khoa Động Lực
    {
      "username": "Nguyễn Thị Mai",
      "id": "28211OT6001",
      "khoa": "Khoa Động Lực",
      "email": "28211OT6001@mail.tdc.edu.vn",
    },
    {
      "username": "Trần Minh Đức",
      "id": "28211OT6022",
      "khoa": "Khoa Động Lực",
      "email": "28211OT6022@mail.tdc.edu.vn",
    },
    {
      "username": "Vũ Anh Dũng",
      "id": "28211OT6033",
      "khoa": "Khoa Động Lực",
      "email": "28211OT6033@mail.tdc.edu.vn",
    },

    // Khoa Quản trị kinh doanh
    {
      "username": "Trần Thu Hà",
      "id": "29211KD9001",
      "khoa": "Khoa Quản trị kinh doanh",
      "email": "29211KD9001@mail.tdc.edu.vn",
    },
    {
      "username": "Nguyễn Hữu Phước",
      "id": "29211KD9002",
      "khoa": "Khoa Quản trị kinh doanh",
      "email": "29211KD9002@mail.tdc.edu.vn",
    },
    {
      "username": "Phạm Quốc Huy",
      "id": "29211KD9003",
      "khoa": "Khoa Quản trị kinh doanh",
      "email": "29211KD9003@mail.tdc.edu.vn",
    },

    // Khoa Du lịch
    {
      "username": "Lê Thị Mai",
      "id": "30211DL1001",
      "khoa": "Khoa Du lịch",
      "email": "30211DL1001@mail.tdc.edu.vn",
    },
    {
      "username": "Hoàng Thị Ngọc",
      "id": "30211DL1002",
      "khoa": "Khoa Du lịch",
      "email": "30211DL1002@mail.tdc.edu.vn",
    },
    {
      "username": "Đặng Văn Phúc",
      "id": "30211DL1003",
      "khoa": "Khoa Du lịch",
      "email": "30211DL1003@mail.tdc.edu.vn",
    },
  ];

  List<Map<String, String>> _filteredAccounts = [];

  @override
  void initState() {
    super.initState();
    _locTheoKhoaVaTimKiem("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildDropdown(),
            const SizedBox(height: 20),
            _buildListHeader(),
            const SizedBox(height: 10),
            _buildAccountList(),
          ],
        ),
      ),
    );
  }

  //Hàm lọc dữ liệu theo khoa & từ khóa
  void _locTheoKhoaVaTimKiem(String query) {
    setState(() {
      _filteredAccounts = _accountData.where((account) {
        final name = account["username"]!.toLowerCase();
        final id = account["id"]!.toLowerCase();
        final khoa = account["khoa"];
        final search = query.toLowerCase();

        final matchKhoa = khoa == selectedKhoa;
        final matchSearch =
            name.contains(search) || id.contains(search) || search.isEmpty;

        return matchKhoa && matchSearch;
      }).toList();
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Truy Xuất Tài Khoản'),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Image.asset("assets/icons/ic_back.png", width: 32, height: 32),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: const [SizedBox(width: 48)],
    );
  }

  // Ô tìm kiếm
  Widget _buildSearchBar() {
    return Customsearch(onTap: (value) => _locTheoKhoaVaTimKiem(value));
  }

  // Dropdown chọn khoa
  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(66, 0, 0, 0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedKhoa,
          items: khoaList.map((khoa) {
            return DropdownMenuItem<String>(value: khoa, child: Text(khoa));
          }).toList(),
          onChanged: (newValue) {
            setState(() => selectedKhoa = newValue!);
            _locTheoKhoaVaTimKiem(_searchController.text);
          },
        ),
      ),
    );
  }

  // Tiêu đề danh sách + số lượng kết quả
  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Danh sách tài khoản",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          "Kết quả: ${_filteredAccounts.length}",
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  //  tài khoản
  Widget _buildAccountItem(Map<String, String> user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChiTietTaiKhoan(
              ten: user["username"]!,
              mssv: user["id"]!,
              khoa: user["khoa"]!,
              email: user["email"]!,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87, width: 1),
          borderRadius: BorderRadius.circular(18),
          color: const Color.fromARGB(255, 255, 250, 250),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                "assets/images/user.png",
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["username"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  user["id"]!,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Danh sách tài khoản
  Widget _buildAccountList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _filteredAccounts.length,
        itemBuilder: (context, index) {
          return _buildAccountItem(_filteredAccounts[index]);
        },
      ),
    );
  }
}
