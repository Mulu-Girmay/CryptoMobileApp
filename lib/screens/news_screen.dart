import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/news.dart';
import '../services/news_service.dart';
import '../utils/formatter.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _articles = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedCurrency;
  Map<String, dynamic>? _sentimentData;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  final List<String> _currencies = [
    'All',
    'BTC',
    'ETH',
    'ADA',
    'SOL',
    'DOT',
    'AVAX',
    'MATIC',
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
    _loadSentiment();
  }

  Future<void> _loadNews({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
        _articles = [];
      });
    }

    try {
      final currency = _selectedCurrency != 'All' ? _selectedCurrency : null;
      final response = await _newsService.fetchNews(
        currency: currency,
        limit: 20,
      );

      if (response.error != null) {
        setState(() {
          _error = response.error;
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      setState(() {
        if (loadMore) {
          _articles.addAll(response.articles);
        } else {
          _articles = response.articles;
        }
        _isLoading = false;
        _isLoadingMore = false;
        _hasMore = response.articles.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadSentiment() async {
    final data = await _newsService.getMarketSentiment();
    setState(() {
      _sentimentData = data;
    });
  }

  Future<void> _refresh() async {
    await _loadNews();
    await _loadSentiment();
  }

  void _openArticle(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open article'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening article: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text('Crypto News'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          // Sentiment Indicator
          _buildSentimentIndicator(),

          // Currency Filter
          _buildCurrencyFilter(),

          // News List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF22C55E)),
                  )
                : _error != null
                ? _buildErrorWidget()
                : _articles.isEmpty
                ? _buildEmptyWidget()
                : RefreshIndicator(
                    onRefresh: _refresh,
                    color: const Color(0xFF22C55E),
                    child: ListView.builder(
                      itemCount: _articles.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _articles.length) {
                          return _buildLoadMore();
                        }
                        return _buildNewsCard(_articles[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentIndicator() {
    if (_sentimentData == null || _sentimentData!['error'] != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_neutral, color: Colors.white54),
            const SizedBox(width: 12),
            Text(
              _sentimentData?['error'] ?? 'Market sentiment unavailable',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    final sentiment = _sentimentData!['sentiment'] as String;
    final score = _sentimentData!['score'] as double;
    final totalArticles = _sentimentData!['articles'] as int;
    final bullish = _sentimentData!['bullish'] as int? ?? 0;
    final bearish = _sentimentData!['bearish'] as int? ?? 0;
    final neutral = _sentimentData!['neutral'] as int? ?? 0;

    Color sentimentColor;
    IconData sentimentIcon;
    if (sentiment == 'bullish') {
      sentimentColor = Colors.green;
      sentimentIcon = Icons.trending_up;
    } else if (sentiment == 'bearish') {
      sentimentColor = Colors.red;
      sentimentIcon = Icons.trending_down;
    } else {
      sentimentColor = Colors.grey;
      sentimentIcon = Icons.sentiment_neutral;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Market Sentiment',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: sentimentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(sentimentIcon, color: sentimentColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      sentiment.toUpperCase(),
                      style: TextStyle(
                        color: sentimentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSentimentStat(
                'Total Articles',
                '$totalArticles',
                Colors.white54,
              ),
              _buildSentimentStat('Bullish', '$bullish', Colors.green),
              _buildSentimentStat('Bearish', '$bearish', Colors.red),
              _buildSentimentStat('Neutral', '$neutral', Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (score + 1) / 2, // Normalize from -1..1 to 0..1
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              score > 0 ? Colors.green : Colors.red,
            ),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildCurrencyFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _currencies.map((currency) {
          final isSelected =
              _selectedCurrency == currency ||
              (_selectedCurrency == null && currency == 'All');
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(currency),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCurrency = selected ? currency : 'All';
                  if (_selectedCurrency == 'All') _selectedCurrency = null;
                });
                _loadNews();
              },
              backgroundColor: const Color(0xFF0B1220),
              selectedColor: const Color(0xFF22C55E).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF22C55E) : Colors.white54,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF22C55E)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    final isPositive =
        article.sentiment == NewsSentiment.bullish ||
        article.sentiment == NewsSentiment.positive;
    final isNegative =
        article.sentiment == NewsSentiment.bearish ||
        article.sentiment == NewsSentiment.negative;

    return GestureDetector(
      onTap: () => _openArticle(article.url),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPositive
                ? Colors.green.withOpacity(0.2)
                : isNegative
                ? Colors.red.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.white10,
                    child: const Icon(Icons.image, color: Colors.white24),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source and time
                  Row(
                    children: [
                      Text(
                        article.source,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(article.publishedAt),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Tags and sentiment
                  Row(
                    children: [
                      if (article.coinSymbol != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            article.coinSymbol!.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (article.coinSymbol != null) const SizedBox(width: 8),
                      if (article.sentiment != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: article.sentiment!.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                article.sentiment!.icon,
                                color: article.sentiment!.color,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                article.sentiment!.displayName,
                                style: TextStyle(
                                  color: article.sentiment!.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMore() {
    if (!_hasMore) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoadingMore
            ? const CircularProgressIndicator(color: Color(0xFF22C55E))
            : OutlinedButton(
                onPressed: () {
                  _currentPage++;
                  _loadNews(loadMore: true);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Text('Load More'),
              ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.black,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper, size: 60, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'No news available',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}
