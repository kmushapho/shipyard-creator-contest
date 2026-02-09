import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/mode_provider.dart';

// We'll move the ingredient grid into its own widget
class IngredientSelector extends StatefulWidget {
  final bool isFood;
  final Color accentColor;

  const IngredientSelector({
    super.key,
    required this.isFood,
    required this.accentColor,
  });

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<IngredientSelector> {
  final List<Map<String, String>> _foodIngredients = [
    {'name': 'Eggs', 'emoji': '🥚'},
    {'name': 'Milk', 'emoji': '🥛'},
    {'name': 'Flour', 'emoji': '🌾'},
    {'name': 'Butter', 'emoji': '🧈'},
    {'name': 'Sugar', 'emoji': '🍬'},
    {'name': 'Chicken', 'emoji': '🍗'},
    {'name': 'Rice', 'emoji': '🍚'},
    {'name': 'Pasta', 'emoji': '🍝'},
    {'name': 'Cheese', 'emoji': '🧀'},
  ];

  final List<Map<String, String>> _drinkIngredients = [
    {'name': 'Coffee', 'emoji': '☕'},
    {'name': 'Tea', 'emoji': '🍵'},
    {'name': 'Juice', 'emoji': '🧃'},
    {'name': 'Milk', 'emoji': '🥛'},
    {'name': 'Lemonade', 'emoji': '🍋'},
    {'name': 'Cocktail', 'emoji': '🍸'},
    {'name': 'Beer', 'emoji': '🍺'},
    {'name': 'Wine', 'emoji': '🍷'},
    {'name': 'Tropical', 'emoji': '🍹'},
    {'name': 'Bubble Tea', 'emoji': '🧋'},
  ];

  Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.isFood ? _foodIngredients : _drinkIngredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Your Pantry',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: widget.accentColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${selected.length} selected',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 12),

        // Selected pills
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selected.map((name) {
              return Chip(
                label: Text(name),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => setState(() => selected.remove(name)),
                backgroundColor: widget.accentColor.withOpacity(0.15),
                labelStyle: TextStyle(color: widget.accentColor),
                shape: StadiumBorder(side: BorderSide(color: widget.accentColor)),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: ingredients.length,
            itemBuilder: (context, i) {
              final ing = ingredients[i];
              final name = ing['name']!;
              final emoji = ing['emoji']!;
              final isSel = selected.contains(name);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSel) {
                      selected.remove(name);
                    } else {
                      selected.add(name);
                    }
                  });
                },
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: widget.accentColor.withOpacity(0.15),
                          child: Text(emoji, style: const TextStyle(fontSize: 32)),
                        ),
                        if (isSel)
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.green,
                            child: const Icon(Icons.check, size: 16, color: Colors.white),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // Custom + button
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: show dialog to add custom ingredient
            },
            icon: const Icon(Icons.add),
            label: const Text('Custom'),
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.accentColor,
              side: BorderSide(color: widget.accentColor),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Big action button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected.isNotEmpty
                  ? () {
                // TODO: navigate to recipes/drinks list
                print('Selected: $selected');
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                widget.isFood ? "Let's Cook!" : "Let's Party!",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedChipIndex = 0; // default: Search by Pantry selected

  // We use a key to force rebuild / "mini reload" when mode changes
  Key _gridKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);
    final accent = mode.accentColor;

    // Listen to mode changes → trigger mini reload
    void onModeChanged() {
      setState(() {
        _gridKey = UniqueKey(); // forces rebuild of the ingredient selector
        _selectedChipIndex = 0; // reset to "Search by Pantry"
      });
    }

    // Optional: you can listen in didChangeDependencies or use didUpdateWidget

    return Scaffold(
      backgroundColor: mode.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with theme toggle + Food/Drink switch
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
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
                    _buildFoodDrinkToggle(mode, onModeChanged),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Search bar (kept from original)
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
                        prefixIcon: Icon(Icons.search_rounded, color: accent.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: mode.cardColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Horizontal chips — "Search by Pantry" always selected in current mode
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: mode.categoryChips.length,
                  itemBuilder: (context, i) {
                    final chip = mode.categoryChips[i];
                    final isSelected = i == _selectedChipIndex;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(
                          chip['label']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : mode.textColor,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (sel) {
                          setState(() => _selectedChipIndex = sel ? i : 0);
                        },
                        selectedColor: accent,
                        backgroundColor: mode.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: accent.withOpacity(0.5)),
                        ),
                        elevation: isSelected ? 2 : 0,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Main content — ingredient selector with key for reload animation
            SliverToBoxAdapter(
              key: _gridKey, // this causes rebuild when mode changes
              child: IngredientSelector(
                isFood: mode.isFood,
                accentColor: accent,
              ),
            ),
          ],
        ),
      ),
      // Bottom nav kept as is
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

  Widget _buildFoodDrinkToggle(ModeProvider mode, VoidCallback onSwitch) {
    final isFood = mode.isFood;
    final accent = mode.accentColor;
    final inactive = mode.textColor.withOpacity(0.6);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTab('Food', isFood, accent, inactive, () {
          if (!isFood) {
            mode.toggleFoodDrink();
            onSwitch();
          }
        }),
        const SizedBox(width: 32),
        _buildTab('Drink', !isFood, accent, inactive, () {
          if (isFood) {
            mode.toggleFoodDrink();
            onSwitch();
          }
        }),
      ],
    );
  }

  Widget _buildTab(String label, bool active, Color accent, Color inactive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          fontSize: 18,
          fontWeight: active ? FontWeight.bold : FontWeight.w600,
          color: active ? accent : inactive,
        ),
        child: Text(label),
      ),
    );
  }
}