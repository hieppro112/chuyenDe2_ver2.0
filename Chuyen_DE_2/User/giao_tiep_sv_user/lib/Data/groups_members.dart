class GroupMember {
  final String group_id;
  final String user_id;
  final int role_id;
  final int status_id;
  final String joined_at;

  GroupMember({
    required this.group_id,
    required this.user_id,
    required this.role_id,
    required this.status_id,
    required this.joined_at,
  });
}
