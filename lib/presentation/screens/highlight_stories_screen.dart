import 'package:flutter/material.dart';
import '../../../di/injection_container.dart';
import '../../../data/datasources/remote/story_remote_data_source.dart';
import '../../../data/models/story_model.dart';

class HighlightCreationScreen extends StatefulWidget {
  const HighlightCreationScreen({super.key});

  @override
  State<HighlightCreationScreen> createState() => _HighlightCreationScreenState();
}

class _HighlightCreationScreenState extends State<HighlightCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedStoryIds = {};
  List<StoryModel> _myStories = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchMyStories();
  }

  Future<void> _fetchMyStories() async {
    try {
      final stories = await sl<StoryRemoteDataSource>().fetchMyStories();
      setState(() {
        _myStories = stories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải tin: $e')),
      );
    }
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty && _selectedStoryIds.isNotEmpty && !_isSubmitting;

  Future<void> _submitHighlight() async {
    setState(() => _isSubmitting = true);
    try {
      await sl<StoryRemoteDataSource>().createHighlight(
        name: _nameController.text.trim(),
        storyIds: _selectedStoryIds.toList(),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã tạo tin nổi bật thành công')),
      );
    } catch (e) {
      debugPrint('Lỗi khi tạo tin nổi bật: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tạo tin nổi bật: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo tin nổi bật'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: _canSubmit ? _submitHighlight : null,
              style: TextButton.styleFrom(
                foregroundColor: _canSubmit ? Colors.pink : Colors.grey,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('Tạo'),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên tin nổi bật',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _myStories.length,
              itemBuilder: (context, index) {
                final story = _myStories[index];
                final isSelected = _selectedStoryIds.contains(story.id);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected
                          ? _selectedStoryIds.remove(story.id)
                          : _selectedStoryIds.add(story.id);
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          story.mediaUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.pink,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
