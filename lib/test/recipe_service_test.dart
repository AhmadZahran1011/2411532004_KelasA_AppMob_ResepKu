import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/services/recipe_service.dart';

void main() {
  group('Model Recipe', () {
    test('fromJson membaca rating int sebagai double dan memberi nilai bawaan', () {
      final jsonMap = {
        'id': 1,
        'name': 'Nasi Goreng',
        'rating': 5, // tipe int
        // field lain sengaja dikosongkan untuk menguji nilai default
      };

      final recipe = Recipe.fromJson(jsonMap);

      expect(recipe.id, 1);
      expect(recipe.name, 'Nasi Goreng');
      expect(recipe.rating, 5.0);
      expect(recipe.rating, isA<double>());
      // Sesuaikan ekspektasi default berikut dengan properti di model Recipe Anda
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
    });
  });

  group('RecipeService dengan MockClient', () {
    test('fetchRecipes mengembalikan List<Recipe> saat status 200', () async {
      final mockClient = MockClient((request) async {
        final fakeResponse = {
          'recipes': [
            {'id': 1, 'name': 'Rendang', 'rating': 5},
            {'id': 2, 'name': 'Sate Ayam', 'rating': 4.8},
          ]
        };
        return http.Response(json.encode(fakeResponse), 200);
      });

      final service = RecipeService(client: mockClient);
      final recipes = await service.fetchRecipes();

      expect(recipes, isA<List<Recipe>>());
      expect(recipes.length, 2);
      expect(recipes[0].name, 'Rendang');
      expect(recipes[0].rating, 5.0);
    });

    test('fetchRecipes melempar RecipeServiceException saat status 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = RecipeService(client: mockClient);

      expect(
        () => service.fetchRecipes(),
        throwsA(isA<RecipeServiceException>()),
      );
    });
  });
}