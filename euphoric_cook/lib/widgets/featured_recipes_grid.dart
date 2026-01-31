import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/mode_provider.dart';
import 'recipe_card.dart';

class FeaturedRecipesGrid extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> recipes;
  final int crossAxisCount;

  const FeaturedRecipesGrid({
    super.key,
    required this.title,
    required this.recipes,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];

            return RecipeCard(
              name: recipe['name'] as String? ?? 'Unnamed ${mode.isFood ? 'Recipe' : 'Drink'}',
              imageUrl: recipe['imageUrl'] as String?,
              servings: recipe['servings'] as int?,
              totalTimeMinutes: recipe['totalTimeMinutes'] as int?,
              alcoholType: recipe['alcoholType'] as String?,
            );
          },
        ),

        const SizedBox(height: 100),
      ],
    );
  }
}