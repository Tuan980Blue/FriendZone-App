import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../di/injection_container.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/storys/create_story_usecase.dart';
import '../../../domain/usecases/storys/upload_story_media_usecase.dart';
import '../common/custom_snackbar.dart';

class StoryOptionDialog extends StatefulWidget {
  final User user;

  const StoryOptionDialog({
    super.key,
    required this.user,
  });

  @override
  State<StoryOptionDialog> createState() => _StoryOptionDialogState();
}

class _StoryOptionDialogState extends State<StoryOptionDialog> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _recentImages;
  bool _isLoadingImages = true;

  final _formKey = GlobalKey<FormState>();
  String _mediaType = 'IMAGE';
  String _location = '';
  String _filter = 'Normal';
  bool _isCreatingStory = false;

  @override
  void initState() {
    super.initState();
    _loadRecentImages();
  }

  Future<void> _loadRecentImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(limit: 20);
      setState(() {
        _recentImages = images;
        _isLoadingImages = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingImages = false;
      });
      debugPrint('Error loading images: $e');
    }
  }

  void _showStoryCreationForm(File imageFile) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          child: SizedBox.expand(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Tạo tin mới'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          imageFile,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Media Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _mediaType,
                        items: ['IMAGE', 'VIDEO']
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _mediaType = val ?? 'IMAGE'),
                        decoration: const InputDecoration(
                          labelText: 'Loại media',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location Input
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Vị trí',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => _location = val,
                      ),
                      const SizedBox(height: 16),

                      // Filter Dropdown
                      DropdownButtonFormField<String>(
                        value: _filter,
                        items: ['Normal', 'BlackWhite', 'Sepia']
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _filter = val ?? 'Normal'),
                        decoration: const InputDecoration(
                          labelText: 'Bộ lọc',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (_isCreatingStory) return;
                              if (!_formKey.currentState!.validate()) return;

                              final uploadUseCase = sl<UploadStoryMediaUseCase>();
                              final createUseCase = sl<CreateStoryUseCase>();

                              final mediaUrl = await uploadUseCase.call(imageFile);
                              if (mediaUrl == null) {
                                Navigator.pop(context);
                                CustomSnackBar.showError(
                                  context: context,
                                  message: "Không thể tải lên media",
                                );
                                return;
                              }

                              try {
                                await createUseCase.call(
                                  CreateStoryParams(
                                    mediaUrl: mediaUrl,
                                    mediaType: _mediaType,
                                    location: _location,
                                    filter: _filter,
                                    isHighlighted: false,
                                  ),
                                );
                                Navigator.pop(context);
                                Navigator.pop(context);
                                CustomSnackBar.showSuccess(
                                  context: context,
                                  message: "Tạo tin thành công",
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                CustomSnackBar.showError(
                                  context: context,
                                  message: "Lỗi khi tạo tin",
                                );
                              }
                            },
                            child: const Text('Tạo tin'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 9),
                _buildHorizontalOptions(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Thư viện',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _isLoadingImages
                      ? const Center(child: CircularProgressIndicator())
                      : _recentImages == null || _recentImages!.isEmpty
                      ? const Center(child: Text('Không có ảnh trong thư viện'))
                      : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _recentImages!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showStoryCreationForm(File(_recentImages![index].path));
                        },
                        child: Image.file(
                          File(_recentImages![index].path),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: SizedBox(
                width: 64,
                height: 64,
                child: FloatingActionButton(
                  onPressed: () async {
                    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                    if (photo != null) {
                      _showStoryCreationForm(File(photo.path));
                    }
                  },
                  child: const Icon(Icons.camera_alt, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          'Tạo tin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.settings, size: 24),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHorizontalOptions() {
    const options = [
      {'icon': Icons.text_fields, 'label': 'Văn bản'},
      {'icon': Icons.music_note, 'label': 'Nhạc'},
      {'icon': Icons.loop, 'label': 'Boomerang'},
      {'icon': Icons.photo_library, 'label': 'Mẫu'},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(options[index]['icon'] as IconData),
                ),
                const SizedBox(height: 4),
                Text(
                  options[index]['label'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
