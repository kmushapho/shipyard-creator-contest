import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';

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
// Detail screen – used for Smart List and each Manual List
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

    Future.delayed(const Duration(milliseconds: 50), () {
      _focusNode.requestFocus();
    });
  }

  void _markAllDone() {
    setState(() {
      for (var item in widget.items) item.checked = true;
    });
    widget.onItemsChanged?.call();
  }

  void _resetAll() {
    setState(() {
      for (var item in widget.items) item.checked = false;
    });
    widget.onItemsChanged?.call();
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Items?"),
        content: const Text(
          "This will remove every item from the list permanently.\nAre you sure?",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.items.clear();
                _selectedIndices.clear();
                _multiSelectMode = false;
              });
              widget.onItemsChanged?.call();
              Navigator.pop(context);

              // Optional: show a quick feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All items cleared"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              "Clear All",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _deleteSelected() {
    setState(() {
      final sorted = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (var idx in sorted) widget.items.removeAt(idx);
      _selectedIndices.clear();
      _multiSelectMode = false;
    });
    widget.onItemsChanged?.call();
  }

  void _removeItem(int index) {
    setState(() {
      widget.items.removeAt(index);
      _selectedIndices.remove(index);
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
              tooltip: 'Delete selected',
              onPressed: _deleteSelected,
            ),
          IconButton(
            icon: Icon(_multiSelectMode ? Icons.close : Icons.checklist),
            tooltip: _multiSelectMode ? 'Cancel' : 'Select items',
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
                      runSpacing: 8,
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
                          label: const Text('Clear all'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              widget.items.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isSmartList ? Icons.lightbulb_outline : Icons.playlist_add_rounded,
                      size: 80,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.isSmartList
                          ? "Your smart list is empty.\nAdd items from recipes or manually below!"
                          : "This list is empty.\nAdd items using the field below.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
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
                  final selected = _selectedIndices.contains(index);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                      tooltip: 'Remove item',
                      onPressed: () => _removeItem(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.checked ? TextDecoration.lineThrough : null,
                        color: item.checked ? Colors.grey[600] : null,
                      ),
                    ),
                    trailing: Checkbox(
                      value: _multiSelectMode ? _selectedIndices.contains(index) : item.checked,
                      onChanged: (bool? newValue) {
                        if (newValue == null) return;

                        setState(() {
                          if (_multiSelectMode) {
                            // multi-select mode → toggle selection
                            if (newValue) {
                              _selectedIndices.add(index);
                            } else {
                              _selectedIndices.remove(index);
                            }
                          } else {
                            // normal mode → toggle checked state
                            item.checked = newValue;
                            widget.onItemsChanged?.call();
                          }
                        });
                      },
                      activeColor: AppColors.vibrantOrange,
                    ),
                    onLongPress: () {
                      setState(() {
                        _multiSelectMode = true;
                        _selectedIndices.add(index);
                      });
                    },
                    onTap: () {
                      if (_multiSelectMode) {
                        // in multi-select: tap toggles selection
                        setState(() {
                          if (_selectedIndices.contains(index)) {
                            _selectedIndices.remove(index);
                          } else {
                            _selectedIndices.add(index);
                          }
                        });
                      } else {
                        // normal mode: tap toggles checked state
                        setState(() {
                          item.checked = !item.checked;
                        });
                        widget.onItemsChanged?.call();
                      }
                    },
                  );
                },
              ),

              // Add item input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Add (e.g. chicken )',
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

  List<ShoppingItem> _smartItems = [];

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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
              tabs: const [Tab(text: "Smart List"), Tab(text: "Manual Lists")],
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

                  // Manual Lists overview with multi-select & delete
                  Stack(
                    children: [
                      _manualLists.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.playlist_add_rounded, size: 80, color: Colors.grey[500]),
                            const SizedBox(height: 24),
                            Text(
                              "No manual lists yet",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Tap below to create one", style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 140),
                        itemCount: _manualLists.length,
                        itemBuilder: (context, index) {
                          final list = _manualLists[index];
                          final checked = list.items.where((i) => i.checked).length;
                          final total = list.items.length;
                          final dateStr = DateFormat('MMM d, yyyy').format(list.createdAt);
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
                                "$dateStr • $checked/$total",
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

                      // Bottom controls
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
}