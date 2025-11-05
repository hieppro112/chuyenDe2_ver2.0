class SavedItemModel {
  final String id;
  final String title;
  final String author;
  final String image;
  final String type; // 'post', 'video', etc.
  final DateTime savedAt;

  SavedItemModel({
    required this.id,
    required this.title,
    required this.author,
    required this.image,
    this.type = 'post',
    required this.savedAt,
  });

  // Factory method để tạo từ Map (dễ dàng cho mock data)
  factory SavedItemModel.fromMap(Map<String, dynamic> map) {
    return SavedItemModel(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      image: map['image'] ?? '',
      type: map['type'] ?? 'post',
      savedAt: map['savedAt'] ?? DateTime.now(),
    );
  }
}
