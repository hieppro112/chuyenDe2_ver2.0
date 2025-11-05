class Posts {
  final String id_post;
  final String user_id;
  final String group_id;
  final String content;
  final String? file_url;
  final DateTime date_created;
  final int status_id;

  Posts({
    required this.id_post,
    required this.user_id,
    required this.group_id,
    required this.content,
    this.file_url,
    required this.date_created,
    required this.status_id,
  });
}
