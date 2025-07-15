import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
                  colors: [Colors.blueAccent, Colors.purpleAccent.shade100],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
          color: isUser ? null : Colors.white,
          border: isUser
              ? null
              : Border.all(color: Colors.blueAccent.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(22).copyWith(
            topLeft: isUser ? const Radius.circular(22) : const Radius.circular(8),
            topRight: isUser ? const Radius.circular(8) : const Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUser) ...[
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue[50],
                child: const Icon(Icons.smart_toy, color: Colors.blueAccent, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                msg.content,
                style: GoogleFonts.nunito(
                  color: isUser ? Colors.white : Colors.blueAccent,
                  fontSize: 15,
                  fontWeight: isUser ? FontWeight.w600 : FontWeight.w700,
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue[50],
                child: const Icon(Icons.person, color: Colors.blueAccent, size: 16),
              ),
            ],
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[100]!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.7),
                  child: const Icon(Icons.smart_toy, color: Colors.blueAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title ?? 'Hỏi AI',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Colors.blueAccent,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.close, color: Colors.grey, size: 22),
                    ),
                  ),
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
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (_error != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: GoogleFonts.nunito(color: Colors.red, fontSize: 13))),
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
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50]!.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.suggestions!.map((s) => ActionChip(
                        avatar: const Icon(Icons.smart_toy, color: Colors.blueAccent, size: 16),
                        backgroundColor: Colors.white,
                        label: Text(s, style: GoogleFonts.nunito(fontSize: 13, color: Colors.blueAccent)),
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
                        style: GoogleFonts.nunito(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Nhập câu hỏi cho AI...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
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
                    Material(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: !_loading && _controller.text.trim().isNotEmpty
                            ? () {
                                final val = _controller.text.trim();
                                _controller.clear();
                                _sendMessage(val);
                              }
                            : null,
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(Icons.send, color: Colors.white),
                        ),
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