import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';
import 'pantry_selector.dart'; // ← Import the new widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedChipIndex = 0;
  Key _contentKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);
    final accent = mode.accentColor;

    return Scaffold(
      backgroundColor: mode.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header: theme + mode toggle
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // for balance
                    _buildFoodDrinkToggle(mode),
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
                        prefixIcon: Icon(Icons.search_rounded, color: accent.withOpacity(0.7)),
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
                      child: ChoiceChip(
                        label: Text(chip['label']!),
                        selected: isSelected,
                        onSelected: (sel) {
                          setState(() => _selectedChipIndex = sel ? i : 0);
                        },
                        selectedColor: accent,
                        backgroundColor: mode.cardColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : mode.textColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Pantry selector (main content)
            SliverToBoxAdapter(
              key: _contentKey,
              child: PantrySelector(
                isFood: mode.isFood,
                accentColor: accent,
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
    final inactive = mode.textColor.withOpacity(0.65);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (!isFood) {
              mode.toggleFoodDrink();
              setState(() => _contentKey = UniqueKey());
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isFood ? accent.withOpacity(0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Food',
              style: TextStyle(
                color: isFood ? accent : inactive,
                fontWeight: isFood ? FontWeight.bold : FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            if (isFood) {
              mode.toggleFoodDrink();
              setState(() => _contentKey = UniqueKey());
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: !isFood ? accent.withOpacity(0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Drink',
              style: TextStyle(
                color: !isFood ? accent : inactive,
                fontWeight: !isFood ? FontWeight.bold : FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }
}