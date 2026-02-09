import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/mode_provider.dart';
import '../widgets/featured_recipes_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedChipIndex = -1;

  Future<List<Map<String, dynamic>>> _fetchFeaturedRecipes(bool isFood) async {
    final int desiredCount = 10;
    final tags = isFood ? '' : 'beverage';

    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/random'
          '?apiKey=9333c1e5442a422ea040f38a3f453614'
          '&number=$desiredCount'
          '${tags.isNotEmpty ? '&tags=$tags' : ''}',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load ${isFood ? "recipes" : "drinks"}: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final List recipes = data['recipes'];

    List<Map<String, dynamic>> alcoholic = [];
    List<Map<String, dynamic>> nonAlcoholic = [];
    List<Map<String, dynamic>> foodResults = [];

    for (var r in recipes) {
      final imageUrl = r['image'];
      if (imageUrl == null || imageUrl.isEmpty) continue;

      final title = (r['title'] as String).toLowerCase();

      if (!isFood) {
        bool isAlcoholic = title.contains('beer') ||
            title.contains('wine') ||
            title.contains('vodka') ||
            title.contains('rum') ||
            title.contains('whiskey') ||
            title.contains('tequila') ||
            title.contains('cocktail');

        bool isNonAlcoholic = title.contains('mocktail') ||
            title.contains('smoothie') ||
            title.contains('juice') ||
            title.contains('tea') ||
            title.contains('coffee') ||
            title.contains('lemonade') ||
            title.contains('milk');

        final drink = {
          'name': r['title'],
          'imageUrl': imageUrl,
          'servings': r['servings'],
          'totalTimeMinutes': r['readyInMinutes'],
          'alcoholType': isAlcoholic ? 'alcoholic' : 'non-alcoholic',
        };

        if (isAlcoholic) alcoholic.add(drink);
        if (isNonAlcoholic) nonAlcoholic.add(drink);
      } else {
        foodResults.add({
          'name': r['title'],
          'imageUrl': imageUrl,
          'servings': r['servings'],
          'totalTimeMinutes': r['readyInMinutes'],
          'alcoholType': null,
        });
      }
    }

    if (isFood) return foodResults;

    final int half = desiredCount ~/ 2;
    return [
      ...alcoholic.take(half),
      ...nonAlcoholic.take(half),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);
    final accent = mode.accentColor;

    return Scaffold(
      backgroundColor: mode.bgColor,
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchFeaturedRecipes(mode.isFood),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error loading ${mode.isFood ? "recipes" : "drinks"}:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            }

            final featuredRecipes = snapshot.data ?? [];

            return CustomScrollView(
              slivers: [
                // Header (theme + toggle)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                mode.isDark ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                                color: accent,
                                size: 28,
                              ),
                              onPressed: mode.toggleTheme,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _buildFoodDrinkToggle(mode),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Material(
                        key: ValueKey(mode.currentMode),
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                        color: mode.cardColor,
                        child: TextField(
                          style: mode.searchTextStyle,
                          decoration: InputDecoration(
                            hintText: mode.searchHint,
                            hintStyle: mode.searchHintStyle,
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: mode.isDark ? Colors.white54 : Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: mode.cardColor,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 36,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: mode.categoryChips.length,
                      itemBuilder: (context, i) {
                        final chip = mode.categoryChips[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              chip['label']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: _selectedChipIndex == i ? mode.accentColor : mode.textColor,
                              ),
                            ),
                            selected: _selectedChipIndex == i,
                            onSelected: (selected) {
                              setState(() => _selectedChipIndex = selected ? i : -1);
                            },
                            selectedColor: mode.accentColor.withOpacity(0.2),
                            backgroundColor: mode.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: mode.cardColor == Colors.white ? Colors.grey[300]! : Colors.grey[700]!,
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      mode.featuredTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: mode.textColor,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // The grid — wrapped safely
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FeaturedRecipesGrid(
                      title: '', // already shown above
                      recipes: featuredRecipes,
                      crossAxisCount: 2,
                    ),
                  ),
                ),

                // Extra bottom padding so content isn't hidden under bottom nav
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accent,
        unselectedItemColor: mode.textColor.withOpacity(0.6),
        backgroundColor: mode.cardColor,
        showUnselectedLabels: true,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Cookbook'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'You'),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildFoodDrinkToggle(ModeProvider mode) {
    final isFood = mode.isFood;
    final accent = mode.accentColor;
    final inactiveColor = mode.textColor.withOpacity(0.65);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildUnderlineTab(
          label: 'Food',
          isActive: isFood,
          accent: accent,
          inactiveColor: inactiveColor,
          onTap: () {
            if (!isFood) mode.toggleFoodDrink();
          },
        ),
        const SizedBox(width: 24),
        _buildUnderlineTab(
          label: 'Drink',
          isActive: !isFood,
          accent: accent,
          inactiveColor: inactiveColor,
          onTap: () {
            if (isFood) mode.toggleFoodDrink();
          },
        ),
      ],
    );
  }

  Widget _buildUnderlineTab({
    required String label,
    required bool isActive,
    required Color accent,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? accent : inactiveColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 16.5,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isActive ? 3.5 : 0,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}