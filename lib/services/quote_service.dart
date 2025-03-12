import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quotepicture/models/quote_model.dart';

class QuoteService {
  final List<Quote> quotes = [
    Quote(text: "La vie est ce qui arrive quand on est occupé à faire d'autres projets.", author: "John Lennon"),
    Quote(text: "L'échec est le fondement de la réussite.", author: "Lao Tseu"),
    Quote(text: "La connaissance s'acquiert par l'expérience, tout le reste n'est que de l'information.", author: "Albert Einstein"),
    Quote(text: "Le succès, c'est d'aller d'échec en échec sans perdre son enthousiasme.", author: "Winston Churchill"),
    Quote(text: "Le bonheur n'est pas quelque chose de prêt à l'emploi. Il découle de vos propres actions.", author: "Dalaï Lama"),
    Quote(text: "La simplicité est la sophistication suprême.", author: "Léonard de Vinci"),
  ];

  Future<Quote> getRandomQuote() async {
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  Future<String> fetchRandomPexelsImage() async {
    final String apiKey = dotenv.env['PEXELS_API_KEY'] ?? '';
    final List<String> keywords = ["inspiration", "nature", "landscape", "sky", "mountain", "ocean"];
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
