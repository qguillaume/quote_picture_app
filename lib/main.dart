import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const QuoteApp());
}

final String pexelsApiKey = dotenv.env['PEXELS_API_KEY'] ?? '';

class QuoteApp extends StatelessWidget {
  const QuoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Générateur de Citations',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const QuoteGenerator(),
    );
  }
}

class QuoteGenerator extends StatefulWidget {
  const QuoteGenerator({Key? key}) : super(key: key);

  @override
  _QuoteGeneratorState createState() => _QuoteGeneratorState();
}

class _QuoteGeneratorState extends State<QuoteGenerator> {
  String currentQuote = "Cliquez sur Générer pour afficher une citation";
  String currentAuthor = "";
  String currentImageUrl = "";
  bool isLoading = false;
  
  // Clé API Pexels
  final String pexelsApiKey = "CLE_API_PEXELS";
  
  // Liste de citations
  final List<Map<String, String>> quotes = [
    {
      "quote": "La vie est ce qui arrive quand on est occupé à faire d'autres projets.",
      "author": "John Lennon"
    },
    {
      "quote": "L'échec est le fondement de la réussite.",
      "author": "Lao Tseu"
    },
    {
      "quote": "La connaissance s'acquiert par l'expérience, tout le reste n'est que de l'information.",
      "author": "Albert Einstein"
    },
    {
      "quote": "Le succès, c'est d'aller d'échec en échec sans perdre son enthousiasme.",
      "author": "Winston Churchill"
    },
    {
      "quote": "Le bonheur n'est pas quelque chose de prêt à l'emploi. Il découle de vos propres actions.",
      "author": "Dalaï Lama"
    },
    {
      "quote": "La simplicité est la sophistication suprême.",
      "author": "Léonard de Vinci"
    },
  ];

  Future<void> generateRandomQuote() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Sélectionner une citation aléatoire
      final random = Random();
      final quoteIndex = random.nextInt(quotes.length);
      final selectedQuote = quotes[quoteIndex];

      // Rechercher une image sur Pexels
      final keywords = ["inspiration", "nature", "landscape", "sky", "mountain", "ocean"];
      final searchTerm = keywords[random.nextInt(keywords.length)];
      final imageUrl = await fetchRandomPexelsImage(searchTerm);

      setState(() {
        currentQuote = selectedQuote["quote"] ?? "";
        currentAuthor = selectedQuote["author"] ?? "";
        currentImageUrl = imageUrl;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<String> fetchRandomPexelsImage(String query) async {
    final response = await http.get(
      Uri.parse('https://api.pexels.com/v1/search?query=$query&per_page=15'),
      headers: {
        'Authorization': pexelsApiKey,
      },
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

  Future<void> shareQuote() async {
    if (currentImageUrl.isEmpty) return;

    try {
      // Télécharger l'image
      final response = await http.get(Uri.parse(currentImageUrl));
      final bytes = response.bodyBytes;

      // Stocker temporairement l'image
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/quote_image.jpg');
      await file.writeAsBytes(bytes);

      // Partager l'image et le texte
      await Share.shareFiles(
        [file.path],
        text: '"$currentQuote" - $currentAuthor',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du partage: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citations Inspirantes'),
      ),
      body: Stack(
        children: [
          // Image de fond
          if (currentImageUrl.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: currentImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade200),
                errorWidget: (context, url, error) => Container(color: Colors.grey.shade300),
              ),
            ),
          
          // Contenu
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentQuote,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (currentAuthor.isNotEmpty)
                      Text(
                        "- $currentAuthor",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(
                              blurRadius: 3.0,
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : generateRandomQuote,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Générer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (currentImageUrl.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : shareQuote,
                            icon: const Icon(Icons.share),
                            label: const Text('Partager'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Indicateur de chargement
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}