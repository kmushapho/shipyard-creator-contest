import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';
import '../widgets/featured_recipes_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);
    final accent = mode.accentColor;
    int _selectedChipIndex = -1;

    // Dummy data for featured grid (changes based on food/drink mode)
    final featuredRecipes = List.generate(6, (index) {
      if (mode.isFood) {
        return {
          'name': 'Creamy Avocado Toast ${index + 1}',
          'imageUrl': null as String?,
          'servings': 2 + index % 3,
          'totalTimeMinutes': 10 + index * 5,
        };
      } else {
        final alcoholTypes = ['alcoholic', 'non-alcoholic', 'optional'];
        return {
          'name': 'Refreshing Mojito ${index + 1}',
          'imageUrl': null as String?,
          'alcoholType': alcoholTypes[index % 3],
        };
      }
    });

    return Scaffold(
      backgroundColor: mode.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top header: theme toggle + food/drink switch ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Theme toggle (sun/moon icon, top-right)
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
                  const SizedBox(height: 1), // small gap between theme icon and toggle

                  // Food / Drink mode switch
                  _buildFoodDrinkToggle(mode),

                  const SizedBox(height: 10), // gap before search field
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Material(
                  key: ValueKey(mode.currentMode),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.08), // soft shadow
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
                      fillColor: mode.cardColor, // dark gray in dark mode
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

            const SizedBox(height: 12),

            // Horizontal category chips
            SizedBox(
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
                          color: _selectedChipIndex == i
                              ? mode.accentColor // selected text = accent
                              : mode.textColor,  // default = same as search text
                        ),
                      ),
                      selected: _selectedChipIndex == i,
                      onSelected: (selected) {
                        setState(() {
                          _selectedChipIndex = selected ? i : -1;
                        });
                      },
                      selectedColor: mode.accentColor.withOpacity(0.2), // light orange highlight
                      backgroundColor: mode.cardColor, // same as search bar
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: mode.cardColor == Colors.white
                              ? Colors.grey[300]! // light mode border
                              : Colors.grey[700]!, // dark mode border
                          width: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Featured recipes grid (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FeaturedRecipesGrid(
                  title: mode.featuredTitle,
                  recipes: featuredRecipes,
                  crossAxisCount: 2,
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accent,
        unselectedItemColor: mode.textColor.withOpacity(0.6),
        backgroundColor: mode.cardColor,
        showUnselectedLabels: true,
        iconSize: 22,
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
        const SizedBox(width: 24), // gap between Food and Drink labels
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