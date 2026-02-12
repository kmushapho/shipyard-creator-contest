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

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Smart Lists ──────────────────────────────────────────────────────────────
  final List<SmartList> _smartLists = [
    SmartList(name: "Drink Smart List"),
    SmartList(name: "Food Smart List"),
    SmartList(
      name: "By Recipe",
      isRecipeBased: true,
      items: [], // we'll show sub-lists instead
    ),
  ];

  // Example sub-recipe lists (you can make this dynamic later)
  final List<SmartList> _recipeSmartLists = [
    SmartList(name: "Bread Recipe"),
    SmartList(name: "Pasta Carbonara"),
    SmartList(name: "Morning Smoothie Bowl"),
    SmartList(name: "Chocolate Cake"),
  ];

  // ── Manual Lists ─────────────────────────────────────────────────────────────
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

  void _createNewManualList() {
    showDialog(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController(
          text: "List ${DateFormat('MMM d').format(DateTime.now())}",
        );
        return AlertDialog(
          title: const Text("New Manual List"),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "e.g. Party Shopping, Birthday Cake Ingredients",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                final name = ctrl.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _manualLists.insert(0, ManualList(name: name, createdAt: DateTime.now()));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteList(int index) {
    final listName = _manualLists[index].name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete List"),
        content: Text("Delete '$listName' permanently?"),
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
      builder: (context) => AlertDialog(
        title: const Text("Delete Selected"),
        content: Text("Delete ${_selectedManualLists.length} lists? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                final sorted = _selectedManualLists.toList()..sort((a, b) => b.compareTo(a));
                for (var idx in sorted) _manualLists.removeAt(idx);
                _multiSelectManualMode = false;
                _selectedManualLists.clear();
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
                  // ── Smart Lists Tab ───────────────────────────────────────────────
                  _buildSmartListsView(),

                  // ── Manual Lists Tab (mostly unchanged) ───────────────────────────
                  Stack(
                    children: [
                      if (_manualLists.isEmpty)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.playlist_add_rounded, size: 80, color: Colors.grey[500]),
                              const SizedBox(height: 24),
                              Text(
                                "No manual lists yet",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text("Tap below to create one", style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 140),
                          itemCount: _manualLists.length,
                          itemBuilder: (context, index) {
                            final list = _manualLists[index];
                            final selected = _selectedManualLists.contains(index);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 1,
                              color: selected ? AppColors.vibrantOrange.withOpacity(0.15) : null,
                              child: ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
                                leading: _multiSelectManualMode
                                    ? Checkbox(
                                  value: selected,
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) _selectedManualLists.add(index);
                                      else _selectedManualLists.remove(index);
                                    });
                                  },
                                  activeColor: AppColors.vibrantOrange,
                                )
                                    : null,
                                title: Text(list.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  list.subtitle,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!_multiSelectManualMode)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        tooltip: 'Delete list',
                                        onPressed: () => _confirmDeleteList(index),
                                      ),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                                onTap: _multiSelectManualMode
                                    ? () {
                                  setState(() {
                                    if (_selectedManualLists.contains(index)) {
                                      _selectedManualLists.remove(index);
                                    } else {
                                      _selectedManualLists.add(index);
                                    }
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

                      // Floating bottom bar for manual lists
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: _multiSelectManualMode
                            ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selectedManualLists.isEmpty ? null : _confirmDeleteSelectedLists,
                                icon: const Icon(Icons.delete_forever, color: Colors.red),
                                label: Text(
                                  "Delete ${_selectedManualLists.length}",
                                  style: const TextStyle(color: Colors.red),
                                ),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
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
                        )
                            : FilledButton.icon(
                          onPressed: _createNewManualList,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text("Create New List"),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.vibrantOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartListsView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Regular smart categories
        ..._smartLists.where((l) => !l.isRecipeBased).map((list) => _smartListTile(list)),

        // "By Recipe" section with sub-lists
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "By Recipe",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ..._recipeSmartLists.map((list) => _smartListTile(list, indent: true)),

        const SizedBox(height: 80), // space for potential future FAB
      ],
    );
  }

  Widget _smartListTile(SmartList list, {bool indent = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(left: indent ? 16 : 0, bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        leading: Icon(
          list.isRecipeBased ? Icons.cookie_rounded : Icons.lightbulb_outline,
          color: AppColors.vibrantOrange,
          size: 32,
        ),
        title: Text(
          list.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          list.subtitle,
          style: TextStyle(color: Colors.grey[600]),
        ),
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
}