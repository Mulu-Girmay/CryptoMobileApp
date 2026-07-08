import 'package:flutter/material.dart';

enum NewsSentiment { bullish, bearish, neutral, positive, negative }

extension NewsSentimentExtension on NewsSentiment {
  String get displayName {
    switch (this) {
      case NewsSentiment.bullish:
        return 'Bullish';
      case NewsSentiment.bearish:
        return 'Bearish';
      case NewsSentiment.neutral:
        return 'Neutral';
      case NewsSentiment.positive:
        return 'Positive';
      case NewsSentiment.negative:
        return 'Negative';
    }
  }

  Color get color {
    switch (this) {
      case NewsSentiment.bullish:
        return Colors.green;
      case NewsSentiment.bearish:
        return Colors.red;
      case NewsSentiment.neutral:
        return Colors.grey;
      case NewsSentiment.positive:
        return Colors.lightGreen;
      case NewsSentiment.negative:
        return Colors.redAccent;
    }
  }

  IconData get icon {
    switch (this) {
      case NewsSentiment.bullish:
        return Icons.trending_up;
      case NewsSentiment.bearish:
        return Icons.trending_down;
      case NewsSentiment.neutral:
        return Icons.remove;
      case NewsSentiment.positive:
        return Icons.thumb_up;
      case NewsSentiment.negative:
        return Icons.thumb_down;
    }
  }
}

class NewsArticle {
  final String id;
  final String title;
  final String? description;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;
  final String source;
  final NewsSentiment? sentiment;
  final String? coinId;
  final String? coinName;
  final String? coinSymbol;
  final int? upvotes;
  final int? downvotes;
  final String? author;

  NewsArticle({
    required this.id,
    required this.title,
    this.description,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
    required this.source,
    this.sentiment,
    this.coinId,
    this.coinName,
    this.coinSymbol,
    this.upvotes,
    this.downvotes,
    this.author,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    // Parse sentiment from the API response
    NewsSentiment? parseSentiment(String? sentimentStr) {
      if (sentimentStr == null) return null;
      final lower = sentimentStr.toLowerCase();
      if (lower.contains('bullish') || lower.contains('positive')) {
        return NewsSentiment.bullish;
      } else if (lower.contains('bearish') || lower.contains('negative')) {
        return NewsSentiment.bearish;
      } else {
        return NewsSentiment.neutral;
      }
    }

    // Parse currencies from the API
    List<dynamic>? currencies = json['currencies'];
    String? coinId;
    String? coinName;
    String? coinSymbol;

    if (currencies != null && currencies.isNotEmpty) {
      final firstCurrency = currencies.first as Map<String, dynamic>;
      coinId = firstCurrency['id']?.toString();
      coinName = firstCurrency['name']?.toString();
      coinSymbol = firstCurrency['code']?.toString().toUpperCase();
    }

    return NewsArticle(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Untitled',
      description: json['description']?.toString(),
      url: json['url'] ?? '',
      imageUrl: json['image']?.toString(),
      publishedAt: DateTime.parse(
        json['published_at'] ?? DateTime.now().toIso8601String(),
      ),
      source: json['source']?['title']?.toString() ?? 'Unknown Source',
      sentiment: parseSentiment(json['sentiment']?.toString()),
      coinId: coinId,
      coinName: coinName,
      coinSymbol: coinSymbol,
      upvotes: json['upvotes'] as int?,
      downvotes: json['downvotes'] as int?,
      author: json['author']?.toString(),
    );
  }

  // Calculate sentiment score (-1 to 1)
  double get sentimentScore {
    if (sentiment == null) return 0.0;
    switch (sentiment!) {
      case NewsSentiment.bullish:
        return 0.8;
      case NewsSentiment.bearish:
        return -0.8;
      case NewsSentiment.positive:
        return 0.5;
      case NewsSentiment.negative:
        return -0.5;
      case NewsSentiment.neutral:
        return 0.0;
    }
  }

  // Get engagement score (upvotes - downvotes)
  int get engagementScore {
    final up = upvotes ?? 0;
    final down = downvotes ?? 0;
    return up - down;
  }
}

class NewsResponse {
  final List<NewsArticle> articles;
  final String? error;
  final int total;

  NewsResponse({required this.articles, this.error, required this.total});

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final articles = json['results'] as List? ?? [];
    return NewsResponse(
      articles: articles.map((e) => NewsArticle.fromJson(e)).toList(),
      total: json['total'] as int? ?? 0,
    );
  }

  factory NewsResponse.withError(String error) {
    return NewsResponse(articles: [], error: error, total: 0);
  }
}
