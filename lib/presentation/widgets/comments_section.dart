import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:friendzoneapp/presentation/theme/app_theme.dart';

class CommentsSection extends StatefulWidget {
  final String postId;
  final String authToken;
  final Function(String) onUserTap;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String postContent; // Thêm thuộc tính để nhận nội dung bài đăng

  const CommentsSection({
    Key? key,
    required this.postId,
    required this.authToken,
    required this.onUserTap,
    required this.isExpanded,
    required this.onToggle,
    required this.postContent, // Thêm postContent vào constructor
  }) : super(key: key);

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  bool isLoading = true;
  String? error;
  List<dynamic>? comments;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isSubmitting = false;
  List<String> commentSuggestions = [];
  bool isLoadingSuggestions = false;

  // Gemini API Key (hardcoded - không khuyến nghị cho môi trường sản xuất)
  static const String _geminiApiKey = 'AIzaSyD0Y1RZNI-PBAsMNtZhDGfFKWefYIa9Wac';

  @override
  void initState() {
    super.initState();
    if (widget.isExpanded) {
      _fetchComments();
      _fetchCommentSuggestions(widget.postContent);
    }
  }

  @override
  void didUpdateWidget(CommentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _fetchComments();
      _fetchCommentSuggestions(widget.postContent);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    if (!widget.isExpanded) return;

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.authToken}',
      };

      final response = await http.get(
        Uri.parse(
            'https://web-socket-friendzone.onrender.com/api/posts/${widget.postId}/comments?page=1&limit=10'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['success'] == true) {
          setState(() {
            comments = jsonBody['data']['comments'] as List;
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'Không thể tải bình luận';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          error = 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Không thể tải bình luận';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Không thể tải bình luận';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCommentSuggestions(String caption) async {
    if (caption.isEmpty || !mounted) return;

    setState(() {
      isLoadingSuggestions = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                  'Bạn là một trợ lý AI, nhiệm vụ là tạo ra 3 gợi ý bình luận tích cực, ngắn gọn (dưới 20 từ mỗi bình luận), phù hợp với văn hóa Việt Nam, cho bài đăng trên mạng xã hội với caption: "$caption". Định dạng mỗi gợi ý trên một dòng, bắt đầu bằng số thứ tự (1., 2., 3.).'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 100,
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['candidates'] != null && jsonBody['candidates'].isNotEmpty) {
          final text = jsonBody['candidates'][0]['content']['parts'][0]['text'];
          final suggestions = text
              .split('\n')
              .where((s) => s.trim().isNotEmpty && s.startsWith(RegExp(r'^\d+\.')))
              .map((s) => s.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
              .toList()
              .cast<String>();
          if (mounted) {
            setState(() {
              commentSuggestions = suggestions;
              isLoadingSuggestions = false;
            });
          }
        } else {
          throw Exception('Phản hồi API không chứa candidates hợp lệ');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Lỗi 403: API Key không hợp lệ hoặc không có quyền truy cập');
      } else if (response.statusCode == 429) {
        throw Exception('Lỗi 429: Vượt quá giới hạn quota API');
      } else {
        throw Exception('Lỗi server: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingSuggestions = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lấy gợi ý bình luận: $e')),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.authToken}',
      };

      final response = await http.post(
        Uri.parse(
            'https://web-socket-friendzone.onrender.com/api/posts/${widget.postId}/comments'),
        headers: headers,
        body: json.encode({
          'content': _commentController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        _commentController.clear();
        await _fetchComments();
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể gửi bình luận')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể gửi bình luận')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }
  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[50]
            : Colors.grey[900],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: Theme.of(context).dividerTheme.color,
          ),
          if (isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPink),
                ),
              ),
            )
          else if (error != null)
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 32,
                    color: AppTheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _fetchComments,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Thử lại'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentPink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (comments == null || comments!.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 32,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chưa có bình luận nào',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments!.length,
                itemBuilder: (context, index) {
                  final comment = comments![index];
                  final author = comment['author'];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade200,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => widget.onUserTap(author['id']),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.accentPink.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundImage: author['avatar'] != null && author['avatar'].isNotEmpty
                                    ? CachedNetworkImageProvider(author['avatar'])
                                    : null,
                                onBackgroundImageError: (_, __) {},
                                child: author['avatar'] == null || author['avatar'].isEmpty
                                    ? Text(
                                  author['fullName']?[0].toUpperCase() ?? '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => widget.onUserTap(author['id']),
                                      child: Text(
                                        author['fullName'] ?? 'Unknown User',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDate(comment['createdAt']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment['content'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          Container(
            height: 1,
            color: Theme.of(context).dividerTheme.color,
          ),
          if (isLoadingSuggestions)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPink),
                ),
              ),
            )
          else if (commentSuggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gợi ý bình luận:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: commentSuggestions.map((suggestion) {
                      return GestureDetector(
                        onTap: () {
                          _commentController.text = suggestion;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            suggestion,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[850],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[100]
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Viết bình luận...',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: isSubmitting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.accentPink),
                            ),
                          ),
                        )
                            : IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: AppTheme.accentPink,
                          ),
                          onPressed: isSubmitting ? null : _submitComment,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                      maxLines: null,
                      onTap: () {
                        if (commentSuggestions.isNotEmpty) {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => ListView(
                              children: commentSuggestions
                                  .map((suggestion) => ListTile(
                                title: Text(suggestion),
                                onTap: () {
                                  _commentController.text = suggestion;
                                  Navigator.pop(context);
                                },
                              ))
                                  .toList(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}