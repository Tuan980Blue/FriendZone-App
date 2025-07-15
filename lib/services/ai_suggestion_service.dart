import 'dart:convert';
import 'package:http/http.dart' as http;

class AiSuggestionService {
  final String apiKey;

  AiSuggestionService({required this.apiKey});

  Future<List<String>> fetchSuggestions({
    required String postContent,
    int numQuestions = 3,
  }) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');
    final prompt =
        'Hãy gợi ý $numQuestions câu hỏi để giúp người dùng tìm hiểu sâu hơn về nội dung họ đang xem bài đăng sau. Chỉ trả về danh sách câu hỏi, mỗi câu hỏi trên một dòng (không quá 15 từ), không giải thích thêm.\nBài đăng: "$postContent"';
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Gemini trả về trong data['candidates'][0]['content']['parts'][0]['text']
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      if (text != null) {
        final lines = text
            .split(RegExp(r'[\n\r]+'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final questions = lines.map((line) {
          final match = RegExp(r'^(\d+\.|\-|\*)\s*').firstMatch(line);
          return match != null ? line.substring(match.end).trim() : line;
        }).toList();
        return questions;
      }
    } else {
      print('Gemini API error: \nStatus: ${response.statusCode}\nBody: ${response.body}');
      throw Exception('Gemini API error: ${response.statusCode} ${response.body}');
    }
    return [];
  }

  /// Gửi một câu hỏi bất kỳ tới AI, có thể truyền lịch sử hội thoại để giữ ngữ cảnh.
  Future<String> sendMessageToAi({
    required String message,
    List<Map<String, String>>? history, // [{role: 'user'/'model', content: '...'}]
  }) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');
    final List<Map<String, dynamic>> contents = [];
    if (history != null && history.isNotEmpty) {
      for (final msg in history) {
        contents.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [ {'text': msg['content'] ?? ''} ]
        });
      }
    }
    // Thêm câu hỏi hiện tại vào cuối cùng (role: user)
    contents.add({
      'role': 'user',
      'parts': [ {'text': message} ]
    });
    final body = jsonEncode({
      'contents': contents
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      if (text != null) return text.trim();
    } else {
      print('Gemini API error: \nStatus: \\${response.statusCode}\nBody: \\${response.body}');
      throw Exception('Gemini API error: \\${response.statusCode} \\${response.body}');
    }
    throw Exception('Không nhận được phản hồi từ AI');
  }
} 