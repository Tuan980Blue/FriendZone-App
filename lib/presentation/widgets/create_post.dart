import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../domain/usecases/posts/create_post_usecase.dart';
import '../../domain/usecases/posts/upload_image_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/entities/user.dart';
import '../../di/injection_container.dart';
import 'common/custom_snackbar.dart';

class CreatePostEntry extends StatelessWidget {
  const CreatePostEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final GetCurrentUserUseCase getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
    return FutureBuilder<User>(
      future: getCurrentUserUseCase(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final user = snapshot.data!;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CreatePostModal(user: user),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                            ? NetworkImage(user.avatar!)
                            : null,
                        radius: 22,
                        backgroundColor: Colors.grey.shade100,
                        child: (user.avatar == null || user.avatar!.isEmpty)
                            ? Icon(Icons.person, size: 26, color: Colors.grey.shade600)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${user.fullName.isNotEmpty ? user.fullName : user.username} ơi, bạn đang nghĩ gì thế?',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CreatePostModal extends StatefulWidget {
  final User user;
  const CreatePostModal({super.key, required this.user});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  bool _hasUnsavedContent = false;

  void _updateUnsavedContent(bool hasContent) {
    setState(() {
      _hasUnsavedContent = hasContent;
    });
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedContent) {
      return await _showExitConfirmationDialog();
    }
    return true;
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon
                      Container(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red.shade600,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Bỏ bài viết?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Bạn có nội dung chưa đăng. Bạn có chắc chắn muốn bỏ bài viết này không?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(
                        height: 1,
                        color: Colors.grey.shade100,
                      ),
                      // Action buttons
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).pop(false),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Tiếp tục',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Vertical divider
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey.shade100,
                          ),
                          // Confirm button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).pop(true),
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Bỏ bài viết',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ) ?? false;
  }

