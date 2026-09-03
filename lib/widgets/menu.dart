import 'package:crypto/screens/alert_screen.dart';
import 'package:crypto/screens/Converter.dart';
import 'package:crypto/screens/cryptoScreen.dart';
import 'package:crypto/screens/currency_screen.dart';
import 'package:crypto/screens/portfolio_screen.dart';
import 'package:crypto/screens/theme_screen.dart';
import 'package:crypto/services/currency_service.dart';
import 'package:crypto/services/favorites_service.dart';
import 'package:crypto/services/refresh_service.dart';
import 'package:crypto/services/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/refresh_setting_screen.dart';
import '../services/theme_service.dart';
import '../screens/transaction_screen.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  final FavoritesService _favoritesService = FavoritesService();
  final CurrencyService _currencyService = CurrencyService();
  final RefreshService _refreshService = RefreshService();
  int _favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFavoritesCount();
  }

  Future<void> _loadFavoritesCount() async {
    await _favoritesService.loadFavorites();
    if (mounted) {
      setState(() {
        _favoritesCount = _favoritesService.getFavorites().length;
      });
    }
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CryptoScreen(),
        settings: const RouteSettings(arguments: {'showFavorites': true}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final theme = Theme.of(context);

    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.6,
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Container(
          color: theme.cardTheme.color,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerTheme.color ?? Colors.transparent,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppTheme.primaryGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crypto App',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_currencyService.selectedCurrency.flag} ${_currencyService.selectedCurrency.code.toUpperCase()}',
                            style: const TextStyle(
                              color: Colors.grey,
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
                    _buildSectionHeader('Main'),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      icon: Icons.list,
                      title: 'Coin List',
                      subtitle: 'Browse all cryptocurrencies',
                      onTap: () => Navigator.of(context).pop(),
                      isActive: true,
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      icon: Icons.equalizer,
                      title: 'Converter',
                      subtitle: 'Convert between currencies',
                      onTap: () =>
                          _openScreen(context, const ConverterScreen()),
                    ),
                    const Divider(height: 32),
                    _buildSectionHeader('Portfolio'),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      icon: Icons.account_balance_wallet,
                      title: 'Portfolio',
                      subtitle: 'Track your investments',
                      onTap: () =>
                          _openScreen(context, const PortfolioScreen()),
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      icon: Icons.receipt_long,
                      title: 'Transactions',
                      subtitle: 'View transaction history',
                      onTap: () =>
                          _openScreen(context, const TransactionScreen()),
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      icon: Icons.notifications_active,
                      title: 'Price Alerts',
                      subtitle: 'Get notified on price changes',
                      onTap: () => _openScreen(context, const AlertScreen()),
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      icon: Icons.star,
                      title: 'Favorites',
                      subtitle: 'Your favorite coins',
                      onTap: () => _navigateToFavorites(context),
                      isFavorite: true,
                      showBadge: true,
                      badgeText: _favoritesCount > 0 ? '$_favoritesCount' : '',
                      badgeColor: Colors.amber,
                    ),
                    const Divider(height: 32),
                    _buildSectionHeader('Settings'),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      icon: Icons.currency_exchange,
                      title: 'Currency',
                      subtitle:
                          '${_currencyService.selectedCurrency.flag} ${_currencyService.selectedCurrency.code.toUpperCase()}',
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CurrencyScreen(),
                          ),
                        );
                        if (result == true) setState(() {});
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      icon: Icons.timer,
                      title: 'Refresh',
                      subtitle:
                          '${_refreshService.isRunning ? 'Auto' : 'Manual'} refresh',
                      onTap: () =>
                          _openScreen(context, const RefreshSettingsScreen()),
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      icon: Icons.palette,
                      title: 'Theme',
                      subtitle: '${themeNotifier.getThemeModeName()} mode',
                      onTap: () => _openScreen(context, const ThemeScreen()),
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'Version 1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.dividerTheme.color ?? Colors.transparent,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Crypto App v1.0.0',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    IconButton(
                      onPressed: () {
                        _loadFavoritesCount();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Refreshed!'),
                            backgroundColor: AppTheme.primaryGreen,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.grey,
                        size: 18,
                      ),
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
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isActive = false,
    bool isFavorite = false,
    bool showBadge = false,
    String badgeText = '',
    Color badgeColor = AppTheme.primaryGreen,
  }) {
    final iconColor = isActive
        ? AppTheme.primaryGreen
        : isFavorite
        ? Colors.amber
        : theme.iconTheme.color?.withOpacity(0.6) ?? Colors.grey;

    final titleColor =
        isActive ? AppTheme.primaryGreen : theme.textTheme.bodyLarge?.color;

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 11),
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
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(3),
              ),
            )
          : null,
      onTap: onTap,
      tileColor: isActive
          ? AppTheme.primaryGreen.withOpacity(0.05)
          : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Crypto App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(
              Icons.currency_bitcoin,
              size: 50,
              color: AppTheme.primaryGreen,
            ),
            SizedBox(height: 16),
            Text(
              'Crypto App v1.0.0',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'A comprehensive cryptocurrency tracking app built with Flutter.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
              '• Live price tracking\n• Portfolio management\n• Price alerts\n• Favorites watchlist\n• Interactive charts\n• Currency converter\n• Multi-currency support\n• Auto-refresh\n• Dark/Light theme',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}
