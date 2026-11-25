import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/services/recipe_service.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late int _servings; // state lokal: hanya halaman ini yang butuh

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings; // nilai awal dari data resep
  }

  void _addServing() {
    setState(() => _servings++);
  }

  void _removeServing() {
    if (_servings > 1) {
      setState(() => _servings--);
    }
  }

  // Latihan 2: Dialog Ubah Nama + Request PUT /recipes/{id}
  Future<void> _renameRecipe() async {
    final controller = TextEditingController(text: widget.recipe.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah nama resep'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama baru',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (!mounted || newName == null || newName.isEmpty) return;

    try {
      final updated = await context
          .read<RecipeService>()
          .updateRecipe(widget.recipe.id, newName);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nama diperbarui menjadi "${updated.name}". '
            'dummyjson hanya menyimulasikan perubahan.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah nama: $e')),
      );
    }
  }

  // Latihan 2: Dialog Konfirmasi + Request DELETE /recipes/{id}
  Future<void> _deleteRecipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus resep?'),
        content: Text('Resep "${widget.recipe.name}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      final isDeleted = await context
          .read<RecipeService>()
          .deleteRecipe(widget.recipe.id);

      if (!mounted) return;
      if (isDeleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${widget.recipe.name}" berhasil dihapus.')),
        );
        Navigator.pop(context); // Tutup halaman detail
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus resep: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final totalCalories = recipe.caloriesPerServing * _servings;
    final isFavorite = context.watch<FavoriteProvider>().isFavorite(recipe);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. SliverAppBar dengan foto resep yang mengecil saat di-scroll
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () =>
                    context.read<FavoriteProvider>().toggle(recipe),
              ),
              // Latihan 2: PopupMenuButton setelah tombol favorit
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _renameRecipe();
                  } else if (value == 'delete') {
                    _deleteRecipe();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Ubah nama'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: recipe.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: Icon(Icons.restaurant_menu, size: 40),
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. Bagian info resep, pengatur porsi, kalori, dan judul "Bahan" di SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${recipe.cuisine} • ${recipe.difficulty} • ${recipe.totalTimeMinutes} menit',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Text('Porsi', style: textTheme.titleMedium),
                          const Spacer(),
                          IconButton.filledTonal(
                            onPressed: _servings > 1 ? _removeServing : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('$_servings', style: textTheme.titleLarge),
                          ),
                          IconButton.filledTonal(
                            onPressed: _addServing,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total kalori: $totalCalories kkal',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Text('Bahan', style: textTheme.titleLarge),
                ],
              ),
            ),
          ),

          // 3. Daftar bahan menggunakan SliverList.builder
          SliverList.builder(
            itemCount: recipe.ingredients.length,
            itemBuilder: (context, index) {
              final item = recipe.ingredients[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(item),
                ),
              );
            },
          ),

          // Judul "Langkah": widget biasa dibungkus SliverToBoxAdapter
          if (recipe.instructions.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Text('Langkah', style: textTheme.titleLarge),
              ),
            ),

          // Daftar langkah: lazy, sama seperti daftar bahan
          SliverList.builder(
            itemCount: recipe.instructions.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 12,
                  child: Text('${index + 1}'),
                ),
                title: Text(recipe.instructions[index]),
              ),
            ),
          ),

          // Jarak bawah agar list terakhir nyaman di-scroll
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}