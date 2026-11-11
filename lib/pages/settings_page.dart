import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text('Aktifkan tema gelap untuk seluruh aplikasi'),
            secondary: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode_outlined,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              context.read<ThemeProvider>().toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }
}