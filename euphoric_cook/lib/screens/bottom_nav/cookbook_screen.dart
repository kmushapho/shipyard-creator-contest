import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart'; // adjust path if needed

class CookbookScreen extends StatefulWidget {
  const CookbookScreen({super.key});

  @override
  State<CookbookScreen> createState() => _CookbookScreenState();
}

class _CookbookScreenState extends State<CookbookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Collection> _collections = []; // starts empty

  final Set<int> _selectedIndices = {};
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _showFab => _tabController.index != 0;

  void _createCollection() async {
    final nameCtrl = TextEditingController();

    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Collection"),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "e.g. Weekend BBQs",
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) Navigator.pop(context, name);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty && mounted) {
      setState(() {
        _collections.add(
          Collection(
            name: newName.trim(),
            createdAt: DateTime.now(),
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created "$newName"')),
      );
    }
  }

  void _deleteSelected() {
    if (_selectedIndices.isEmpty) return;

    final count = _selectedIndices.length; // ← capture count BEFORE changing state

    setState(() {
      final indices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (final i in indices) {
        _collections.removeAt(i);
      }
      _selectedIndices.clear();
      _isSelecting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted $count collection${count == 1 ? "" : "s"}')),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      _isSelecting = _selectedIndices.isNotEmpty;
    });
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
        actions: _isSelecting
            ? [
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            tooltip: "Delete selected",
            onPressed: _selectedIndices.isNotEmpty ? _deleteSelected : null,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedIndices.clear();
                _isSelecting = false;
              });
            },
          ),
        ]
            : null,
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
                _buildFavoritesTab(isDark),
                _buildEmptyState(
                  icon: Icons.book_outlined,
                  title: "No custom recipes yet",
                  subtitle: "Create your first recipe with the + button below",
                  iconSize: 100,
                ),
                _buildCollectionsTab(isDark),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
        onPressed: _createCollection,
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
        emptyMessage: "No food favs yet.\nGo to any food recipe and tap the heart to add.",
      ),
      _CategoryTile(
        title: "Drink Favorites",
        subtitle: "Hearted drink recipes",
        icon: Icons.local_drink_rounded,
        emptyMessage: "No drink favs yet.\nGo to any drink recipe and tap the heart to add.",
      ),
      _CategoryTile(
        title: "Food & Drink Fav",
        subtitle: "All your favorite recipes",
        icon: Icons.favorite_rounded,
        emptyMessage: "No food or drink favs yet.\nGo to any recipe and tap the heart to add.",
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => categories[index],
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
          Icon(icon, size: iconSize, color: isDark ? Colors.white24 : Colors.black26)
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
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsTab(bool isDark) {
    if (_collections.isEmpty) {
      return _buildEmptyCollections(isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _collections.length,
      itemBuilder: (context, index) {
        final collection = _collections[index];
        final isSelected = _selectedIndices.contains(index);
        final dateStr = DateFormat("d MMM yyyy • HH:mm").format(collection.createdAt);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: ListTile(
            selected: isSelected,
            selectedTileColor: AppColors.vibrantOrange.withOpacity(0.15),
            onTap: _isSelecting
                ? () => _toggleSelection(index)
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CollectionDetailScreen(collection: collection),
                ),
              );
            },
            onLongPress: () => _toggleSelection(index),
            leading: _isSelecting
                ? Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleSelection(index),
              activeColor: AppColors.vibrantOrange,
            )
                : null,
            title: Text(
              collection.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              dateStr,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            trailing: _isSelecting
                ? null
                : IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: isDark ? Colors.red[300] : Colors.red[700],
              ),
              onPressed: () {
                setState(() => _collections.removeAt(index));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Collection deleted")),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCollections(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.collections_bookmark_outlined,
            size: 90,
            color: isDark ? Colors.white24 : Colors.black26,
          ).animate().fadeIn(duration: 800.ms).scale(curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          Text(
            "No collections yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Tap the + button below to create your first collection",
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

// ────────────────────────────────────────────────
// Models & detail screen
// ────────────────────────────────────────────────

class Collection {
  final String name;
  final DateTime createdAt;

  Collection({
    required this.name,
    required this.createdAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };
}

class CollectionDetailScreen extends StatelessWidget {
  final Collection collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const bool hasRecipes = false; // change when you have real data

    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
      ),
      body: hasRecipes
          ? const Center(child: Text("Your recipes will appear here…"))
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.collections_bookmark_outlined,
                size: 80,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              const SizedBox(height: 24),
              Text(
                "This collection is empty",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Go to any recipe and tap the add button,\n"
                    "then select \"${collection.name}\" to add recipes here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: open detail screen for this favorites category
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 48, color: AppColors.vibrantOrange),
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
              Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}