import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // optional – for gentle animations

import '../../../constants/colors.dart'; // ← your colors file

class CookbookScreen extends StatefulWidget {
  const CookbookScreen({super.key});

  @override
  State<CookbookScreen> createState() => _CookbookScreenState();
}

class _CookbookScreenState extends State<CookbookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleFabPress() {
    final index = _tabController.index;

    String message;
    switch (index) {
      case 0:
        message = "Discover / add favorites";
        break;
      case 1:
        message = "Create new recipe";
        // Navigator.push(context, MaterialPageRoute(builder: (_) => NewRecipeScreen()));
        break;
      case 2:
        message = "Create new collection";
        break;
      default:
        message = "Action";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,

      appBar: AppBar(
        title: const Text("My Cookbook"),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        foregroundColor: isDark ? AppColors.lightText : AppColors.darkText,
        elevation: 0,
      ),

      body: Column(
        children: [
          // Tabs (Material 3 style – no underline by default, we use indicator)
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.vibrantOrange,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
            indicatorColor: AppColors.vibrantOrange,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "Favorites"),
              Tab(text: "My Recipes"),
              Tab(text: "Collections"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Favorites – empty state
                _buildEmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: "No favorites yet",
                  subtitle: "Heart recipes you love to find them here quickly",
                ),

                _buildEmptyState(
                  icon: Icons.book_outlined,
                  title: "No custom recipes yet",
                  subtitle: "Create your first recipe with the + button below",
                  iconSize: 100,
                ),

                // Collections
                _buildEmptyState(
                  icon: Icons.collections_bookmark_outlined,
                  title: "No collections yet",
                  subtitle: "Group your favorite recipes into custom cookbooks",
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _handleFabPress,
        backgroundColor: AppColors.vibrantOrange,
        foregroundColor: AppColors.lightText,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    double iconSize = 90,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: isDark ? Colors.white24 : Colors.black26,
          )
              .animate()
              .fadeIn(duration: 800.ms)
              .scale(curve: Curves.easeOutBack),

          const SizedBox(height: 32),

          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}