import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/pages/detail_page.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/widgets/recipe_image.dart';

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
    final items = favorite.items.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Semua',
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
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final recipe = items[index];

                return Dismissible(
                  key: ValueKey(recipe.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context.read<FavoriteProvider>().toggle(recipe);

                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${recipe.name} dihapus dari favorit'),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: RecipeImage(
                          url: recipe.image,
                          cacheWidth: 160,
                        ),
                      ),
                    ),
                    title: Text(
                      recipe.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(recipe.cuisine),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(recipe: recipe),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}