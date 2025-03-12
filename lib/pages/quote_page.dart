import 'package:flutter/material.dart';
import 'package:quotepicture/widgets/quote_widget.dart';

class QuotePage extends StatelessWidget {
  const QuotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QuoteGenerator(),
    );
  }
}
