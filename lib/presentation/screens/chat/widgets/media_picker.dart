import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MediaPicker extends StatefulWidget {
  final Function(MediaType, String) onMediaSelected;

  const MediaPicker({super.key, required this.onMediaSelected});

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

enum MediaType { image, video, file, location }

class _MediaPickerState extends State<MediaPicker> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    setState(() => _isProcessing = true);
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        widget.onMediaSelected(MediaType.image, image.path);
      }
    } catch (e) {
      print('❌ Image pick error: $e');
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _pickVideo() async {
    setState(() => _isProcessing = true);
    try {
      final video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        widget.onMediaSelected(MediaType.video, video.path);
      }
    } catch (e) {
      print('❌ Video pick error: $e');
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _pickFile() async {
    setState(() => _isProcessing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'],
      );
      if (result != null && result.files.isNotEmpty) {
        widget.onMediaSelected(MediaType.file, result.files.first.path!);
      }
    } catch (e) {
      print('❌ File pick error: $e');
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'اختر وسائط',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _mediaOption(
                  icon: Icons.photo_library,
                  label: 'صورة',
                  color: Colors.purple,
                  onTap: _pickImage,
                ),
                _mediaOption(
                  icon: Icons.videocam,
                  label: 'فيديو',
                  color: Colors.blue,
                  onTap: _pickVideo,
                ),
                _mediaOption(
                  icon: Icons.picture_as_pdf,
                  label: 'ملف',
                  color: Colors.red,
                  onTap: _pickFile,
                ),
                _mediaOption(
                  icon: Icons.location_on,
                  label: 'موقع',
                  color: Colors.green,
                  onTap: () {
                    widget.onMediaSelected(MediaType.location, '');
                  },
                ),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _mediaOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
