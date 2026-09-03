import 'dart:async';
import 'package:crypto/screens/alert_screen.dart';
import 'package:crypto/screens/Converter.dart';
import 'package:crypto/screens/news_screen.dart';
import 'package:crypto/screens/cryptoScreen.dart';
import 'package:crypto/screens/portfolio_screen.dart';
import 'package:crypto/screens/transaction_screen.dart';
import 'package:crypto/screens/currency_screen.dart';
import 'package:crypto/screens/refresh_setting_screen.dart';
import 'package:crypto/screens/theme_screen.dart';
import 'package:crypto/services/currency_service.dart';
import 'package:crypto/services/favorites_service.dart';
import 'package:crypto/services/theme_notifier.dart';
import 'package:crypto/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF22C55E),
                        child: Icon(Icons.currency_bitcoin, size: 40, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Crypto App',
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Track prices & trends in real-time',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF020617),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                    ),
                    SizedBox(height: 12),
                    Text('Loading market data...', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _favoritesCount = 0;
  final FavoritesService _favoritesService = FavoritesService();

  // Keep pages alive by using IndexedStack
  final List<Widget> _pages = const [
    _CoinsTab(),
    TransactionScreen(),
    PortfolioScreen(),
    AlertScreen(),
    ConverterScreen(),
    NewsScreen(),
    _SettingsPage(),
  ];

  final List<String> _titles = const [
    'Coin List',
    'Transactions',
    'Portfolio',
    'Price Alerts',
    'Converter',
    'News',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavoritesCount();
  }

  Future<void> _loadFavoritesCount() async {
    await _favoritesService.loadFavorites();
    if (mounted) {
      setState(() => _favoritesCount = _favoritesService.getFavorites().length);
    }
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _FavoritesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _currentIndex == 0
          ? AppBar(
              title: Text(_titles[_currentIndex]),
              actions: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      onPressed: _openFavorites,
                      icon: const Icon(Icons.star),
                      tooltip: 'Favorites',
                    ),
                    if (_favoritesCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$_favoritesCount',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) _loadFavoritesCount();
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: theme.textTheme.bodySmall?.color,
        backgroundColor: theme.cardTheme.color,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Coins'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Converter'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// Coins tab wrapper — CryptoScreen returns Padding, needs a colored background
class _CoinsTab extends StatelessWidget {
  const _CoinsTab();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const CryptoScreen(),
    );
  }
}

// Favorites page — shows CryptoScreen filtered to favorites only
class _FavoritesPage extends StatelessWidget {
  const _FavoritesPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const CryptoScreen(showOnlyFavorites: true),
      ),
    );
  }
}

// Settings page shown in the 5th tab
class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color;
    final borderColor = theme.dividerTheme.color ?? Colors.transparent;
    final themeNotifier = context.watch<ThemeNotifier>();
    final currencyService = CurrencyService();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // App info card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            gradient: LinearGradient(
              colors: [AppTheme.primaryGreen.withOpacity(0.08), Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.currency_bitcoin, color: AppTheme.primaryGreen, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crypto App', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Version 1.0.0', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _sectionHeader('Appearance', theme),
        const SizedBox(height: 8),

        _settingsTile(
          context: context,
          icon: Icons.palette,
          title: 'Theme',
          subtitle: '${themeNotifier.getThemeModeName()} mode',
          trailing: Icon(themeNotifier.getThemeModeIcon(), color: AppTheme.primaryGreen, size: 20),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeScreen())),
        ),

        const SizedBox(height: 24),
        _sectionHeader('Preferences', theme),
        const SizedBox(height: 8),

        _settingsTile(
          context: context,
          icon: Icons.currency_exchange,
          title: 'Currency',
          subtitle: '${currencyService.selectedCurrency.flag} ${currencyService.selectedCurrency.name}',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyScreen())),
        ),

        _settingsTile(
          context: context,
          icon: Icons.timer,
          title: 'Auto Refresh',
          subtitle: 'Configure refresh interval',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RefreshSettingsScreen())),
        ),

        const SizedBox(height: 24),
        _sectionHeader('About', theme),
        const SizedBox(height: 8),

        _settingsTile(
          context: context,
          icon: Icons.info_outline,
          title: 'About Crypto App',
          subtitle: 'Features & information',
          onTap: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: theme.textTheme.bodySmall?.color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _settingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        ),
        title: Text(title, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
        trailing: trailing ?? Icon(Icons.chevron_right, color: theme.textTheme.bodySmall?.color),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
            Icon(Icons.currency_bitcoin, size: 50, color: AppTheme.primaryGreen),
            SizedBox(height: 16),
            Text('Crypto App v1.0.0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('A comprehensive cryptocurrency tracking app built with Flutter.', style: TextStyle(color: Colors.grey)),
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
            child: const Text('Close', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }
}
