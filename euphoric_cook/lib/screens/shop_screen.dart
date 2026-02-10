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
// Shared Detail Screen (Smart List & Manual List)
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
  final FocusNode _focusNode = FocusNode();
  bool _multiSelectMode = false;
  final Set<int> _selectedIndices = {};

  @override
  void dispose() {
    _addController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

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
    // Keep keyboard open after adding
    Future.delayed(const Duration(milliseconds: 50), () {
      _focusNode.requestFocus();
    });
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
      _selectedIndices.clear();
      _multiSelectMode = false;
    });
    widget.onItemsChanged?.call();
  }

  void _deleteSelected() {
    setState(() {
      final sortedIndices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (var idx in sortedIndices) {
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        foregroundColor: isDark ? AppColors.lightText : AppColors.darkText,
        actions: [
          if (_multiSelectMode && _selectedIndices.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete selected items',
              onPressed: _deleteSelected,
            ),
          IconButton(
            icon: Icon(_multiSelectMode ? Icons.close : Icons.checklist),
            tooltip: _multiSelectMode ? 'Cancel selection' : 'Select items',
            onPressed: _toggleMultiSelect,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          reverse: true,
          padding: EdgeInsets.only(bottom: bottomInset + 16),
          child: Column(
            children: [
              // Progress & quick actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$_checkedCount / $_totalCount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: widget.items.isNotEmpty ? _markAllDone : null,
                          icon: const Icon(Icons.done_all, size: 18),
                          label: const Text('Mark all'),
                        ),
                        TextButton.icon(
                          onPressed: widget.items.isNotEmpty ? _resetAll : null,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Reset'),
                        ),
                        TextButton.icon(
                          onPressed: widget.items.isNotEmpty ? _clearAll : null,
                          icon: const Icon(Icons.delete_sweep, size: 18),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Items or empty state
              widget.items.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isSmartList ? Icons.lightbulb_outline : Icons.list_alt_rounded,
                      size: 80,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.isSmartList
                          ? "Your smart list is empty.\nAdd items from recipes in Cookbook or manually below!"
                          : "This list has no items yet.\nUse the field below to add some.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = _selectedIndices.contains(index);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        color: item.checked ? Colors.grey[600] : null,
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

              // Add item input (always above keyboard)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Add item (e.g. chicken breast)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voice input – coming soon')),
                        );
                      },
                      icon: const Icon(Icons.mic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  // Smart list starts empty
  List<ShoppingItem> _smartItems = [];

  // Manual lists – one default empty weekly list
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
        final nameCtrl = TextEditingController(text: "New List ${DateTime.now().day}");
        return AlertDialog(
          title: const Text("New Manual List"),
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
                Tab(text: "Smart List"),
                Tab(text: "Manual Lists"),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Smart List
                  ListDetailScreen(
                    title: "Smart List",
                    items: _smartItems,
                    isSmartList: true,
                    onItemsChanged: _refresh,
                  ),

                  // Manual Lists overview
                  _manualLists.isEmpty
                      ? const Center(child: Text("No manual lists yet"))
                      : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _manualLists.length,
                    itemBuilder: (context, index) {
                      final list = _manualLists[index];
                      final checked = list.items.where((i) => i.checked).length;
                      final total = list.items.length;
                      final dateStr = DateFormat('MMM d, yyyy').format(list.createdAt);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                          title: Text(
                            list.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "$dateStr • $checked/$total",
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
      ),

      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
        onPressed: _createNewManualList,
        backgroundColor: AppColors.vibrantOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}