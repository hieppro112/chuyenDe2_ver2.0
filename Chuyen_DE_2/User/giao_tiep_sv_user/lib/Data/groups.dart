class Groups {
  final String id_group;
  final String name;
  final String? description;
  final String created_by;
  final bool approval_mode;
  final int faculty_id;
  final int member_quantity;
  final String? avt;
  final int type_id;

  Groups({
    required this.id_group,
    required this.name,
    this.description,
    required this.created_by,
    required this.approval_mode,
    required this.faculty_id,
    required this.member_quantity,
    this.avt,
    required this.type_id,
  });
}
