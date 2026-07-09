import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../services/currency_service.dart';
import '../services/favorites_service.dart';
import '../services/favorites_storage.dart';
import '../services/refresh_service.dart';
import '../widgets/reusable_card.dart';
import '../widgets/coin_detail_dialog.dart';
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
  String? _errorMessage;
  String _currentCurrency = 'usd';

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
      _errorMessage = null;
    });

    try {
      _currentCurrency = _currencyService.currentCode;
      await _favoritesService.loadFavorites();
      final coins = await fetchCoins(_currentCurrency);

      setState(() {
        _coins = coins;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshCoins() async {
    if (_isRefreshing || _isLoading) return;

    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      _currentCurrency = _currencyService.currentCode;
      await _favoritesService.loadFavorites();
      final coins = await fetchCoins(_currentCurrency);

      setState(() {
        _coins = coins;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isRefreshing = false;
      });
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
      if (query.isNotEmpty) {
        final matchesSearch =
            coin.name.toLowerCase().contains(query) ||
            coin.symbol.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      if (widget.showOnlyFavorites) {
        return coin.isFavorite;
      }

      return true;
    }).toList();

    if (!widget.showOnlyFavorites) {
      filtered.sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return 0;
      });
    }

    return filtered;
  }

  void _showCoinDetail(Coin coin) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: 480,
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1220),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header - Shows coin info with price and change
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            coin.image,
                            width: 32,
                            height: 32,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.image,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    coin.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: coin.change >= 0
                                          ? Colors.green.withOpacity(0.15)
                                          : Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      Formatter.formatChange(coin.change),
                                      style: TextStyle(
                                        color: coin.change >= 0
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${coin.symbol.toUpperCase()} • ${Formatter.formatPrice(coin.price)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Favorite button in header
                        IconButton(
                          onPressed: () {
                            _toggleFavorite(coin);
                            // Force rebuild to update the star icon
                            setState(() {});
                          },
                          icon: Icon(
                            coin.isFavorite ? Icons.star : Icons.star_border,
                            color: coin.isFavorite
                                ? Colors.amber
                                : Colors.white54,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white54,
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable Content - Using DialogCoinDetail
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      child: DialogCoinDetail(
                        coin: coin,
                        onFavoriteToggle: () {
                          _toggleFavorite(coin);
                          // Force rebuild to update the star icon
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCoins,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredCoins = _filteredCoins;

    if (filteredCoins.isEmpty) {
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

    return RefreshIndicator(
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
            onTap: () => _showCoinDetail(coin),
          );
        },
      ),
    );
  }
}
