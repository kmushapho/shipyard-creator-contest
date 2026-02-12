import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import 'shop/shopping_model.dart';
import 'shop/list_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // SMART LISTS (hard defined)
  final SmartList foodList = SmartList(name: "Food Smart List");
  final SmartList drinkList = SmartList(name: "Drink Smart List");
  final SmartList foodDrinkList = SmartList(name: "Food & Drink");

  // MANUAL LISTS (with your requested empty one)
  final List<ManualList> _manualLists = [
    ManualList(
      name: "idk myb groceries",
      createdAt: DateTime.now(),
      items: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Shopping List",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                  isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.vibrantOrange,
              unselectedLabelColor:
              isDark ? Colors.white70 : Colors.black54,
              indicatorColor: AppColors.vibrantOrange,
              tabs: const [
                Tab(text: "Smart Lists"),
                Tab(text: "Manual Lists"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSmartListsView(),
                  _buildManualListsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SMART LISTS ----------------

  Widget _buildSmartListsView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _smartListTile(drinkList),
        _smartListTile(foodList),
        _smartListTile(foodDrinkList),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "By Recipe",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
          color: isDark ? Colors.grey[850] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 64,
                  color: AppColors.vibrantOrange.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                const Text(
                  "This section is empty",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _smartListTile(SmartList list) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        leading: const Icon(Icons.lightbulb_outline,
            color: AppColors.vibrantOrange, size: 32),
        title: Text(list.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(list.subtitle,
            style: TextStyle(color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListDetailScreen(
                title: list.name,
                items: list.items,
                isSmartList: true,
                onItemsChanged: _refresh,
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- MANUAL LISTS ----------------

  Widget _buildManualListsView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_manualLists.isEmpty) {
      return Center(
        child: Text(
          "No manual lists",
          style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _manualLists.length,
      itemBuilder: (context, index) {
        final list = _manualLists[index];
        return Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            title: Text(list.name),
            subtitle: Text(list.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListDetailScreen(
                    title: list.name,
                    items: list.items,
                    onItemsChanged: _refresh,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
