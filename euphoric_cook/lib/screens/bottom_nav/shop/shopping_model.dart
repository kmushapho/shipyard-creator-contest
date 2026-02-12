import 'package:intl/intl.dart';

class ShoppingItem {
  String name;
  bool checked;

  ShoppingItem({
    required this.name,
    this.checked = false,
  });
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

  String get subtitle {
    final checkedCount = items.where((i) => i.checked).length;
    final dateStr = DateFormat('MMM d, yyyy').format(createdAt);
    return "$dateStr • $checkedCount/${items.length}";
  }
}

class SmartList {
  final String name;
  final List<ShoppingItem> items;
  final DateTime createdAt;

  SmartList({
    required this.name,
    this.items = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get subtitle =>
      "${items.where((i) => i.checked).length}/${items.length} items • ${DateFormat('MMM d').format(createdAt)}";
}