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

    final featuredRecipes = List.generate(
      6,
          (index) {
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
      },
    );

    return Scaffold(
      backgroundColor: mode.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header with theme + mode toggle ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Theme toggle row (aligned right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          mode.isDark ? Icons.wb_sunny_rounded : Icons
                              .nights_stay_rounded,
                          color: accent,
                          size: 28,
                        ),
                        onPressed: mode.toggleTheme,
                        tooltip: mode.isDark ? 'Day mode' : 'Night mode',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14), // ← tweak this value (4–16)

                  // 3. Food/Drink toggle (centered)
                  _buildFoodDrinkToggle(mode),

                  // Optional: tiny space before search bar
                  const SizedBox(height: 16),
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
                  shadowColor: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  color: mode.cardColor,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: mode.searchHint,
                      hintStyle: TextStyle(
                          color: mode.textColor.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search_rounded, color: accent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: accent.withOpacity(0.4),
                          width: 1.2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: accent.withOpacity(0.35),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: accent,
                          width: 1.8,
                        ),
                      ),
                      filled: true,
                      fillColor: mode.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Horizontal chips
            SizedBox(
              height: 44, // slightly reduced for tighter feel
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: mode.categoryChips.length,
                itemBuilder: (context, i) {
                  final chip = mode.categoryChips[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Chip(
                      label: Text(chip['label']!),
                      backgroundColor: mode.cardColor,
                      side: BorderSide(color: accent.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Scrollable featured section
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

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accent,
        unselectedItemColor: mode.textColor.withOpacity(0.6),
        backgroundColor: mode.cardColor,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded), label: 'Cookbook'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded), label: 'Plan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded), label: 'Shop'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'You'),
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
        const SizedBox(width: 24), // space between Food and Drink
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
      child: IntrinsicWidth( // ← this is the magic
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // makes underline stretch to text
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}