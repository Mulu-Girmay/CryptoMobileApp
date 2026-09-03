import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/news.dart';
import '../services/news_service.dart';

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

  final List<String> _currencies = ['All', 'BTC', 'ETH', 'ADA', 'SOL', 'DOT', 'AVAX', 'MATIC'];

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
      setState(() { _isLoading = true; _error = null; _articles = []; });
    }

    try {
      final currency = _selectedCurrency != 'All' ? _selectedCurrency : null;
      final response = await _newsService.fetchNews(currency: currency, limit: 20);

      if (response.error != null) {
        setState(() { _error = 'Unable to load news. Check your connection and try again.'; _isLoading = false; _isLoadingMore = false; });
        return;
      }

      setState(() {
        if (loadMore) { _articles.addAll(response.articles); } else { _articles = response.articles; }
        _isLoading = false;
        _isLoadingMore = false;
        _hasMore = response.articles.isNotEmpty;
      });
    } catch (e) {
      setState(() { _error = 'Something went wrong. Please try again later.'; _isLoading = false; _isLoadingMore = false; });
    }
  }

  Future<void> _loadSentiment() async {
    final data = await _newsService.getMarketSentiment();
    setState(() => _sentimentData = data);
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
          const SnackBar(content: Text('Could not open article'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article. Try again later.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Crypto News'),
        actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          _buildSentimentIndicator(context),
          _buildCurrencyFilter(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E)))
                : _error != null
                ? _buildErrorWidget(context)
                : _articles.isEmpty
                ? _buildEmptyWidget(context)
                : RefreshIndicator(
                    onRefresh: _refresh,
                    color: const Color(0xFF22C55E),
                    child: ListView.builder(
                      itemCount: _articles.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _articles.length) return _buildLoadMore(context);
                        return _buildNewsCard(context, _articles[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color;
    final borderColor = theme.dividerTheme.color ?? Colors.transparent;
    final subtleText = theme.textTheme.bodySmall?.color;

    if (_sentimentData == null || _sentimentData!['error'] != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_neutral, color: subtleText),
            const SizedBox(width: 12),
            Text(
              _sentimentData?['error'] ?? 'Market sentiment unavailable',
              style: TextStyle(color: subtleText),
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
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Market Sentiment', style: TextStyle(color: subtleText, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                      style: TextStyle(color: sentimentColor, fontWeight: FontWeight.bold, fontSize: 12),
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
              _buildSentimentStat('Total Articles', '$totalArticles', subtleText ?? Colors.grey),
              _buildSentimentStat('Bullish', '$bullish', Colors.green),
              _buildSentimentStat('Bearish', '$bearish', Colors.red),
              _buildSentimentStat('Neutral', '$neutral', Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (score + 1) / 2,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(score > 0 ? Colors.green : Colors.red),
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
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
      ],
    );
  }

  Widget _buildCurrencyFilter(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color;
    final borderColor = theme.dividerTheme.color ?? Colors.transparent;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _currencies.map((currency) {
          final isSelected = _selectedCurrency == currency ||
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
              backgroundColor: cardColor,
              selectedColor: const Color(0xFF22C55E).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF22C55E) : theme.textTheme.bodySmall?.color,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF22C55E) : borderColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, NewsArticle article) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color;
    final borderColor = theme.dividerTheme.color ?? Colors.transparent;
    final subtleText = theme.textTheme.bodySmall?.color;

    final isPositive = article.sentiment == NewsSentiment.bullish ||
        article.sentiment == NewsSentiment.positive;
    final isNegative = article.sentiment == NewsSentiment.bearish ||
        article.sentiment == NewsSentiment.negative;

    return GestureDetector(
      onTap: () => _openArticle(article.url),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPositive
                ? Colors.green.withOpacity(0.2)
                : isNegative
                ? Colors.red.withOpacity(0.2)
                : borderColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    color: theme.dividerTheme.color,
                    child: Icon(Icons.image, color: subtleText),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(article.source, style: TextStyle(color: subtleText, fontSize: 10)),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(article.publishedAt),
                        style: TextStyle(color: subtleText?.withOpacity(0.6), fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (article.coinSymbol != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: article.sentiment!.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(article.sentiment!.icon, color: article.sentiment!.color, size: 12),
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

  Widget _buildLoadMore(BuildContext context) {
    if (!_hasMore) return const SizedBox.shrink();
    final borderColor = Theme.of(context).dividerTheme.color ?? Colors.transparent;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoadingMore
            ? const CircularProgressIndicator(color: Color(0xFF22C55E))
            : OutlinedButton(
                onPressed: () { _currentPage++; _loadNews(loadMore: true); },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                  side: BorderSide(color: borderColor),
                ),
                child: const Text('Load More'),
              ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: theme.textTheme.bodySmall?.color?.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'Unable to load news.',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection and tap Try Again.',
              style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 14),
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

  Widget _buildEmptyWidget(BuildContext context) {
    final subtleText = Theme.of(context).textTheme.bodySmall?.color;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper, size: 60, color: subtleText?.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No news available', style: TextStyle(color: subtleText, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Check back later for updates', style: TextStyle(color: subtleText?.withOpacity(0.6), fontSize: 14)),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${difference.inDays ~/ 7}w ago';
  }
}
