import 'package:crypto/screens/cryptolist.dart';
import 'package:flutter/material.dart';
import '../model/coin.dart';
import '../utils/formatter.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  double totalBalance = 0.0;
  bool isLoading = false;
  bool showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _fetchTotalBalance();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTotalBalance() async {
    setState(() => isLoading = true);
    try {
      final coins = await fetchCoins('usd');
      double total = 0;
      for (int i = 0; i < (coins.length > 10 ? 10 : coins.length); i++) {
        total += coins[i].price;
      }
      setState(() {
        totalBalance = total;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1220),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Balance",
                      style: TextStyle(color: Colors.white54, fontSize: 14),
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
                          Text(
                            Formatter.formatPrice(totalBalance),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                        const Spacer(),
                        IconButton(
                          onPressed: _fetchTotalBalance,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search and Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1220),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search coins...",
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white54,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      searchController.clear();
                                      searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Favorites filter toggle
                  Container(
                    decoration: BoxDecoration(
                      color: showOnlyFavorites
                          ? const Color(0xFF22C55E).withOpacity(0.15)
                          : const Color(0xFF0B1220),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: showOnlyFavorites
                            ? const Color(0xFF22C55E)
                            : Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          showOnlyFavorites = !showOnlyFavorites;
                        });
                      },
                      icon: Icon(
                        showOnlyFavorites ? Icons.star : Icons.star_border,
                        color: showOnlyFavorites
                            ? Colors.amber
                            : Colors.white54,
                        size: 24,
                      ),
                      tooltip: showOnlyFavorites
                          ? 'Show all coins'
                          : 'Show favorites only',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Counter for favorites
              if (showOnlyFavorites)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Showing favorites only',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showOnlyFavorites = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Clear filter',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 12,
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
        ),
      ),
    );
  }
}
