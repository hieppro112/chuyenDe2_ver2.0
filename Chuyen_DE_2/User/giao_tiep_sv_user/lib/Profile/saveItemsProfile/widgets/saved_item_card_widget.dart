// saved_item_card_widget.dart
import 'package:flutter/material.dart';
import '../models/saved_item_model.dart';
import 'more_options_button_widget.dart';

class SavedItemCardWidget extends StatelessWidget {
  final SavedItemModel item;
  final Function(String) onDelete;
  final int index;
  final VoidCallback onTap; // THÊM: Callback khi click vào card

  const SavedItemCardWidget({
    super.key,
    required this.item,
    required this.onDelete,
    required this.index,
    required this.onTap, // Bắt buộc truyền vào
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        // Dùng Material để có hiệu ứng ripple
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap, // Click toàn bộ card
          child: Stack(
            children: [
              Row(
                children: [
                  // Hình ảnh
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: _buildImageWidget(),
                  ),
                  const SizedBox(width: 10),
                  // Thông tin bài viết
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // HIỂN THỊ TÊN USER
                          Row(
                            children: [
                              Text(
                                item.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 5),
                              // HIỂN THỊ KHOA
                              Text(
                                "• Khoa: ${item.userFaculty}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // HIỂN THỊ BÀI VIẾT
                          const SizedBox(height: 5),
                          Text(
                            "Bài viết: ${item.title}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _formatDate(item.savedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Xóa bài viết
              Positioned(
                top: 0,
                right: 0,
                child: MoreOptionsButtonWidget(
                  itemTitle: item.title,
                  postId: item.id,
                  onDelete: onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (item.image != null && item.image!.isNotEmpty) {
      return Image.network(
        item.image!,
        width: 90,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholderImage();
        },
      );
    } else {
      return _placeholderImage();
    }
  }

  Widget _placeholderImage() {
    return Container(
      width: 90,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Không rõ ngày";
    return '${date.day}/${date.month}/${date.year}';
  }
}
