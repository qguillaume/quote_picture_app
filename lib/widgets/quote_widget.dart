import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:quotepicture/models/quote_model.dart';
import 'package:quotepicture/services/quote_service.dart';

class QuoteGenerator extends StatefulWidget {
  const QuoteGenerator({Key? key}) : super(key: key);

  @override
  _QuoteGeneratorState createState() => _QuoteGeneratorState();
}

class _QuoteGeneratorState extends State<QuoteGenerator> {
  final QuoteService quoteService = QuoteService();
  Quote? currentQuote;
  String currentImageUrl = "";
  bool isLoading = false;

  Future<void> generateRandomQuote() async {
    setState(() {
      isLoading = true;
    });

    try {
      final quote = await quoteService.getRandomQuote();
      final imageUrl = await quoteService.fetchRandomPexelsImage();

      setState(() {
        currentQuote = quote;
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

  Future<void> shareQuote() async {
    if (currentImageUrl.isEmpty || currentQuote == null) return;

    try {
      final response = await http.get(Uri.parse(currentImageUrl));
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/quote_image.jpg');
      await file.writeAsBytes(bytes);

      await Share.shareFiles(
        [file.path],
        text: '"${currentQuote!.text}" - ${currentQuote!.author}',
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
          if (currentImageUrl.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: currentImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade200),
                errorWidget: (context, url, error) => Container(color: Colors.grey.shade300),
              ),
            ),
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentQuote?.text ?? "Cliquez sur Générer pour afficher une citation",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (currentQuote != null)
                      Text(
                        "- ${currentQuote!.author}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
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
                        ),
                        const SizedBox(width: 16),
                        if (currentImageUrl.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : shareQuote,
                            icon: const Icon(Icons.share),
                            label: const Text('Partager'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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
