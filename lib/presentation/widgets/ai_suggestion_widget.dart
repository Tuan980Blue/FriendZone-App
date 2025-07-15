import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/ai_suggestion_service.dart';
import 'ai_chat_dialog.dart';

class AiSuggestionWidget extends StatefulWidget {
  final String postContent;
  final List<String>? imageUrls;
  final String? location;
  final String? authorName;
  final Function(String) onSuggestionTap;
  final String apiKey;

  const AiSuggestionWidget({
    Key? key,
    required this.postContent,
    this.imageUrls,
    this.location,
    this.authorName,
    required this.onSuggestionTap,
    required this.apiKey,
  }) : super(key: key);

  @override
  State<AiSuggestionWidget> createState() => _AiSuggestionWidgetState();
}

class _AiSuggestionWidgetState extends State<AiSuggestionWidget> {
  bool _loading = true;
  List<String> _suggestions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAiSuggestions();
  }

  Future<void> _fetchAiSuggestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = AiSuggestionService(apiKey: widget.apiKey);
      final questions = await service.fetchSuggestions(postContent: widget.postContent);
      setState(() {
        _suggestions = questions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể lấy gợi ý từ AI. Vui lòng thử lại.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: const [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Đang gợi ý câu hỏi...'),
          ],
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: _fetchAiSuggestions,
              tooltip: 'Thử lại',
            ),
          ],
        ),
      );
    }
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.blueAccent.withOpacity(0.12)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.blueAccent, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'AI gợi ý câu hỏi:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFamily: 'Roboto', // hoặc GoogleFonts.nunito nếu có
                    color: Colors.blueAccent,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: _suggestions.map((s) => ActionChip(
                avatar: const Icon(Icons.smart_toy, color: Colors.blueAccent, size: 18),
                backgroundColor: Colors.blue[50],
                label: Text(
                  s,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Roboto', // hoặc GoogleFonts.nunito nếu có
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.blueAccent, width: 0.5),
                ),
                elevation: 1,
                onPressed: () {
                  widget.onSuggestionTap(s);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => DraggableScrollableSheet(
                      initialChildSize: 0.7,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      expand: false,
                      builder: (_, __) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        child: AIChatDialog(
                          initialQuestion: s,
                          apiKey: widget.apiKey,
                          title: 'Hỏi AI về: "$s"',
                        ),
                      ),
                    ),
                  );
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 