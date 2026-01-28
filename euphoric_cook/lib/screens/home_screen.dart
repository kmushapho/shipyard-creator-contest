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
            // no alcoholType needed for food
          };
        } else {
          // Drink mode – add alcoholType
          final alcoholTypes = ['alcoholic', 'non-alcoholic', 'optional'];
          return {
            'name': 'Refreshing Mojito ${index + 1}',
            'imageUrl': null as String?,
            'alcoholType': alcoholTypes[index % 3], // cycles through the 3 options
            // servings & totalTimeMinutes can stay if you want fallback, but we won't use them
          };
        }
      },
    );

    return Scaffold(
      backgroundColor: mode.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // makes children take full width
                children: [
                  // Row just for the theme toggle aligned to the right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // pushes icon to right
                    children: [
                      IconButton(
                        icon: Icon(
                          mode.isDark ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                          color: accent,
                          size: 28,
                        ),
                        onPressed: mode.toggleTheme,
                        tooltip: mode.isDark ? 'Day mode' : 'Night mode',
                      ),
                    ],
                  ),

                  const SizedBox(height: 5), // small vertical space

                  // Centered Food ↔ Drink toggle (takes center automatically)
                  Center(
                    child: _buildFoodDrinkToggle(mode),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8), // small vertical space

            // ── Search bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Material(
                  key: ValueKey(mode.currentMode), // keep the key for smooth switch
                  elevation: 2,                     // subtle shadow (1–3 is gentle; 4+ feels heavier)
                  shadowColor: Colors.black.withOpacity(0.12), // soft, not dark
                  borderRadius: BorderRadius.circular(30),
                  color: mode.cardColor,            // your existing fill color
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: mode.searchHint,
                      hintStyle: TextStyle(color: mode.textColor.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search_rounded, color: accent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: accent.withOpacity(0.4), // semi-visible, subtle accent tint
                          width: 1.2,                     // thin but noticeable
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
                          color: accent,                  // full accent when focused
                          width: 1.8,                     // slightly thicker on focus for feedback
                        ),
                      ),
                      filled: true,
                      fillColor: mode.cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),

            // ── Horizontal category chips ──────────────────────────────
            SizedBox(
              height: 48,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 16),

            // ── Featured content ───────────────────────────────────────
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

      // ── Fixed bottom navigation ────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accent,
        unselectedItemColor: mode.textColor.withOpacity(0.6),
        backgroundColor: mode.cardColor,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Cookbook'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'You'),
        ],
        currentIndex: 0,
        onTap: (index) {}, // add navigation later
      ),
    );
  }

  // ── Helper: Food / Drink centered toggle ───────────────────────
  Widget _buildFoodDrinkToggle(ModeProvider mode) {
    final isFood = mode.currentMode == AppMode.food;
    final accent = mode.accentColor;

    return Container(
      decoration: BoxDecoration(
        color: mode.cardColor,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModePill(
            label: 'Food',
            isActive: isFood,
            accent: accent,
            onTap: () {
              if (!isFood) mode.toggleFoodDrink();
            },
          ),
          _buildModePill(
            label: 'Drink',
            isActive: !isFood,
            accent: accent,
            onTap: () {
              if (isFood) mode.toggleFoodDrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required String label,
    required bool isActive,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : accent,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}