import 'package:crypto/screens/alert_screen.dart';
import 'package:crypto/screens/Converter.dart';
import 'package:crypto/screens/cryptoScreen.dart';
import 'package:crypto/screens/portfolio_screen.dart';
import 'package:crypto/services/favorites_service.dart';
import 'package:flutter/material.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  final FavoritesService _favoritesService = FavoritesService();
  int _favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFavoritesCount();
  }

  Future<void> _loadFavoritesCount() async {
    await _favoritesService.loadFavorites();
    setState(() {
      _favoritesCount = _favoritesService.getFavorites().length;
    });
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.of(context).pop();
    // Navigate to home with favorites filter
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CryptoScreen(),
        settings: const RouteSettings(arguments: {'showFavorites': true}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.6,
      backgroundColor: const Color(0xFF020617),
      child: SafeArea(
        child: Container(
          color: const Color(0xFF0B1220),
          child: Column(
            children: [
              // Header with profile
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF22C55E).withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF22C55E),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crypto App',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Track & manage your crypto',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Section: Main
                    _buildSectionHeader('Main'),

                    _buildMenuItem(
                      icon: Icons.list,
                      title: 'Coin List',
                      subtitle: 'Browse all cryptocurrencies',
                      onTap: () => Navigator.of(context).pop(),
                      isActive: true,
                    ),

                    _buildMenuItem(
                      icon: Icons.equalizer,
                      title: 'Converter',
                      subtitle: 'Convert between currencies',
                      onTap: () =>
                          _openScreen(context, const ConverterScreen()),
                    ),

                    const Divider(color: Colors.white12, height: 32),

                    // Section: Portfolio
                    _buildSectionHeader('Portfolio'),

                    _buildMenuItem(
                      icon: Icons.account_balance_wallet,
                      title: 'Portfolio',
                      subtitle: 'Track your investments',
                      onTap: () =>
                          _openScreen(context, const PortfolioScreen()),
                      showBadge: true,
                      badgeText:
                          '${_favoritesCount > 0 ? _favoritesCount : ''}',
                    ),

                    _buildMenuItem(
                      icon: Icons.notifications_active,
                      title: 'Price Alerts',
                      subtitle: 'Get notified on price changes',
                      onTap: () => _openScreen(context, const AlertScreen()),
                    ),
                    _buildMenuItem(
                      icon: Icons.show_chart,
                      title: 'Charts',
                      subtitle: 'View price trends',
                      onTap: () {
                        // Navigate to a chart screen with default coin (e.g., Bitcoin)
                        // You could show a list of coins first
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tap a coin to view its chart'),
                            backgroundColor: Color(0xFF22C55E),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.star,
                      title: 'Favorites',
                      subtitle: 'Your favorite coins',
                      onTap: () => _navigateToFavorites(context),
                      isFavorite: true,
                      showBadge: true,
                      badgeText: _favoritesCount > 0 ? '$_favoritesCount' : '',
                      badgeColor: Colors.amber,
                    ),

                    const Divider(color: Colors.white12, height: 32),

                    // Section: Settings
                    _buildSectionHeader('Settings'),

                    _buildMenuItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      onTap: () {
                        // TODO: Implement settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Settings coming soon!'),
                            backgroundColor: Color(0xFF22C55E),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'Version 1.0.0',
                      onTap: () {
                        // TODO: Implement about dialog
                        _showAboutDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Crypto App v1.0.0',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // TODO: Implement dark/light mode toggle
                          },
                          icon: const Icon(
                            Icons.dark_mode,
                            color: Colors.white38,
                            size: 18,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Implement refresh
                            _loadFavoritesCount();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Refreshed!'),
                                backgroundColor: Color(0xFF22C55E),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white38,
                            size: 18,
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isActive = false,
    bool isFavorite = false,
    bool showBadge = false,
    String badgeText = '',
    Color badgeColor = const Color(0xFF22C55E),
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive
            ? const Color(0xFF22C55E)
            : isFavorite
            ? Colors.amber
            : Colors.white54,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? const Color(0xFF22C55E) : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white38, fontSize: 11),
      ),
      trailing: showBadge && badgeText.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeColor.withOpacity(0.3)),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            )
          : isActive
          ? Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(3),
              ),
            )
          : null,
      onTap: onTap,
      tileColor: isActive
          ? const Color(0xFF22C55E).withOpacity(0.05)
          : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text(
          'About Crypto App',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.currency_bitcoin, size: 50, color: Color(0xFF22C55E)),
            SizedBox(height: 16),
            Text(
              'Crypto App v1.0.0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A comprehensive cryptocurrency tracking app built with Flutter.',
              style: TextStyle(color: Colors.white54),
            ),
            SizedBox(height: 8),
            Text(
              'Features:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '• Live price tracking\n• Portfolio management\n• Price alerts\n• Favorites watchlist\n• Interactive charts\n• Currency converter',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
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
      ),
    );
  }
}
