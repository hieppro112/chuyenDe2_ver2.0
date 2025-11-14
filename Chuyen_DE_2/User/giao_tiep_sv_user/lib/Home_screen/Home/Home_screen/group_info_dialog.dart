import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/member_post_screen.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/view/maneger_member_group.dart';
import '../../../Data/global_state.dart'; // Cần import GlobalState

class GroupInfoDialog extends StatelessWidget {
  final String groupName;
  final String currentGroupId;
  final int currentUserRole;
  final String groupOwnerId;

  const GroupInfoDialog({
    super.key,
    required this.groupName,
    required this.currentGroupId,
    required this.currentUserRole,
    required this.groupOwnerId,
  });

  bool get isOwner {
    return groupOwnerId.isNotEmpty && groupOwnerId == GlobalState.currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Thông tin $groupName",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ======= Các tùy chọn chính =======
            if (isOwner)
              _buildOption(
                context,
                Icons.check_circle,
                "Duyệt",
                Colors.green,
                currentGroupId,
              ),

            _buildOption(
              context,
              Icons.group,
              "Thành viên",
              Colors.blue,
              currentGroupId,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Đóng"),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
    String groupId,
  ) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);

        if (text == "Duyệt") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberPostScreen(
                groupId: currentGroupId, // ← Truyền groupId
              ),
            ),
          );
          return;
        } else if (text == "Thành viên") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManegerMemberGroupScreen()),
          );
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Đã chọn: $text")));
      },
    );
  }
}
