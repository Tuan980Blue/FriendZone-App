import 'package:flutter/material.dart';
import '../../services/ai_suggestion_service.dart';

class AIChatDialog extends StatefulWidget {
  final String initialQuestion;
  final String apiKey;
  final String? title;
  final List<String>? suggestions;

  const AIChatDialog({
    Key? key,
    required this.initialQuestion,
    required this.apiKey,
    this.title,
    this.suggestions,
  }) : super(key: key);

  @override
  State<AIChatDialog> createState() => _AIChatDialogState();
}

class _AIChatDialogState extends State<AIChatDialog> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  late AiSuggestionService _service;

  @override
  void initState() {
    super.initState();
    _service = AiSuggestionService(apiKey: widget.apiKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendMessage(widget.initialQuestion, isInit: true);
    });
  }

  Future<void> _sendMessage(String text, {bool isInit = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (!isInit) {
        _messages.add(_ChatMessage(role: 'user', content: text));
      }
    });
    try {
      final history = _messages.map((e) => {'role': e.role, 'content': e.content}).toList();
      final aiReply = await _service.sendMessageToAi(
        message: text,
        history: isInit ? null : history,
      );
      setState(() {
        if (isInit) {
          _messages.add(_ChatMessage(role: 'user', content: text));
        }
        _messages.add(_ChatMessage(role: 'model', content: aiReply));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể lấy phản hồi từ AI. Vui lòng thử lại.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMessage(_ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.blue[50],
          borderRadius: BorderRadius.circular(18).copyWith(
            topLeft: isUser ? const Radius.circular(18) : const Radius.circular(6),
            topRight: isUser ? const Radius.circular(6) : const Radius.circular(18),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUser) ...[
              const Icon(Icons.smart_toy, color: Colors.blueAccent, size: 18),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                msg.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.blueAccent,
                  fontSize: 15,
                  fontFamily: 'Roboto', // hoặc GoogleFonts.nunito nếu có
                  fontWeight: isUser ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
              border: Border(
                bottom: BorderSide(color: Colors.blueAccent.withOpacity(0.12)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.blueAccent, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title ?? 'Hỏi AI',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      fontFamily: 'Roboto', // hoặc GoogleFonts.nunito nếu có
                      color: Colors.blueAccent,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Đóng',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              shrinkWrap: true,
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, idx) => _buildMessage(_messages[idx]),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: () {
                      if (_messages.isNotEmpty) {
                        _sendMessage(_messages.last.content);
                      }
                    },
                    tooltip: 'Thử lại',
                  ),
                ],
              ),
            ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.suggestions != null && widget.suggestions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.suggestions!.map((s) => ActionChip(
                        avatar: const Icon(Icons.smart_toy, color: Colors.blueAccent, size: 16),
                        backgroundColor: Colors.blue[50],
                        label: Text(s, style: const TextStyle(fontSize: 13, fontFamily: 'Roboto', color: Colors.blueAccent)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.blueAccent, width: 0.5),
                        ),
                        elevation: 1,
                        onPressed: !_loading ? () {
                          _controller.clear();
                          _sendMessage(s);
                        } : null,
                      )).toList(),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_loading,
                        textInputAction: TextInputAction.send,
                        style: const TextStyle(fontSize: 15, fontFamily: 'Roboto'),
                        decoration: InputDecoration(
                          hintText: 'Nhập câu hỏi cho AI...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty && !_loading) {
                            _controller.clear();
                            _sendMessage(val.trim());
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: !_loading && _controller.text.trim().isNotEmpty
                            ? () {
                                final val = _controller.text.trim();
                                _controller.clear();
                                _sendMessage(val);
                              }
                            : null,
                        tooltip: 'Gửi',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role; // 'user' hoặc 'model'
  final String content;
  _ChatMessage({required this.role, required this.content});
} 