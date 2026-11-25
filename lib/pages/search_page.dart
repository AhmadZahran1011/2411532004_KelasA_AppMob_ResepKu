import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_tile.dart';
import '../widgets/error_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final RecipeService _recipeService = RecipeService();
  final TextEditingController _searchController = TextEditingController();
  Future<List<Recipe>>? _searchFuture;

  void _performSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _searchFuture = _recipeService.searchRecipes(trimmed);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari nama resep atau bahan...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchFuture = null;
                });
              },
            ),
          ),
          onSubmitted: _performSearch,
        ),
      ),
      body: _searchFuture == null
          ? const Center(
              child: Text('Ketik kata kunci lalu tekan Enter untuk mencari.'),
            )
          : FutureBuilder<List<Recipe>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: () => _performSearch(_searchController.text),
                  );
                }

                final recipes = snapshot.data ?? [];
                if (recipes.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ditemukan resep untuk "${_searchController.text}".',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return RecipeTile(recipe: recipes[index]);
                  },
                );
              },
            ),
    );
  }
}