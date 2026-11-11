import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/widgets/recipe_tile.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Semua Favorit?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus seluruh resep dari daftar favorit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              context.read<FavoriteProvider>().clear();
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorite = context.watch<FavoriteProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Semua',
            // Tombol nonaktif jika daftar favorit kosong
            onPressed: favorite.count == 0
                ? null
                : () => _showClearConfirmationDialog(context),
          ),
        ],
      ),
      body: favorite.count == 0
          ? const Center(
              child: Text(
                'Belum ada resep favorit.\nTekan ikon hati di daftar resep.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              children: [
                for (final recipe in favorite.items) RecipeTile(recipe: recipe),
              ],
            ),
    );
  }
}