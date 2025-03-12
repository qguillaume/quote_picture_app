import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PexelsService {
  final String apiKey = dotenv.env['PEXELS_API_KEY'] ?? '';
  final List<String> keywords = ["inspiration", "nature", "landscape", "sky", "mountain", "ocean"];

  Future<String> fetchRandomImage() async {
    final String query = keywords[Random().nextInt(keywords.length)];
    final response = await http.get(
      Uri.parse('https://api.pexels.com/v1/search?query=$query&per_page=15'),
      headers: {'Authorization': apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final photos = data['photos'] as List;
      if (photos.isNotEmpty) {
        final randomIndex = Random().nextInt(photos.length);
        return photos[randomIndex]['src']['large'];
      }
    }
    throw Exception('Impossible de récupérer une image');
  }
}