class Notifycation {
  final String id;
  final int type_notify;
  final String title;
  final String content;
  final Map<String, dynamic> user_recipient_ID;

  Notifycation(
    this.title, {
    required this.id,
    required this.type_notify,
    required this.content,
    required this.user_recipient_ID,
  });

  Map<String, dynamic> tomap() {
    return {
      'id': id,
      "type_notify": type_notify,
      "title": title,
      'content': content,
      "user_recipient_id": user_recipient_ID,
    };
  }

  // // tao group
  //   factory Group.fromMap(Map<String, dynamic> map) {
  //     return Group(
  //       id: map['id'] ?? '',
  //       name: map['name'] ?? '',
  //       description: map['description'] ?? '',
  //       created_by: Map<String, String>.from(map['created_by'] ?? []),
  //       approval_mode: map['approval_mode'] ?? false,
  //       avt: map['avt'] ?? '',
  //       type_group: map['type_group'] ?? 0,
  //     );
  //   }
}
