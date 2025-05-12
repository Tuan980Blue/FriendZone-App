import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/usecases/posts/create_post_usecase.dart';
import '../../domain/usecases/posts/upload_image_usecase.dart';
import '../../di/injection_container.dart';

class CreatePostWidget extends StatefulWidget {
  const CreatePostWidget({super.key});

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController _contentController = TextEditingController();
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  bool _isLoading = false;
  
  final CreatePostUseCase _createPostUseCase = sl<CreatePostUseCase>();
  final UploadImageUseCase _uploadImageUseCase = sl<UploadImageUseCase>();

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });

        for (var image in images) {
          final file = File(image.path);
          setState(() {
            _selectedImages.add(file);
          });

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to upload some images')),
              );
            }
          } catch (e) {
            print('Error uploading image: $e');
            setState(() {
              _selectedImages.remove(file);
            });
          }
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createPost() async {
    if (_contentController.text.isEmpty && _uploadedImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content or images')),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );
      _contentController.clear();
      setState(() {
        _selectedImages.clear();
        _uploadedImageUrls.clear();
      });
    } catch (e) {
      print('Error in post creation process: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedImages.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.file(
                          _selectedImages[index],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                              _uploadedImageUrls.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: _isLoading ? null : _pickImages,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _createPost,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
} 