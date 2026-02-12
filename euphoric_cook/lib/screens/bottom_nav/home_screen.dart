import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mode_provider.dart';
import '../horizontal_menu/pantry_selector.dart';
import '../horizontal_menu/all_day_meals.dart';
import '../bottom_nav/cookbook_screen.dart';
import '../bottom_nav/meal_plan_screen.dart';
import '../bottom_nav/shop_screen.dart';
import '../bottom_nav/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _selectedChipIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);
    final accent = mode.accentColor;

    return Scaffold(
      backgroundColor: mode.bgColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            /// ───────── HOME TAB ─────────
            KeyedSubtree(
              key: const ValueKey('home'),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              mode.isDark
                                  ? Icons.wb_sunny_rounded
                                  : Icons.nights_stay_rounded,
                              color: accent,
                            ),
                            onPressed: mode.toggleTheme,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: _buildFoodDrinkToggle(mode),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Material(
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
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  /// ─── CHIPS ───
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
                                  color: isSelected
                                      ? Colors.white
                                      : mode.textColor,
                                ),
                              ),
                              onSelected: (_) {
                                setState(() => _selectedChipIndex = i);
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

                  /// ─── CONTENT ───
                  _buildSelectedChipContent(mode, accent),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
            const CookbookScreen(key: ValueKey('cookbook')),
            const MealPlannerPage(key: ValueKey('plan')),
            const ShopScreen(key: ValueKey('shop')),
            const ProfileScreen(key: ValueKey('profile')),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accent,
        unselectedItemColor: mode.textColor.withOpacity(0.6),
        backgroundColor: mode.cardColor,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
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

  Widget _buildFoodDrinkToggle(ModeProvider mode) {
    final isFood = mode.isFood;
    final activeColor = Colors.orangeAccent.shade700;
    final inactiveColor = mode.textColor.withOpacity(0.65);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _toggleItem(
          'Food',
          isFood,
              () {
            mode.setFoodMode();
            setState(() => _selectedChipIndex = 0);
          },
          activeColor,
          inactiveColor,
        ),
        const SizedBox(width: 48),
        _toggleItem(
          'Drinks',
          !isFood,
              () {
            mode.setDrinkMode();
            setState(() => _selectedChipIndex = 0);
          },
          activeColor,
          inactiveColor,
        ),
      ],
    );
  }

  Widget _toggleItem(
      String text,
      bool active,
      VoidCallback onTap,
      Color activeColor,
      Color inactiveColor,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: active ? activeColor : inactiveColor,
              fontSize: 18,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            width: 60,
            height: active ? 3.2 : 0,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChipContent(ModeProvider mode, Color accent) {
    final label = mode.categoryChips[_selectedChipIndex]['label']!;
    switch (label) {
      case 'Search By Pantry':
        return SliverToBoxAdapter(
          child: PantrySelector(
            isFood: mode.isFood,
            accentColor: accent,
          ),
        );
      case 'All Day Meals':
        return const SliverToBoxAdapter(
          child: AllDayMealsMenu(),
        );
      default:
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Coming soon: $label',
                style: TextStyle(
                  fontSize: 18,
                  color: mode.textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }
  }
}