// lib/widgets/DangBaiDialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../FireBase_Service/create_post.dart';
import '../../../Data/global_state.dart';

// ======== UPLOAD SERVICE (giữ nguyên hoặc thêm vào file riêng) ========
class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(File file, String userId) async {
    final fileName = file.path.split('/').last;
    final now = DateTime.now().millisecondsSinceEpoch;
    final path = 'groups/$userId/$now-$fileName';

    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("Upload thành công: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Lỗi upload: $e");
      return null;
    }
  }
}
// ====================================================================

class DangBaiDialog extends StatefulWidget {
  final List<String> availableGroups;
  const DangBaiDialog({super.key, required this.availableGroups});

  @override
  State<DangBaiDialog> createState() => _DangBaiDialogState();
}

class _DangBaiDialogState extends State<DangBaiDialog> {
  final CreatePostService _createPostService = CreatePostService();
  final String? userId = GlobalState.currentUserId;
  final UploadService _uploadService = UploadService();

  late String selectedGroup;
  final TextEditingController contentController = TextEditingController();

  List<File> selectedImages = [];
  List<String> selectedFileNames = [];
  List<File> selectedFiles = []; // Lưu File thực để upload
  String? firstImagePath;

  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    selectedGroup =
        widget.availableGroups.isNotEmpty &&
            widget.availableGroups.first != "Tất cả"
        ? widget.availableGroups.first
        : (widget.availableGroups.length > 1
              ? widget.availableGroups[1]
              : 'CNTT');
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        selectedImages.addAll(picked.map((x) => File(x.path)));
        selectedFileNames.clear();
        selectedFiles.clear();
        firstImagePath = selectedImages.first.path;
      });
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFiles = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
        selectedFileNames = result.files.map((f) => f.name).toList();
        selectedImages.clear();
        firstImagePath = null;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
      if (selectedImages.isEmpty) firstImagePath = null;
    });
  }

  void _removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
      selectedFileNames.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    final content = contentController.text.trim();

    if (content.isEmpty && selectedImages.isEmpty && selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập nội dung hoặc chọn tệp!")),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lỗi: Chưa đăng nhập!")));
      return;
    }

    setState(() => _isUploading = true);

    List<String> imageUrls = [];
    String? fileUrl;

    try {
      // Upload ảnh
      if (selectedImages.isNotEmpty) {
        final futures = selectedImages.map(
          (img) => _uploadService.uploadFile(img, userId!),
        );
        final results = await Future.wait(futures);
        imageUrls = results.whereType<String>().toList();

        if (imageUrls.length != selectedImages.length) {
          throw Exception("Một số ảnh không tải lên được");
        }
      }

      // Upload file đính kèm (chỉ 1 file đầu tiên)
      if (selectedFiles.isNotEmpty) {
        final url = await _uploadService.uploadFile(
          selectedFiles.first,
          userId!,
        );
        if (url != null) fileUrl = url;
      }

      // Đăng bài
      final success = await _createPostService.uploadPost(
        currentUserId: userId!,
        content: content,
        groupId: selectedGroup,
        imageUrls: imageUrls,
        fileUrl: fileUrl,
      );

      if (!success) throw Exception("Đăng bài thất bại");

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng bài thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E88E5);
    final hasAttachments =
        selectedImages.isNotEmpty || selectedFileNames.isNotEmpty;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đăng Bài Viết Mới',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),

              // Nội dung
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: "Bạn đang nghĩ gì? Chia sẻ ngay...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Đính kèm
              const Text(
                'Đính kèm:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Chọn ảnh',
                      child: IconButton(
                        icon: const Icon(Icons.image, color: primaryColor),
                        onPressed: _pickImages,
                      ),
                    ),
                    Tooltip(
                      message: 'Chọn file',
                      child: IconButton(
                        icon: const Icon(
                          Icons.attach_file,
                          color: primaryColor,
                        ),
                        onPressed: _pickFiles,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hasAttachments
                            ? 'Đã chọn ${selectedImages.length + selectedFileNames.length} tệp'
                            : 'Chưa có tệp nào',
                        style: TextStyle(
                          color: hasAttachments ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Hiển thị ảnh
              if (selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: selectedImages.length,
                    itemBuilder: (ctx, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            selectedImages[i],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeImage(i),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Hiển thị file
              if (selectedFileNames.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    children: selectedFileNames.asMap().entries.map((e) {
                      return Chip(
                        label: Text(e.value, overflow: TextOverflow.ellipsis),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeFile(e.key),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 20),

              // Chọn nhóm
              const Text(
                'Chọn nhóm:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedGroup,
                items: widget.availableGroups.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (v) => setState(() => selectedGroup = v!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Nút hành động
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    child: _isUploading
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("Đang đăng..."),
                            ],
                          )
                        : const Text(
                            "Đăng Bài",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
