import 'package:crypto/screens/Converter.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Container(
          color: const Color.fromARGB(56, 66, 58, 58),
          child: ListView(
            children: [
              ListTile(
                title: const Text('List'),
                leading: const Icon(Icons.list),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Converter'),
                leading: const Icon(Icons.equalizer),
                onTap: () => _openScreen(context, const ConverterScreen()),
              ),
              ListTile(
                title: const Text('Portfolio'),
                leading: const Icon(Icons.account_balance_wallet),
                onTap: () => _openScreen(context, const PortfolioScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Portfolio screen coming soon')),
    );
  }
}
