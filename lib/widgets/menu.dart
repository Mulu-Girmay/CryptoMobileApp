import 'package:crypto/screens/Converter.dart';
import 'package:crypto/screens/portfolio_screen.dart';
import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.5,
      backgroundColor: const Color(0xFF020617),
      child: SafeArea(
        child: Container(
          color: const Color(0xFF0B1220),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text(
                  'List',
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(Icons.list, color: Color(0xFF22C55E)),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text(
                  'Converter',
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(Icons.equalizer, color: Color(0xFF22C55E)),
                onTap: () => _openScreen(context, ConverterScreen()),
              ),
              ListTile(
                title: const Text(
                  'Portfolio',
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF22C55E),
                ),
                onTap: () => _openScreen(context, const PortfolioScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
