import 'package:flutter/services.dart';
import 'dart:math';

class QuoteService {
  static List<String> _quotes = [];

  static Future<void> loadQuotes() async {
    final data = await rootBundle.loadString('assets/text/quotes.txt');
    _quotes = data
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static String randomQuote() {
    if (_quotes.isEmpty) return '今天也要好好训练哦 💪';
    final random = Random(DateTime.now().microsecondsSinceEpoch);
    return _quotes[random.nextInt(_quotes.length)];
  }
}