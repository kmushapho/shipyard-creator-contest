import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/colors.dart';

// ────────────────────────────────────────────────
// Models
// ────────────────────────────────────────────────

class ShoppingItem {
  String name;
  bool checked;

  ShoppingItem({required this.name, this.checked = false});
}

class ManualList {
  String name;
  DateTime createdAt;
  List<ShoppingItem> items;

  ManualList({
    required this.name,
    required this.createdAt,
    this.items = const [],
  });
}

// ────────────────────────────────────────────────
// Detail Screen (used by both Smart & Manual)
// ────────────────────────────────────────────────

class ListDetailScreen extends StatefulWidget {
  final String title;
  final List<ShoppingItem> items;
  final bool isSmartList;
  final VoidCallback? onItemsChanged;

  const ListDetailScreen({
    super.key,
    required this.title,
    required this.items,
    this.isSmartList = false,
    this.onItemsChanged,
  });

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final TextEditingController _addController = TextEditingController();
  bool _multiSelectMode = false;
  final Set<int> _selectedIndices = {};

  int get _checkedCount => widget.items.where((i) => i.checked).length;
  int get _totalCount => widget.items.length;

  void _toggleMultiSelect() {
    setState(() {
      _multiSelectMode = !_multiSelectMode;
      if (!_multiSelectMode) _selectedIndices.clear();
    });
  }

  void _addItem() {
    final text = _addController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      widget.items.add(ShoppingItem(name: text));
      _addController.clear();
    });
    widget.onItemsChanged?.call();
  }

  void _markAllDone() {
    setState(() {
      for (var item in widget.items) {
        item.checked = true;
      }
    });
    widget.onItemsChanged?.call();
  }

  void _resetAll() {
    setState(() {
      for (var item in widget.items) {
        item.checked = false;
      }
    });
    widget.onItemsChanged?.call();
  }

  void _clearAll() {
    setState(() {
      widget.items.clear();
    });
    widget.onItemsChanged?.call();
  }

  void _deleteSelected() {
    setState(() {
      final indices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (var idx in indices) {
        widget.items.removeAt(idx);
      }
      _selectedIndices.clear();
      _multiSelectMode = false;
    });
    widget.onItemsChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        foregroundColor: isDark ? AppColors.lightText : AppColors.darkText,
        actions: [
          if (_multiSelectMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete selected',
              onPressed: _selectedIndices.isNotEmpty ? _deleteSelected : null,
            ),
          IconButton(
            icon: Icon(_multiSelectMode ? Icons.close : Icons.select_all),
            tooltip: _multiSelectMode ? 'Cancel selection' : 'Select items',
            onPressed: _toggleMultiSelect,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress & quick actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_checkedCount / $_totalCount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _markAllDone,
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Mark all'),
                    ),
                    TextButton.icon(
                      onPressed: _resetAll,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: widget.items.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isSmartList ? Icons.lightbulb_outline : Icons.list_alt,
                      size: 64,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.isSmartList
                          ? "No items in your smart list yet.\nAdd recipes from Cookbook or add items manually below!"
                          : "This list is empty.\nAdd some items below!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = _selectedIndices.contains(index);

                return ListTile(
                  leading: _multiSelectMode
                      ? Checkbox(
                    value: isSelected,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedIndices.add(index);
                        } else {
                          _selectedIndices.remove(index);
                        }
                      });
                    },
                    activeColor: AppColors.vibrantOrange,
                  )
                      : null,
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.checked ? TextDecoration.lineThrough : null,
                      color: item.checked ? Colors.grey : null,
                    ),
                  ),
                  trailing: !_multiSelectMode
                      ? Checkbox(
                    value: item.checked,
                    onChanged: (val) {
                      setState(() => item.checked = val ?? false);
                      widget.onItemsChanged?.call();
                    },
                    activeColor: AppColors.vibrantOrange,
                  )
                      : null,
                  onLongPress: () {
                    setState(() {
                      _multiSelectMode = true;
                      _selectedIndices.add(index);
                    });
                  },
                  onTap: _multiSelectMode
                      ? () {
                    setState(() {
                      if (_selectedIndices.contains(index)) {
                        _selectedIndices.remove(index);
                      } else {
                        _selectedIndices.add(index);
                      }
                    });
                  }
                      : () {
                    setState(() => item.checked = !item.checked);
                    widget.onItemsChanged?.call();
                  },
                );
              },
            ),
          ),

          // Add item row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: InputDecoration(
                      hintText: 'Add item (e.g. 500g chicken)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.vibrantOrange,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice input coming soon')),
                    );
                  },
                  icon: const Icon(Icons.mic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Main Shop Screen
// ────────────────────────────────────────────────

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Smart list – starts empty
  List<ShoppingItem> _smartItems = [];

  // Manual lists – one empty weekly example
  final List<ManualList> _manualLists = [
    ManualList(
      name: "Weekly Groceries",
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

  void _createNewManualList() {
    showDialog(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController(text: "New List");
        return AlertDialog(
          title: const Text("Create new list"),
          content: TextField(
            controller: nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: "List name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _manualLists.insert(
                      0,
                      ManualList(name: name, createdAt: DateTime.now()),
                    );
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
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
              Tab(text: "Smart List"),
              Tab(text: "Manual Lists"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Smart List ──
                ListDetailScreen(
                  title: "Smart List",
                  items: _smartItems,
                  isSmartList: true,
                  onItemsChanged: _refresh,
                ),

                // ── Manual Lists ──
                _manualLists.isEmpty
                    ? const Center(child: Text("No manual lists yet"))
                    : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _manualLists.length,
                  itemBuilder: (context, index) {
                    final list = _manualLists[index];
                    final checked = list.items.where((i) => i.checked).length;
                    final total = list.items.length;
                    final date = DateFormat('MMM d, yyyy').format(list.createdAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                        title: Text(
                          list.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "$date • $checked/$total items",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
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
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
        onPressed: _createNewManualList,
        backgroundColor: AppColors.vibrantOrange,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}