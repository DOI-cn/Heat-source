import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiConfig {
  final String baseUrl;
  final String apiKey;
  final String model;

  const ApiConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
  });

  factory ApiConfig.kimi(String apiKey) => ApiConfig(
        baseUrl: 'https://api.moonshot.cn/anthropic',
        apiKey: apiKey,
        model: 'kimi-k2.6',
      );

  factory ApiConfig.custom({
    required String baseUrl,
    required String apiKey,
    required String model,
  }) =>
      ApiConfig(baseUrl: baseUrl, apiKey: apiKey, model: model);
}

class RecognitionResult {
  final String foodName;
  final double confidence;
  final double caloriePerGram;

  const RecognitionResult({
    required this.foodName,
    required this.confidence,
    required this.caloriePerGram,
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) =>
      RecognitionResult(
        foodName: json['food_name'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        caloriePerGram: (json['calorie_per_gram'] as num).toDouble(),
      );
}

class ApiClient {
  final ApiConfig _config;
  final http.Client _client;

  ApiClient({required ApiConfig config, http.Client? client})
      : _config = config,
        _client = client ?? http.Client();

  Future<List<RecognitionResult>> recognizeFood(String imageBase64) async {
    final response = await _client.post(
      Uri.parse('${_config.baseUrl}/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _config.apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _config.model,
        'max_tokens': 1024,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': imageBase64,
                },
              },
              {
                'type': 'text',
                'text': '识别图片中的所有食物。返回 JSON 数组，每个元素包含：food_name(食物中文名)、confidence(置信度0-1)、calorie_per_gram(每克热量千卡)。只返回 JSON 数组，不要其他内容。',
              },
            ],
          }
        ],
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw ApiException('API 请求失败: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['content'] as List<dynamic>?)
        ?.firstWhereOrNull((b) => b['type'] == 'text');
    final text = content?['text'] as String?;
    if (text == null) {
      throw ApiException('API 返回格式异常');
    }

    final cleaned = text.trim();
    final list = jsonDecode(cleaned) as List<dynamic>;
    return list
        .map((e) => RecognitionResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() => _client.close();
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}
