import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/colors.dart'; // your colors file

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
    _tabController.addListener(() {
      setState(() {}); // rebuild to update FAB visibility/behavior
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleFabPress() {
    final index = _tabController.index;
    if (index == 0) return; // no action in Favorites

    String message;
    switch (index) {
      case 1:
        message = "Create new recipe";
        // Navigator.push(context, MaterialPageRoute(builder: (_) => NewRecipeScreen()));
        break;
      case 2:
        message = "Create new collection";
        // Navigator.push(context, MaterialPageRoute(builder: (_) => NewCollectionScreen()));
        break;
      default:
        message = "Action";
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool get _showFab => _tabController.index != 0;

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
                // 1. Favorites – category tiles
                _buildFavoritesTab(isDark),

                // 2. My Recipes – empty for now (as in original)
                _buildEmptyState(
                  icon: Icons.book_outlined,
                  title: "No custom recipes yet",
                  subtitle: "Create your first recipe with the + button below",
                  iconSize: 100,
                ),

                // 3. Collections
                _buildCollectionsTab(isDark),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
        onPressed: _handleFabPress,
        backgroundColor: AppColors.vibrantOrange,
        foregroundColor: AppColors.lightText,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFavoritesTab(bool isDark) {
    final categories = [
      _CategoryTile(
        title: "Food Favorites",
        subtitle: "Hearted food recipes",
        icon: Icons.restaurant_rounded,
        emptyMessage:
        "No food favs yet.\nGo to any food recipe and tap the heart to add.",
      ),
      _CategoryTile(
        title: "Drink Favorites",
        subtitle: "Hearted drink recipes",
        icon: Icons.local_drink_rounded,
        emptyMessage:
        "No drink favs yet.\nGo to any drink recipe and tap the heart to add.",
      ),
      _CategoryTile(
        title: "Food & Drink Fav",
        subtitle: "All your favorite recipes",
        icon: Icons.favorite_rounded,
        emptyMessage:
        "No food or drink favs yet.\nGo to any recipe and tap the heart to add.",
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return categories[index];
      },
    );
  }

  Widget _buildCollectionsTab(bool isDark) {
    // For now we show empty state + create button
    // Later replace with real ListView.builder when you have collection data
    final hasCollections = false; // ← replace with real logic

    if (hasCollections) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 0, // placeholder
        itemBuilder: (context, index) => const ListTile(
          title: Text("Collection name"),
          subtitle: Text("Created • 12 Feb 2026", textAlign: TextAlign.end),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.collections_bookmark_outlined,
            size: 90,
            color: isDark ? Colors.white24 : Colors.black26,
          )
              .animate()
              .fadeIn(duration: 800.ms)
              .scale(curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          Text(
            "No collections yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Group your favorite recipes into custom cookbooks",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () => _handleFabPress(), // or direct navigation
            icon: const Icon(Icons.add_rounded),
            label: const Text("Create Collection"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.vibrantOrange,
              side: BorderSide(color: AppColors.vibrantOrange),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
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

// ── Helper widget for Favorites categories ──────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String emptyMessage;

  const _CategoryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // In real app: check if this category actually has items
    final isEmpty = true; // ← replace with real data check

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _FavoriteDetailScreen(
                categoryTitle: title,
                emptyMessage: emptyMessage,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: AppColors.vibrantOrange,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white54 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Example detail screen for each favorite category
class _FavoriteDetailScreen extends StatelessWidget {
  final String categoryTitle;
  final String emptyMessage;

  const _FavoriteDetailScreen({
    required this.categoryTitle,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // In real app → load actual favorites here
    final hasItems = false;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        foregroundColor: isDark ? AppColors.lightText : AppColors.darkText,
      ),
      body: hasItems
          ? const Center(child: Text("List of favorites goes here…"))
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 80,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              const SizedBox(height: 24),
              Text(
                "It's empty here",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}