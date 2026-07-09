import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../model/news.dart';
import '../utils/error_handler.dart';
import '../utils/retry_helper.dart';

class NewsService {
  static const String _baseUrl = 'https://cryptopanic.com/api/v2/posts/';

  // Free API key - you can get your own at https://cryptopanic.com/developers/api/
  // For production, consider using environment variables
  static const String _apiKey = 'YOUR_API_KEY'; // Replace with your API key

  static const List<String> _currencies = [
    'BTC',
    'ETH',
    'ADA',
    'SOL',
    'DOT',
    'AVAX',
    'MATIC',
  ];

  Future<NewsResponse> fetchNews({
    String? currency,
    int limit = 20,
    bool filter = true,
  }) async {
    try {
      // Build URL with parameters
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'auth_token': _apiKey,
          'public': 'true',
          'limit': limit.toString(),
          if (currency != null && _currencies.contains(currency.toUpperCase()))
            'currencies': currency.toUpperCase(),
          if (filter) 'filter': 'hot',
        },
      );

      final response = await RetryHelper.retry(
        () => http.get(uri).timeout(const Duration(seconds: 10)),
        maxRetries: 2,
        delay: const Duration(seconds: 1),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NewsResponse.fromJson(data);
      } else if (response.statusCode == 429) {
        // Rate limit - return empty with error
        return NewsResponse.withError(
          'Rate limit exceeded. Please try again later.',
        );
      } else {
        return NewsResponse.withError(
          'Failed to load news: ${response.statusCode}',
        );
      }
    } on SocketException {
      return NewsResponse.withError(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      return NewsResponse.withError('Connection timeout. Please try again.');
    } catch (e) {
      return NewsResponse.withError('Error loading news: ${e.toString()}');
    }
  }

  // Get news for a specific coin
  Future<NewsResponse> fetchCoinNews(String coinId) async {
    final coinSymbol = coinId.toUpperCase();
    if (_currencies.contains(coinSymbol)) {
      return fetchNews(currency: coinSymbol);
    }
    return NewsResponse.withError('News not available for this coin');
  }

  // Get market sentiment overview
  Future<Map<String, dynamic>> getMarketSentiment() async {
    final response = await fetchNews(limit: 50);

    if (response.error != null) {
      return {
        'sentiment': 'neutral',
        'score': 0.0,
        'articles': 0,
        'error': response.error,
      };
    }

    final articles = response.articles;
    if (articles.isEmpty) {
      return {'sentiment': 'neutral', 'score': 0.0, 'articles': 0};
    }

    // Calculate average sentiment score
    double totalScore = 0.0;
    int validArticles = 0;

    for (final article in articles) {
      if (article.sentiment != null) {
        totalScore += article.sentimentScore;
        validArticles++;
      }
    }

    final averageScore = validArticles > 0 ? totalScore / validArticles : 0.0;

    String sentiment;
    if (averageScore > 0.3) {
      sentiment = 'bullish';
    } else if (averageScore < -0.3) {
      sentiment = 'bearish';
    } else {
      sentiment = 'neutral';
    }

    return {
      'sentiment': sentiment,
      'score': averageScore,
      'articles': articles.length,
      'bullish': articles
          .where((a) => a.sentiment == NewsSentiment.bullish)
          .length,
      'bearish': articles
          .where((a) => a.sentiment == NewsSentiment.bearish)
          .length,
      'neutral': articles
          .where((a) => a.sentiment == NewsSentiment.neutral)
          .length,
    };
  }
}
