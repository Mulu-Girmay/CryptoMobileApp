import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../services/currency_service.dart';
import '../services/favorites_service.dart';
import '../services/refresh_service.dart';
import '../utils/error_handler.dart';
import '../widgets/reusable_card.dart';
import '../utils/formatter.dart';

class CryptoList extends StatefulWidget {
  final int columns;
  final String searchQuery;
  final bool showOnlyFavorites;

  const CryptoList({
    super.key,
    this.columns = 2,
    this.searchQuery = '',
    this.showOnlyFavorites = false,
  });

  @override
  State<CryptoList> createState() => _CryptoListState();
}

class _CryptoListState extends State<CryptoList>
    with AutomaticKeepAliveClientMixin {
  final FavoritesService _favoritesService = FavoritesService();
  final CurrencyService _currencyService = CurrencyService();
  final RefreshService _refreshService = RefreshService();

  List<Coin> _coins = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  AppError? _error;
  String _currentCurrency = 'usd';
  DateTime _lastUpdated = DateTime.now();
  String _lastUpdatedText = 'Never';
  int _retryCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCoins();
    _refreshService.addListener(_onAutoRefresh);
  }

  @override
  void dispose() {
    _refreshService.removeListener(_onAutoRefresh);
    super.dispose();
  }

  void _onAutoRefresh() {
    if (mounted && !_isRefreshing && !_isLoading) {
      _refreshCoins();
    }
  }

  Future<void> _loadCoins() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _currentCurrency = _currencyService.currentCode;

      // Load favorites
      await _favoritesService.loadFavorites();

      // Fetch coins with error handling
      final result = await fetchCoinsWithErrorHandling(_currentCurrency);

      if (result.error != null) {
        setState(() {
          _error = result.error;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _coins = result.coins;
        _isLoading = false;
        _isRefreshing = false;
        _lastUpdated = DateTime.now();
        _updateLastUpdatedText();
        _retryCount = 0;
      });
    } catch (e) {
      setState(() {
        _error = AppError.fromException(e);
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshCoins() async {
    if (_isRefreshing || _isLoading) return;

    setState(() {
      _isRefreshing = true;
      _error = null;
    });

    try {
      _currentCurrency = _currencyService.currentCode;

      // Load favorites
      await _favoritesService.loadFavorites();

      // Fetch coins with error handling
      final result = await fetchCoinsWithErrorHandling(_currentCurrency);

      if (result.error != null) {
        setState(() {
          _error = result.error;
          _isRefreshing = false;
        });
        return;
      }

      setState(() {
        _coins = result.coins;
        _isRefreshing = false;
        _lastUpdated = DateTime.now();
        _updateLastUpdatedText();
        _retryCount = 0;
      });
    } catch (e) {
      setState(() {
        _error = AppError.fromException(e);
        _isRefreshing = false;
      });
    }
  }

  void _updateLastUpdatedText() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inMinutes < 1) {
      _lastUpdatedText = 'Just now';
    } else if (difference.inMinutes < 60) {
      _lastUpdatedText = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      _lastUpdatedText = '${difference.inHours}h ago';
    } else {
      _lastUpdatedText = '${difference.inDays}d ago';
    }
  }

  Future<void> _toggleFavorite(Coin coin) async {
    await _favoritesService.toggleFavorite(coin.id);

    setState(() {
      final index = _coins.indexWhere((c) => c.id == coin.id);
      if (index != -1) {
        _coins[index] = _coins[index].copyWithFavorite(
          !_coins[index].isFavorite,
        );
      }
    });
  }

  List<Coin> get _filteredCoins {
    final query = widget.searchQuery.trim().toLowerCase();

    var filtered = _coins.where((coin) {
      // Search filter
      if (query.isNotEmpty) {
        final matchesSearch =
            coin.name.toLowerCase().contains(query) ||
            coin.symbol.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Favorites filter
      if (widget.showOnlyFavorites) {
        return coin.isFavorite;
      }

      return true;
    }).toList();

    // Sort favorites to the top
    if (!widget.showOnlyFavorites) {
      filtered.sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return 0;
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Show loading
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF22C55E)),
            SizedBox(height: 16),
            Text('Loading coins...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    // Show error with retry
    if (_error != null) {
      return ErrorHandler.buildErrorWidget(
        context,
        _error!,
        onRetry: () {
          _retryCount++;
          _loadCoins();
        },
        onDismiss: () {
          setState(() {
            _error = null;
            _isLoading = false;
          });
        },
      );
    }

    final filteredCoins = _filteredCoins;

    if (filteredCoins.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.showOnlyFavorites ? Icons.star_border : Icons.search_off,
              size: 60,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              widget.showOnlyFavorites
                  ? 'No favorite coins yet'
                  : 'No coins found',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.showOnlyFavorites
                  ? 'Star your favorite coins to see them here'
                  : 'Try adjusting your search',
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Last updated indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _refreshService.isRunning
                    ? Icons.refresh
                    : Icons.not_interested,
                size: 12,
                color: _refreshService.isRunning
                    ? Colors.green
                    : Colors.white38,
              ),
              const SizedBox(width: 4),
              Text(
                _isRefreshing ? 'Refreshing...' : 'Updated $_lastUpdatedText',
                style: TextStyle(
                  color: _isRefreshing ? Colors.green : Colors.white38,
                  fontSize: 11,
                ),
              ),
              if (_isRefreshing)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                ),
              if (_retryCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Retry $_retryCount',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Main grid
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshCoins,
            color: const Color(0xFF22C55E),
            backgroundColor: const Color(0xFF0B1220),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: filteredCoins.length,
              itemBuilder: (context, index) {
                final coin = filteredCoins[index];

                return ReusableCard(
                  coin: coin,
                  onFavoriteToggle: () => _toggleFavorite(coin),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final media = MediaQuery.sizeOf(context);
                        final maxDialogWidth = media.width - 48;

                        return AlertDialog(
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          backgroundColor: const Color(0xFF0B1220),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  coin.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _toggleFavorite(coin),
                                icon: Icon(
                                  coin.isFavorite
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: coin.isFavorite
                                      ? Colors.amber
                                      : Colors.white54,
                                ),
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          content: SizedBox(
                            width: maxDialogWidth,
                            child: SingleChildScrollView(
                              child: OnClickReusableCard(
                                coin: coin,
                                onFavoriteToggle: () => _toggleFavorite(coin),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Close',
                                style: TextStyle(color: Color(0xFF22C55E)),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
