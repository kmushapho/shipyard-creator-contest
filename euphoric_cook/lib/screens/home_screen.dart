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
  bool _isFoodMode = true;

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);
    final accent = mode.accentColor;
    final textColor = mode.textColor;

    final foodColor = AppColors.vibrantOrange;
    final drinkColor = const Color(0xFF4A90E2);

    final currentAccent = _isFoodMode ? foodColor : drinkColor;

    return Scaffold(
      backgroundColor: mode.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left spacer (or logo later)
                      const SizedBox(width: 48),

                      // Center: Food / Drink Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: mode.cardColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildModeButton(
                              label: 'Food',
                              isActive: _isFoodMode,
                              color: currentAccent,
                              onTap: () => setState(() => _isFoodMode = true),
                            ),
                            _buildModeButton(
                              label: 'Drink',
                              isActive: !_isFoodMode,
                              color: currentAccent,
                              onTap: () => setState(() => _isFoodMode = false),
                            ),
                          ],
                        ),
                      ),

                      // Top-right: Day/Night toggle
                      IconButton(
                        icon: Icon(
                          mode.isDark ? Icons.wb_sunny : Icons.nights_stay,
                          color: currentAccent,
                          size: 28,
                        ),
                        onPressed: mode.toggleTheme,
                        tooltip: mode.isDark ? 'Day Mode' : 'Night Mode',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search bar (mode-aware placeholder)
                  TextField(
                    decoration: InputDecoration(
                      hintText: _isFoodMode
                          ? 'Search food recipes by name'
                          : 'Search drink recipes by name',
                      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search, color: currentAccent),
                      filled: true,
                      fillColor: mode.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ],
              ),
            ),

            // Rest of your content (horizontal chips, featured recipes, etc.)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    _isFoodMode ? 'Featured Recipes' : 'Featured Drinks',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Your horizontal category chips here...
                  // Featured grid...
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: currentAccent,
        unselectedItemColor: textColor.withOpacity(0.6),
        backgroundColor: mode.cardColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Cookbook'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}