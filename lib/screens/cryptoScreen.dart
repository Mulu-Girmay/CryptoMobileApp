import 'package:crypto/screens/cryptolist.dart';
import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../services/currency_service.dart';
import '../utils/formatter.dart';

class CryptoScreen extends StatefulWidget {
  final bool showOnlyFavorites;
  const CryptoScreen({super.key, this.showOnlyFavorites = false});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  final TextEditingController searchController = TextEditingController();
  final CurrencyService _currencyService = CurrencyService();
  String searchQuery = '';
  double totalBalance = 0.0;
  bool isLoading = false;
  late bool showOnlyFavorites;

  @override
  void initState() {
    super.initState();
    showOnlyFavorites = widget.showOnlyFavorites;
    _fetchTotalBalance();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTotalBalance() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final currency = _currencyService.currentCode;
      final coins = await fetchCoins(currency);
      double total = 0;
      for (int i = 0; i < (coins.length > 10 ? 10 : coins.length); i++) {
        total += coins[i].price;
      }
      if (mounted) {
        setState(() {
          totalBalance = total;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color;
    final dividerColor = theme.dividerTheme.color ?? Colors.transparent;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Total Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currencyService.currentCode.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (isLoading)
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF22C55E),
                          ),
                        )
                      else
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              Formatter.formatPrice(totalBalance),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                          ),
                        ),
                      IconButton(
                        onPressed: _fetchTotalBalance,
                        icon: Icon(
                          Icons.refresh,
                          color: theme.textTheme.bodySmall?.color,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search and Filter Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: dividerColor),
                    ),
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search coins...',
                        hintStyle: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.textTheme.bodySmall?.color,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: theme.textTheme.bodySmall?.color,
                                  size: 18,
                                ),
                                onPressed: () => setState(() {
                                  searchController.clear();
                                  searchQuery = '';
                                }),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: showOnlyFavorites
                        ? const Color(0xFF22C55E).withOpacity(0.15)
                        : cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: showOnlyFavorites
                          ? const Color(0xFF22C55E)
                          : dividerColor,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () =>
                        setState(() => showOnlyFavorites = !showOnlyFavorites),
                    icon: Icon(
                      showOnlyFavorites ? Icons.star : Icons.star_border,
                      color: showOnlyFavorites ? Colors.amber : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (showOnlyFavorites)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Showing favorites only',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => showOnlyFavorites = false),
                      child: const Text(
                        'Clear filter',
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: CryptoList(
                searchQuery: searchQuery,
                showOnlyFavorites: showOnlyFavorites,
              ),
            ),
          ],
        ),
      );
  }
}
