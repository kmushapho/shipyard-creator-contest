import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';
import '../constants/colors.dart';

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

                  const SizedBox(height: 8), // small vertical space

                  // Centered Food ↔ Drink toggle (takes center automatically)
                  Center(
                    child: _buildFoodDrinkToggle(mode),
                  ),
                ],
              ),
            ),

            // ── Search bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: TextField(
                  key: ValueKey(mode.currentMode),
                  decoration: InputDecoration(
                    hintText: mode.searchHint,
                    hintStyle: TextStyle(color: mode.textColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search_rounded, color: accent),
                    filled: true,
                    fillColor: mode.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

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

            // ── Featured title + grid ──────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      mode.featuredTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mode.textColor,
                      ),
                    ),
                  ),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: mode.isDark ? 2 : 1,
                        color: mode.cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.08),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image_rounded, size: 60, color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recipe ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: mode.textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '12 min • 2 servings',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: mode.textColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 100), // space for bottom nav
                ],
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