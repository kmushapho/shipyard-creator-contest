import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/mode_provider.dart';
// import '../widgets/featured_recipes_grid.dart';  // ← removed

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedChipIndex = -1;

  // ── Ingredient selection state ────────────────────────────────────────────
  final List<Map<String, String>> _ingredients = [
    {'name': 'Eggs', 'emoji': '🥚'},
    {'name': 'Milk', 'emoji': '🥛'},
    {'name': 'Flour', 'emoji': '🌾'},
    {'name': 'Butter', 'emoji': '🧈'},
    {'name': 'Sugar', 'emoji': '🍬'},
    {'name': 'Chicken', 'emoji': '🍗'},
    {'name': 'Rice', 'emoji': '🍚'},
    {'name': 'Pasta', 'emoji': '🍝'},
    {'name': 'Cheese', 'emoji': '🧀'},
    {'name': 'Tomato', 'emoji': '🍅'},
    {'name': 'Lemon', 'emoji': '🍋'},
    {'name': 'Coffee', 'emoji': '☕'},
  ];

  final Set<String> _selectedIngredients = {};

  // You can keep _fetchFeaturedRecipes if you want to use it elsewhere later
  Future<List<Map<String, dynamic>>> _fetchFeaturedRecipes(bool isFood) async {
    // ... (your original implementation remains – not used in UI now)
    // This can be removed if you no longer need random recipes on home
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
      throw Exception('Failed to load ${isFood ? "recipes" : "drinks"}');
    }
    final data = json.decode(response.body);
    return (data['recipes'] as List).map((r) => {
      'name': r['title'],
      'imageUrl': r['image'] ?? '',
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);
    final accent = mode.accentColor;

    return Scaffold(
      backgroundColor: mode.bgColor,
      body: SafeArea(
        child: CustomScrollView(
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
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
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

            // Chips (your existing category chips)
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
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Your Pantry section ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Pantry',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mode.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedIngredients.length} ingredients selected',
                      style: TextStyle(fontSize: 14, color: mode.textColor.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedIngredients.map((name) {
                        return Chip(
                          label: Text(name),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => setState(() => _selectedIngredients.remove(name)),
                          backgroundColor: accent.withOpacity(0.15),
                          labelStyle: TextStyle(color: accent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Grid of ingredients
                    Text(
                      'Tap to select your ingredients!',
                      style: TextStyle(fontSize: 16, color: mode.textColor.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _ingredients.length,
                      itemBuilder: (context, index) {
                        final ing = _ingredients[index];
                        final name = ing['name']!;
                        final emoji = ing['emoji']!;
                        final selected = _selectedIngredients.contains(name);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedIngredients.remove(name);
                              } else {
                                _selectedIngredients.add(name);
                              }
                            });
                          },
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: accent.withOpacity(0.25),
                                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                                  ),
                                  if (selected)
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.green,
                                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: mode.textColor),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Custom ingredient button
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: _showCustomIngredientDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Custom'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: BorderSide(color: accent),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Let's Cook / Let's Party button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedIngredients.isNotEmpty
                            ? () {
                          // TODO: navigate to results / recipes screen
                          // You can pass _selectedIngredients
                          print('Selected: $_selectedIngredients');
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          mode.isFood ? "Let's Cook!" : "Let's Party!",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
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

  void _showCustomIngredientDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Ingredient'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Gin, Avocado, Mint...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _selectedIngredients.add(name);
                  // Optional: add to grid with generic emoji
                  _ingredients.add({'name': name, 'emoji': '🛒'});
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}