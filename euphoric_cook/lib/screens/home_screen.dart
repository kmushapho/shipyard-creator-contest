import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';
import 'pantry_selector.dart';
import 'cookbook_screen.dart';
import 'meal_plan_screen.dart';
import 'shop_screen.dart';
import 'profile_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // ← Tracks which tab is active (starts at Home)

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);
    final accent = mode.accentColor; // This is your vibrant orange, I assume

    return Scaffold(
      backgroundColor: mode.bgColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Screen 0: Home (your original scrollable content)
            CustomScrollView(
              slivers: [
                // Theme toggle row (top right)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
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
                  ),
                ),

                // Food / Drink underline toggle – centered
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: _buildFoodDrinkToggle(mode),
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
                        elevation: 1.5,
                        borderRadius: BorderRadius.circular(30),
                        color: mode.cardColor,
                        child: TextField(
                          style: mode.searchTextStyle,
                          decoration: InputDecoration(
                            hintText: mode.searchHint,
                            hintStyle: mode.searchHintStyle,
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: accent.withOpacity(0.7),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Horizontal chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: mode.categoryChips.length,
                      itemBuilder: (context, i) {
                        final chip = mode.categoryChips[i];
                        final isSelected = i == _selectedChipIndex;

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: RawChip(
                            label: Text(
                              chip['label']!,
                              style: TextStyle(
                                color: isSelected ? Colors.white : mode.textColor,
                              ),
                            ),
                            onSelected: (sel) {
                              setState(() => _selectedChipIndex = sel ? i : 0);
                            },
                            selected: isSelected,
                            selectedColor: accent,
                            backgroundColor: mode.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Main content
                SliverToBoxAdapter(
                  key: _contentKey,
                  child: PantrySelector(
                    isFood: mode.isFood,
                    accentColor: accent,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),

            // Screen 1: Cookbook
            const CookbookScreen(),

            // Screen 2: Plan (placeholder – replace later)
            const MealPlannerPage(),

            // Screen 3: Shop (placeholder)
            const ShopScreen(),

            // Screen 4: You (placeholder)
            const ProfileScreen()
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accent, // ← This makes selected icon + label use vibrant orange
        unselectedItemColor: mode.textColor.withOpacity(0.6),
        backgroundColor: mode.cardColor,
        showUnselectedLabels: true,
        currentIndex: _currentIndex, // ← Now dynamic!
        onTap: (index) {
          setState(() {
            _currentIndex = index; // ← This updates the highlight
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_rounded),
            label: 'Cookbook',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_rounded),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'You',
          ),
        ],
      ),
    );
  }

  // You still need this method (moved it outside build for cleanliness)
  int _selectedChipIndex = 0; // ← You had this but it was local to build – moved up
  Key _contentKey = UniqueKey();

  Widget _buildFoodDrinkToggle(ModeProvider mode) {
    final isFood = mode.isFood;
    final foodColor = Colors.orangeAccent.shade700;
    final drinkColor = Colors.blueAccent.shade700;
    final inactiveColor = mode.textColor.withOpacity(0.65);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (!isFood) {
              mode.toggleFoodDrink();
              setState(() => _contentKey = UniqueKey());
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Food',
                style: TextStyle(
                  color: isFood ? foodColor : inactiveColor,
                  fontSize: 18,
                  fontWeight: isFood ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 60,
                height: isFood ? 3.2 : 0,
                decoration: BoxDecoration(
                  color: foodColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
        GestureDetector(
          onTap: () {
            if (isFood) {
              mode.toggleFoodDrink();
              setState(() => _contentKey = UniqueKey());
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Drinks',
                style: TextStyle(
                  color: !isFood ? drinkColor : inactiveColor,
                  fontSize: 18,
                  fontWeight: !isFood ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 60,
                height: !isFood ? 3.2 : 0,
                decoration: BoxDecoration(
                  color: drinkColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}