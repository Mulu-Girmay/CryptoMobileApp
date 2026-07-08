import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../services/currency_service.dart';
import '../services/favorites_service.dart';
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

class _CryptoListState extends State<CryptoList> {
  final FavoritesService _favoritesService = FavoritesService();
  final CurrencyService _currencyService = CurrencyService();
  List<Coin> _coins = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _currentCurrency = 'usd';

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  @override
  void didUpdateWidget(CryptoList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showOnlyFavorites != widget.showOnlyFavorites ||
        oldWidget.searchQuery != widget.searchQuery) {
      // Just refresh the UI, no need to reload data
      setState(() {});
    }
  }

  Future<void> _loadCoins() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get current currency from service
      _currentCurrency = _currencyService.currentCode;

      // Load favorites
      await _favoritesService.loadFavorites();

      // Fetch coins with selected currency
      final coins = await fetchCoins(_currentCurrency);

      setState(() {
        _coins = coins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Refresh when currency changes
  Future<void> _refreshCoins() async {
    await _loadCoins();
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
      // Filter by search query
      if (query.isNotEmpty) {
        final matchesSearch =
            coin.name.toLowerCase().contains(query) ||
            coin.symbol.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Filter by favorites
      if (widget.showOnlyFavorites) {
        return coin.isFavorite;
      }

      return true;
    }).toList();

    // Sort favorites to the top when not in favorites-only mode
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF22C55E)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 12),
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadCoins,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
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
                            coin.isFavorite ? Icons.star : Icons.star_border,
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
    );
  }
}
