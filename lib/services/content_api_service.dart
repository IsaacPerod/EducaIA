import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class ContentApiService {
  final String _apiKey = YOUTUBE_API_KEY;

  Future<List<Map<String, dynamic>>> fetchContents(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'contents_$topic';
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      print('Usando cache para $topic');
      return List<Map<String, dynamic>>.from(json.decode(cached));
    }

    final query = _mapTopicToQuery(topic);
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=$_apiKey&maxResults=10',
    );

    try {
      print('Chamando API: $url (chave: ${_apiKey.substring(0, 10)}...)');
      final response = await http.get(url);
      print('Resposta: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final contents = (data['items'] as List).map((item) {
          return {
            'id': item['id']['videoId'] ?? '',
            'title': item['snippet']['title'] ?? 'Sem título',
            'type': 'video',
            'difficulty': 'beginner',
            'url': 'https://www.youtube.com/watch?v=${item['id']['videoId'] ?? ''}',
            'topics': [topic],
          };
        }).toList();
        await prefs.setString(cacheKey, json.encode(contents));
        print('Conteúdos salvos no cache: ${contents.length}');
        return contents;
      } else {
        throw Exception('Erro na API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao buscar conteúdos: $e');
      return [];
    }
  }

  String _mapTopicToQuery(String topic) {
    switch (topic) {
      case 'Programação':
        return 'programming tutorial';
      case 'Matemática':
        return 'math tutorial';
      case 'Português':
        return 'portuguese grammar tutorial';
      case 'Lógica':
        return 'logic tutorial';
      default:
        return topic;
    }
  }
}