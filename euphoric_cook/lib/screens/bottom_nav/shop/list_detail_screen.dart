import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import 'shopping_model.dart';

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

  bool _isAdding = false;

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

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _closeAddInput() {
    if (!mounted) return;
    setState(() => _isAdding = false);
    _addController.clear();
    FocusScope.of(context).unfocus();
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                widget.items.clear();
                _selectedIndices.clear();
                _multiSelectMode = false;
                _isAdding = false;
              });
              widget.onItemsChanged?.call();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All items cleared")),
              );
            },
            child: const Text("Clear All", style: TextStyle(color: Colors.redAccent)),
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

  Widget _buildAddInputRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(28),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: _addController,
                focusNode: _focusNode,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Add item (eggs)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
                onSubmitted: (_) => _addItem(),
              ),
            ),
            const SizedBox(width: 2),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.vibrantOrange, size: 32),
              tooltip: 'Add',
              onPressed: _addItem,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _closeAddInput,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.vibrantOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Done",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        onTap: () {
          if (_isAdding) _closeAddInput();
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.only(
                bottom: bottomInset + (_isAdding ? 160 : 100),
              ),
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

                  if (widget.items.isEmpty)
                    Padding(
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
                                ? "Your smart list is empty.\nTap + to add items!"
                                : "This list is empty.\nTap + to add items.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
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
                            icon: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent, size: 24),
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
                            value: _multiSelectMode ? selected : item.checked,
                            onChanged: (bool? newValue) {
                              if (newValue == null) return;
                              setState(() {
                                if (_multiSelectMode) {
                                  newValue ? _selectedIndices.add(index) : _selectedIndices.remove(index);
                                } else {
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
                              setState(() {
                                _selectedIndices.contains(index)
                                    ? _selectedIndices.remove(index)
                                    : _selectedIndices.add(index);
                              });
                            } else {
                              setState(() => item.checked = !item.checked);
                              widget.onItemsChanged?.call();
                            }
                          },
                        );
                      },
                    ),

                  SizedBox(height: _isAdding ? 160 : 100),
                ],
              ),
            ),

            // Bottom-right: either FAB or input row
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
                child: _isAdding
                    ? _buildAddInputRow()
                    : FloatingActionButton(
                  backgroundColor: AppColors.vibrantOrange,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  onPressed: () {
                    setState(() => _isAdding = true);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) _focusNode.requestFocus();
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}