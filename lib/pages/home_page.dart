import 'package:flutter/material.dart';
import 'package:resepku/data/dummy_recipes.dart';
import 'package:resepku/models/recipe.dart'; 
import 'package:resepku/pages/settings_page.dart';
import 'package:resepku/widgets/favorite_badge_button.dart';
import 'package:resepku/widgets/recipe_grid_card.dart';
import 'package:resepku/widgets/recipe_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGrid = false; // ephemeral state: hanya HomePage yang membutuhkan
  String? _cuisine; // 1. State filter cuisine (null = Semua)

  @override
  Widget build(BuildContext context) {
    // 2. Ambil daftar cuisine unik dari data
    final cuisines = dummyRecipes.map((r) => r.cuisine).toSet().toList();

    // Filter daftar resep berdasarkan _cuisine yang dipilih
    final filteredRecipes = _cuisine == null
        ? dummyRecipes
        : dummyRecipes.where((r) => r.cuisine == _cuisine).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text('ResepKu'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isGrid ? 'Tampilan list' : 'Tampilan grid',
            icon: Icon(
              _isGrid ? Icons.view_list : Icons.grid_view,
            ),
            onPressed: () => setState(() {
              _isGrid = !_isGrid;
            }),
          ),
          const FavoriteBadgeButton(),
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            ),
          ),
        ],
      ),
      // 3. Body menggunakan Column
      body: Column(
        children: [
          // Deretan ChoiceChip di dalam SizedBox(height: 56) berisi ListView horizontal
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Semua'),
                    selected: _cuisine == null,
                    onSelected: (_) => setState(() => _cuisine = null),
                  ),
                ),
                ...cuisines.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _cuisine == c,
                      onSelected: (_) => setState(() => _cuisine = c),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 4. Expanded berisi list atau grid dengan data yang sudah difilter
          Expanded(
            child: _isGrid
                ? _buildGrid(filteredRecipes)
                : _buildList(filteredRecipes),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Recipe> recipes) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return RecipeTile(
          recipe: recipes[index],
        );
      },
    );
  }

  Widget _buildGrid(List<Recipe> recipes) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 4, // lebar : tinggi
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return RecipeGridCard(
          recipe: recipes[index],
        );
      },
    );
  }
}