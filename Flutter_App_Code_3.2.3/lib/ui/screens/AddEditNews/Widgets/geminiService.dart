import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:news/utils/api.dart';

class GeminiService {
  static Future<Map<String, dynamic>> _callGeminiAPI(String prompt, {String? systemInstruction}) async {
    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ],
      if (systemInstruction != null)
        "systemInstruction": {
          "parts": [
            {"text": systemInstruction}
          ]
        }
    };

    final response = await http.post(
      Uri.parse(Api.geminiMetaInfoApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error']?['message'] ?? 'Failed to generate content');
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, String>> generateContent({String? title, String? category, String? language, String? languageCode}) async {
    String fullPrompt = 'You are a skilled news article writer. Create engaging and informative content.';

    if (title != null && title.isNotEmpty) {
      fullPrompt += '\n\nWrite an article with the title: "$title"';
    }

    if (category != null && category.isNotEmpty) {
      fullPrompt += '\nCategory: $category';
    }

    if (language != null && languageCode != null) {
      fullPrompt += '\n\nIMPORTANT: Generate all content in $language language ($languageCode). '
          'The response MUST be in $language.';
    }

    fullPrompt += '\n\nRequest: Article:';

    final response = await _callGeminiAPI(fullPrompt);
    final content = response['candidates'][0]['content']['parts'][0]['text'];

    return {"content": content};
  }

  static Future<Map<String, dynamic>> generateMetaInfo({required String title, required String language, required String languageCode}) async {
    String languageInstruction = '';
    if (language.isNotEmpty && languageCode.isNotEmpty) {
      languageInstruction = '\n\nIMPORTANT: Generate all content in $language language ($languageCode). '
          'The response MUST be in the same language as the title.';
    }

    final prompt = '''
You are an SEO expert. Generate meta title, description, keywords, and a slug for this news article titled: "$title".$languageInstruction

Return ONLY a JSON object with these fields:
- meta_title: an SEO-friendly title (max 60 chars)
- meta_description: an engaging description (between 50-160 chars)
- meta_keywords: comma-separated keywords
- slug: URL-friendly version of the title

The response must be valid JSON format with these exact field names. Do not include any explanation or additional text.
''';

    final response = await _callGeminiAPI(prompt);
    final text = response['candidates'][0]['content']['parts'][0]['text'].trim();

    try {
      return jsonDecode(text);
    } catch (_) {
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (match != null) {
        try {
          return jsonDecode(match.group(0)!);
        } catch (_) {}
      }

      return {
        "meta_title": title,
        "meta_description": "Read about $title in our latest news article.",
        "meta_keywords": title.toLowerCase().split(' ').join(','),
        "slug": title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '')
      };
    }
  }
}
