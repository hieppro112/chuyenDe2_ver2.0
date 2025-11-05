class message {
  final String id_message;
  final String chat_id;
  final String sender_id;
  final String? content;
  final String? media_url;
  final DateTime create_at;

  message({required this.id_message, required this.chat_id, required this.sender_id,  this.content,  this.media_url, required this.create_at});

  

}