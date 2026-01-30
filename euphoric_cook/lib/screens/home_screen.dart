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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mode toggle (top-right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,       // remove default padding
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

                  const SizedBox(height: 1), // spacing between mode and Food/Drink toggle

                  // Food/Drink toggle
                  _buildFoodDrinkToggle(mode),

                  const SizedBox(height: 10), // spacing before search bar
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
                    style: TextStyle(fontSize: 14, color: mode.textColor),
                    decoration: InputDecoration(
                      hintText: mode.searchHint,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: mode.textColor.withOpacity(0.6),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.search_rounded, color: accent, size: 20),
                      ),
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
                        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                  ),
                ),

              ),
            ),


            const SizedBox(height: 12),

            // Horizontal chips
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
                              ? Colors.orange.shade700
                              : Colors.grey[800],
                        ),
                      ),
                      selected: _selectedChipIndex == i,
                      onSelected: (selected) {
                        setState(() {
                          _selectedChipIndex = selected ? i : -1;
                        });
                      },
                      selectedColor: Colors.orange.withOpacity(0.2),
                      backgroundColor: Colors.grey[50], // off-white fill
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

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