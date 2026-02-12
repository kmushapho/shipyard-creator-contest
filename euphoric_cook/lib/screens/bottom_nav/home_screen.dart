import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mode_provider.dart';
import '../horizontal_menu/pantry_selector.dart';
import '../horizontal_menu/all_day_meals.dart';
import '../bottom_nav/cookbook_screen.dart';
import '../bottom_nav/meal_plan_screen.dart';
import '../bottom_nav/shop_screen.dart';
import '../bottom_nav/profile_screen.dart';
import '../../providers/user_provider.dart';

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
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildFoodDrinkToggle(mode),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
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
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                /// CHIPS
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

                /// CONTENT BASED ON CHIP
                _buildSelectedChipContent(mode, accent),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),

            // OTHER TABS
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
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Cookbook'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'You'),
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
        _toggleItem('Food', isFood, () {
          mode.setFoodMode();
          setState(() => _selectedChipIndex = 0);
        }, activeColor, inactiveColor),
        const SizedBox(width: 48),
        _toggleItem('Drinks', !isFood, () {
          mode.setDrinkMode();
          setState(() => _selectedChipIndex = 0);
        }, activeColor, inactiveColor),
      ],
    );
  }

  Widget _toggleItem(
      String text, bool active, VoidCallback onTap, Color activeColor, Color inactiveColor) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          child: PantrySelector(isFood: mode.isFood, accentColor: accent),
        );
      case 'All Day Meals':
        return const SliverToBoxAdapter(child: AllDayMealsMenu());
      case 'Cuisines by region':
        return const SliverToBoxAdapter(child: CountriesContent());
      case 'Recently viewed':
        final userProvider = Provider.of<UserProvider>(context);
        final items = userProvider.getRecentlyViewed(isFood: mode.isFood); // if you have isFood
        return SliverToBoxAdapter(
          child: items.isEmpty || items.first == 'No recently viewed items'
              ? Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'No recently viewed items yet.',
              style: TextStyle(
                fontSize: 18,
                color: userProvider.isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          )
              : SizedBox(
            height: 200, // fixed height to avoid overflow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Chip(
                  label: Text(items[i]),
                ),
              ),
            ),
          ),
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

/// ───────────────────── CountriesContent ─────────────────────
class CountriesContent extends StatelessWidget {
  const CountriesContent({super.key});

  static final List<Map<String, String>> _countries = [
    {'name': 'Algerian', 'flag': '🇩🇿'},
    {'name': 'American', 'flag': '🇺🇸'},
    {'name': 'Argentinian', 'flag': '🇦🇷'},
    {'name': 'Australian', 'flag': '🇦🇺'},
    {'name': 'British', 'flag': '🇬🇧'},
    {'name': 'Canadian', 'flag': '🇨🇦'},
    {'name': 'Chinese', 'flag': '🇨🇳'},
    {'name': 'Croatian', 'flag': '🇭🇷'},
    {'name': 'Dutch', 'flag': '🇳🇱'},
    {'name': 'Egyptian', 'flag': '🇪🇬'},
    {'name': 'Filipino', 'flag': '🇵🇭'},
    {'name': 'French', 'flag': '🇫🇷'},
    {'name': 'Greek', 'flag': '🇬🇷'},
    {'name': 'Indian', 'flag': '🇮🇳'},
    {'name': 'Irish', 'flag': '🇮🇪'},
    {'name': 'Italian', 'flag': '🇮🇹'},
    {'name': 'Jamaican', 'flag': '🇯🇲'},
    {'name': 'Japanese', 'flag': '🇯🇵'},
    {'name': 'Kenyan', 'flag': '🇰🇪'},
    {'name': 'Malaysian', 'flag': '🇲🇾'},
    {'name': 'Mexican', 'flag': '🇲🇽'},
    {'name': 'Moroccan', 'flag': '🇲🇦'},
    {'name': 'Norwegian', 'flag': '🇳🇴'},
    {'name': 'Polish', 'flag': '🇵🇱'},
    {'name': 'Portuguese', 'flag': '🇵🇹'},
    {'name': 'Russian', 'flag': '🇷🇺'},
    {'name': 'Saudi Arabian', 'flag': '🇸🇦'},
    {'name': 'Slovakian', 'flag': '🇸🇰'},
    {'name': 'South African', 'flag': '🇿🇦'},
    {'name': 'Spanish', 'flag': '🇪🇸'},
    {'name': 'Syrian', 'flag': '🇸🇾'},
    {'name': 'Thai', 'flag': '🇹🇭'},
    {'name': 'Tunisian', 'flag': '🇹🇳'},
    {'name': 'Turkish', 'flag': '🇹🇷'},
    {'name': 'Ukrainian', 'flag': '🇺🇦'},
    {'name': 'Venezuelan', 'flag': '🇻🇪'},
  ];

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: _countries.length,
      itemBuilder: (context, index) {
        final country = _countries[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(country['flag']!, style: const TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                country['name']!,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  color: mode.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
