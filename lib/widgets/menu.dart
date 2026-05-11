import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

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
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Converter'),
                leading: const Icon(Icons.equalizer),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
