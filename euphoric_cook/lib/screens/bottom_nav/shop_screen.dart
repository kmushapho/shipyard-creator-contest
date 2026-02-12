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

  // SMART LISTS
  final SmartList foodList = SmartList(name: "Food Smart List");
  final SmartList drinkList = SmartList(name: "Drink Smart List");
  final SmartList foodDrinkList = SmartList(name: "Food & Drink");

  // MANUAL LISTS
  final List<ManualList> _manualLists = [
    ManualList(
      name: "Weekly Groceries",
      createdAt: DateTime.now(),
      items: [],
    ),
  ];

  bool _multiSelectManualMode = false;
  final Set<int> _selectedManualLists = {};

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

  // ---------------- DELETE HELPERS ----------------

  void _confirmDeleteList(int index) {
    final name = _manualLists[index].name;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete List"),
        content: Text("Delete '$name' permanently?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() => _manualLists.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSelectedLists() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Selected"),
        content: Text("Delete ${_selectedManualLists.length} lists?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                final sorted = _selectedManualLists.toList()
                  ..sort((a, b) => b.compareTo(a));
                for (var i in sorted) {
                  _manualLists.removeAt(i);
                }
                _selectedManualLists.clear();
                _multiSelectManualMode = false;
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------

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
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.vibrantOrange,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
          color: isDark ? Colors.grey[850] : Colors.white,
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.menu_book_rounded, size: 64, color: AppColors.vibrantOrange),
                SizedBox(height: 16),
                Text("This section is empty", style: TextStyle(color: Colors.grey)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        leading: const Icon(Icons.lightbulb_outline,
            color: AppColors.vibrantOrange, size: 32),
        title: Text(list.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(list.subtitle, style: TextStyle(color: Colors.grey[600])),
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
        child: Text("No manual lists",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
          itemCount: _manualLists.length,
          itemBuilder: (context, index) {
            final list = _manualLists[index];
            final selected = _selectedManualLists.contains(index);

            return Card(
              color: selected ? AppColors.vibrantOrange.withOpacity(0.15) : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: _multiSelectManualMode
                    ? Checkbox(
                  value: selected,
                  onChanged: (v) {
                    setState(() {
                      v == true
                          ? _selectedManualLists.add(index)
                          : _selectedManualLists.remove(index);
                    });
                  },
                  activeColor: AppColors.vibrantOrange,
                )
                    : null,
                title: Text(list.name),
                subtitle: Text(list.subtitle),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_multiSelectManualMode)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _confirmDeleteList(index),
                      ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: _multiSelectManualMode
                    ? () {
                  setState(() {
                    selected
                        ? _selectedManualLists.remove(index)
                        : _selectedManualLists.add(index);
                  });
                }
                    : () {
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
                onLongPress: () {
                  setState(() {
                    _multiSelectManualMode = true;
                    _selectedManualLists.add(index);
                  });
                },
              ),
            );
          },
        ),

        if (_multiSelectManualMode)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectedManualLists.isEmpty
                        ? null
                        : _confirmDeleteSelectedLists,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: Text(
                      "Delete ${_selectedManualLists.length}",
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _multiSelectManualMode = false;
                      _selectedManualLists.clear();
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: const Text("Cancel"),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