  Future<void> _handleClose() async {
    if (_hasUnsavedContent) {
      final shouldExit = await _showExitConfirmationDialog();
      if (shouldExit) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.7,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Close button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _handleClose,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade700,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Title
                      Text(
                        'Tạo bài viết',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const Spacer(),
                      // Balance the close button
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                // User info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      // User avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundImage: widget.user.avatar != null && widget.user.avatar!.isNotEmpty
                              ? NetworkImage(widget.user.avatar!)
                              : null,
                          radius: 26,
                          backgroundColor: Colors.grey.shade100,
                          child: (widget.user.avatar == null || widget.user.avatar!.isEmpty)
                              ? Icon(Icons.person, size: 30, color: Colors.grey.shade600)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // User info and privacy selector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.fullName.isNotEmpty ? widget.user.fullName : widget.user.username,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            PrivacySelector(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content area
                Expanded(
                  child: CreatePostWidget(
                    onContentChanged: _updateUnsavedContent,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PrivacySelector extends StatefulWidget {
  @override
  _PrivacySelectorState createState() => _PrivacySelectorState();
}

class _PrivacySelectorState extends State<PrivacySelector> {
  String _selectedPrivacy = 'Công khai';
  final List<Map<String, dynamic>> _privacyOptions = [
    {
      'name': 'Công khai',
      'icon': Icons.public,
      'color': Colors.pink,
      'description': 'Mọi người có thể xem'
    },
    {
      'name': 'Bạn bè',
      'icon': Icons.people,
      'color': Colors.blue,
      'description': 'Chỉ bạn bè có thể xem'
    },
    {
      'name': 'Chỉ mình tôi',
      'icon': Icons.lock,
      'color': Colors.black54,
      'description': 'Chỉ bạn có thể xem'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedOption = _privacyOptions.firstWhere(
      (option) => option['name'] == _selectedPrivacy,
    );

    return GestureDetector(
      onTap: () => _showPrivacyDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectedOption['icon'],
              size: 16,
              color: selectedOption['color'],
            ),
            const SizedBox(width: 6),
            Text(
              selectedOption['name'],
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Text(
                          'Ai có thể xem bài viết này?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      // Divider
                      Container(
                        height: 1,
                        color: Colors.grey.shade100,
                      ),
                      // Options
                      ..._privacyOptions.map((option) {
                        final isSelected = option['name'] == _selectedPrivacy;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  _selectedPrivacy = option['name'];
                                });
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? Colors.blue.shade200 : Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: option['color'].withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        option['icon'],
                                        color: option['color'],
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            option['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            option['description'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CreatePostWidget extends StatefulWidget {
  final Function(bool) onContentChanged;
  const CreatePostWidget({super.key, required this.onContentChanged});

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  bool _isLoading = false;
  bool _showEmojiPicker = false;
  String? _selectedLocation;
  
  final CreatePostUseCase _createPostUseCase = sl<CreatePostUseCase>();
  final UploadImageUseCase _uploadImageUseCase = sl<UploadImageUseCase>();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
    
    // Add listener to content controller
    _contentController.addListener(_checkContentChanged);
  }

  void _checkContentChanged() {
    final hasContent = _contentController.text.isNotEmpty || _selectedImages.isNotEmpty;
    widget.onContentChanged(hasContent);
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });

        for (int i = 0; i < images.length; i++) {
          var image = images[i];
          
          final file = File(image.path);
          
          setState(() {
            _selectedImages.add(file);
          });
          _checkContentChanged(); // Notify parent about content change

          try {
            final url = await _uploadImageUseCase(file);
            
            if (url != null) {
              setState(() {
                _uploadedImageUrls.add(url);
              });
            } else {
              setState(() {
                _selectedImages.remove(file);
              });
              _checkContentChanged(); // Notify parent about content change
              CustomSnackBar.showError(
                context: context,
                message: 'Không thể tải lên một số ảnh',
              );
            }
          } catch (e) {
            setState(() {
              _selectedImages.remove(file);
            });
            _checkContentChanged(); // Notify parent about content change
          }
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: 'Lỗi khi chọn ảnh: $e',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _isLoading = true;
        });

        final file = File(photo.path);
        setState(() {
          _selectedImages.add(file);
        });
        _checkContentChanged(); // Notify parent about content change

        try {
          final url = await _uploadImageUseCase(file);
          
          if (url != null) {
            setState(() {
              _uploadedImageUrls.add(url);
            });
          } else {
            setState(() {
              _selectedImages.remove(file);
            });
            _checkContentChanged(); // Notify parent about content change
            CustomSnackBar.showError(
              context: context,
              message: 'Không thể tải lên ảnh',
            );
          }
        } catch (e) {
          setState(() {
            _selectedImages.remove(file);
          });
          _checkContentChanged(); // Notify parent about content change
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: 'Lỗi khi chụp ảnh: $e',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Chọn ảnh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 24),
            // Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Chụp ảnh',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).pop();
                        _takePhoto();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Thư viện',
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImages();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker() {
    // Mock location picker - in real app, integrate with Google Places API
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Text(
                          'Chọn vị trí',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      // Divider
                      Container(
                        height: 1,
                        color: Colors.grey.shade100,
                      ),
                      // Location options
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            _buildLocationOption(
                              'Hà Nội, Việt Nam',
                              'Thủ đô Việt Nam',
                              onTap: () {
                                setState(() {
                                  _selectedLocation = 'Hà Nội, Việt Nam';
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                            _buildLocationOption(
                              'TP. Hồ Chí Minh, Việt Nam',
                              'Thành phố lớn nhất Việt Nam',
                              onTap: () {
                                setState(() {
                                  _selectedLocation = 'TP. Hồ Chí Minh, Việt Nam';
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                            _buildLocationOption(
                              'Đà Nẵng, Việt Nam',
                              'Thành phố đáng sống',
                              onTap: () {
                                setState(() {
                                  _selectedLocation = 'Đà Nẵng, Việt Nam';
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(
                        height: 1,
                        color: Colors.grey.shade100,
                      ),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedLocation = null;
                                  });
                                  Navigator.of(context).pop();
                                },
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Xóa vị trí',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey.shade100,
                          ),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Hủy',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationOption(String title, String subtitle, {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.red.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    if (_contentController.text.isEmpty && _uploadedImageUrls.isEmpty) {
      CustomSnackBar.showError(
        context: context,
        message: 'Vui lòng thêm nội dung hoặc ảnh',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _createPostUseCase(CreatePostParams(
        content: _contentController.text,
        imageUrls: _uploadedImageUrls,
      ));

      CustomSnackBar.showSuccess(
        context: context,
        message: 'Đăng bài thành công!',
      );
      _contentController.clear();
      setState(() {
        _selectedImages.clear();
        _uploadedImageUrls.clear();
        _selectedLocation = null;
      });
      _checkContentChanged(); // Reset unsaved content state
      Navigator.of(context).pop();
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: 'Lỗi khi tạo bài viết: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = _contentController.text.isNotEmpty || _selectedImages.isNotEmpty;
    
    return Column(
      children: [
        // Content TextField
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  focusNode: _focusNode,
                  maxLines: null,
                  minLines: 8,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Bạn đang nghĩ gì?',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                // Location display
                if (_selectedLocation != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.red.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedLocation!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLocation = null;
                            });
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.red.shade600,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Image Preview
                if (_selectedImages.isNotEmpty) ...[
                  Container(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _selectedImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                        _uploadedImageUrls.removeAt(index);
                                      });
                                      _checkContentChanged(); // Notify parent about content change
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    iconSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
        // Emoji Picker
        if (_showEmojiPicker) ...[
          Container(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                setState(() {
                  _contentController.text += emoji.emoji;
                });
                _checkContentChanged(); // Notify parent about content change
              },
              config: Config(
                columns: 7,
                emojiSizeMax: 28,
                bgColor: Colors.grey.shade50,
              ),
            ),
          ),
        ],
        // Bottom Actions
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade100,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Action buttons
              Row(
                children: [
                  // Image Picker Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _isLoading ? null : _showImageSourceDialog,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.blue.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ảnh',
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Emoji Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              _showEmojiPicker = !_showEmojiPicker;
                            });
                            if (_showEmojiPicker) {
                              _focusNode.unfocus();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: Colors.orange.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Cảm xúc',
                                  style: TextStyle(
                                    color: Colors.orange.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Location Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _showLocationPicker,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.red.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Vị trí',
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Post Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: hasContent
                          ? LinearGradient(
                              colors: [
                                Colors.blue.shade500,
                                Colors.blue.shade600,
                              ],
                            )
                          : null,
                      color: hasContent ? null : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: hasContent
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isLoading || !hasContent ? null : _createPost,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Đăng',
                                  style: TextStyle(
                                    color: hasContent ? Colors.white : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _contentController.removeListener(_checkContentChanged);
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
} 