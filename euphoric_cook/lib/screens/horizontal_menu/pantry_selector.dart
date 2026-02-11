import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantrySelector extends StatefulWidget {
  final bool isFood;
  final Color accentColor;

  const PantrySelector({
    super.key,
    required this.isFood,
    required this.accentColor,
  });

  @override
  State<PantrySelector> createState() => _PantrySelectorState();
}

class _PantrySelectorState extends State<PantrySelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  // Helper: convert ingredient name → filename (lowercase + spaces → underscores)
  String _toAssetFilename(String name) {
    return name.toLowerCase().replaceAll(' ', '_') + '.png';
  }

  final List<Map<String, String>> _foodIngredients = [
    {'name': 'Flour'},
    {'name': 'Sugar'},
    {'name': 'Rice'},
    {'name': 'Pasta'},
    {'name': 'Bread'},
    {'name': 'Honey'},
    {'name': 'Olive Oil'},
    {'name': 'Vinegar'},
    {'name': 'Soy Sauce'},
    {'name': 'Oats'},
    {'name': 'Noodles'},
    {'name': 'Beans'},
    {'name': 'Milk'},
    {'name': 'Eggs'},
    {'name': 'Butter'},
    {'name': 'Cheese'},
    {'name': 'Yogurt'},
    {'name': 'Chicken'},
    {'name': 'Beef'},
    {'name': 'Bacon'},
    {'name': 'Fish'},
    {'name': 'Shrimp'},
    {'name': 'Water'},
    {'name': 'Onion'},
    {'name': 'Garlic'},
    {'name': 'Potato'},
    {'name': 'Tomato'},
    {'name': 'Carrot'},
    {'name': 'Lemon'},
    {'name': 'Ginger'},
    {'name': 'Chili'},
    {'name': 'Bell Pepper'},
    {'name': 'Broccoli'},
    {'name': 'Mushroom'},
    {'name': 'Avocado'},
    {'name': 'Salt'},
    {'name': 'Black Pepper'},
    {'name': 'Cinnamon'},
    {'name': 'Chocolate'},
    {'name': 'Tea'},
  ];

  final List<Map<String, String>> _drinkIngredients = [
    {'name': 'Vodka'},
    {'name': 'Gin'},
    {'name': 'Light Rum'},
    {'name': 'Dark Rum'},
    {'name': 'Tequila'},
    {'name': 'Bourbon'},
    {'name': 'Whiskey'},
    {'name': 'Brandy'},
    {'name': 'Champagne'},
    {'name': 'Red Wine'},
    {'name': 'White Wine'},
    {'name': 'Beer'},
    {'name': 'Water'},
    {'name': 'Club Soda'},
    {'name': 'Tonic Water'},
    {'name': 'Ginger Ale'},
    {'name': 'Cola'},
    {'name': 'Milk'},
    {'name': 'Coffee'},
    {'name': 'Tea'},
    {'name': 'Orange Juice'},
    {'name': 'Lemon Juice'},
    {'name': 'Lime Juice'},
    {'name': 'Pineapple Juice'},
    {'name': 'Cranberry Juice'},
    {'name': 'Apple Juice'},
    {'name': 'Tomato Juice'},
    {'name': 'Grapefruit Juice'},
    {'name': 'Simple Syrup'},
    {'name': 'Honey'},
    {'name': 'Sugar'},
    {'name': 'Maple Syrup'},
    {'name': 'Grenadine'},
    {'name': 'Mint'},
    {'name': 'Lemon Peel'},
    {'name': 'Lime Wedge'},
    {'name': 'Cherry'},
    {'name': 'Olive'},
    {'name': 'Cinnamon'},
    {'name': 'Ice'},
  ];

  Future<List<Map<String, dynamic>>> fetchRecipesByIngredients(Set<String> selected) async {
    if (selected.isEmpty) return [];

    final String appId = '6cff42be';
    final String appKey = 'c9667882039fd44fc94f1f4efa2cae1b';
    final String url = 'https://api.edamam.com';

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$appId:$appKey'));

    List<Map<String, String>> preselected = selected.map((ing) => {'preselected': ing}).toList();

    final Map<String, dynamic> requestBody = {
      'plan': {
        'accept': {'all': preselected}
      },
      'rules': {
        'daily_meals': [
          {'label': 'Suggested Meal', 'type': 'selection'}
        ]
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
          'Edamam-Account-User': 'unique_user_id_123',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> meals = [];
        if (data['selection'] != null) {
          for (var day in data['selection']) {
            for (var section in day['sections'].values) {
              meals.add(section['assigned']);
            }
          }
        }
        return meals;
      } else {
        print('Edamam status: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Fetch error: $e');
      return [];
    }
  }

  Set<String> selected = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.isFood ? _foodIngredients : _drinkIngredients;
    final buttonText = widget.isFood ? "Let's Cook!" : "Let's Party!";
    final selectedCount = selected.length;

    return Column(
      children: [
        const SizedBox(height: 16),

        // Action buttons row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                flex: 65,
                child: OutlinedButton.icon(
                  onPressed: () => _showCustomBottomSheet(context),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: const Text(
                    'Add Ingredient',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.accentColor,
                    side: BorderSide(color: widget.accentColor, width: 1.4),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 35,
                child: ElevatedButton(
                  onPressed: selected.isNotEmpty
                      ? () async {
                    final recipes = await fetchRecipesByIngredients(selected);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Found ${recipes.length} suggestions!'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: selected.isNotEmpty ? 4 : 1,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Center(
          child: Text(
            '$selectedCount ingredient${selectedCount == 1 ? '' : 's'} selected',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selectedCount > 0 ? widget.accentColor : Colors.grey[700],
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: selected.map((name) {
                return Chip(
                  label: Text(name),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => setState(() => selected.remove(name)),
                  backgroundColor: widget.accentColor.withOpacity(0.13),
                  labelStyle: TextStyle(color: widget.accentColor, fontSize: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: StadiumBorder(
                    side: BorderSide(color: widget.accentColor.withOpacity(0.4)),
                  ),
                );
              }).toList(),
            ),
          ),

        SizedBox(height: selected.isNotEmpty ? 24 : 32),

        // ─── Image Grid ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.78,
              crossAxisSpacing: 12,
              mainAxisSpacing: 20,
            ),
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ing = ingredients[index];
              final name = ing['name']!;
              final isSelected = selected.contains(name);

              final String folder = widget.isFood ? 'food' : 'drink';
              final String filename = _toAssetFilename(name);
              final String assetPath = 'assets/pics/$folder/$filename';

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selected.remove(name);
                    } else {
                      selected.add(name);
                    }
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: widget.accentColor.withOpacity(0.14),
                          backgroundImage: AssetImage(assetPath),
                          onBackgroundImageError: (_, __) {
                            // Optional: you can log or handle missing images here
                          },
                          child: null, // no fallback emoji/text needed if images exist
                        ),
                        if (isSelected)
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2),
                                ),
                              ),
                              child: const Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 60),
      ],
    );
  }

  void _showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomIngredientBottomSheet(
          isFood: widget.isFood,
          accentColor: widget.accentColor,
          initialSelected: selected,
          onSelectionChanged: (newSet) {
            setState(() => selected = newSet);
          },
        );
      },
    );
  }
}

// ────────────────────────────────────────────────
// Custom Ingredient Bottom Sheet (unchanged)
// ────────────────────────────────────────────────
class CustomIngredientBottomSheet extends StatefulWidget {
  final bool isFood;
  final Color accentColor;
  final Set<String> initialSelected;
  final ValueChanged<Set<String>> onSelectionChanged;

  const CustomIngredientBottomSheet({
    super.key,
    required this.isFood,
    required this.accentColor,
    required this.initialSelected,
    required this.onSelectionChanged,
  });

  @override
  State<CustomIngredientBottomSheet> createState() => _CustomIngredientBottomSheetState();
}

class _CustomIngredientBottomSheetState extends State<CustomIngredientBottomSheet> {
  late Set<String> _selected;
  final _controller = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
    _controller.addListener(() {
      if (_errorMessage != null) setState(() => _errorMessage = null);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addIngredient() {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    text = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');

    final lower = text.toLowerCase();
    if (_selected.any((item) => item.toLowerCase() == lower)) {
      setState(() {
        _errorMessage = '"$text" is already added';
      });
      return;
    }

    setState(() {
      _selected.add(text);
      _controller.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final count = _selected.length;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Ingredients',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.accentColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: widget.accentColor),
                    onPressed: () {
                      widget.onSelectionChanged(_selected);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '$count ingredient${count == 1 ? '' : 's'} selected',
                style: TextStyle(
                  fontSize: 15,
                  color: widget.accentColor.withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: _selected.map((name) {
                    return Chip(
                      label: Text(name),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => setState(() => _selected.remove(name)),
                      backgroundColor: widget.accentColor.withOpacity(0.11),
                      labelStyle: TextStyle(color: widget.accentColor, fontSize: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: widget.accentColor.withOpacity(0.3)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          autocorrect: true,
                          enableSuggestions: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addIngredient(),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[,\n]')),
                            FilteringTextInputFormatter.singleLineFormatter,
                          ],
                          decoration: InputDecoration(
                            hintText: 'e.g. Cinnamon',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: widget.accentColor.withOpacity(0.06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed: _controller.clear,
                            )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(Icons.add_circle_rounded, color: widget.accentColor, size: 36),
                        onPressed: _addIngredient,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'One at a time • + to add • Done when finished',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(fontSize: 13, color: Colors.red[700], fontWeight: FontWeight.w500),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selected.isNotEmpty
                          ? () {
                        widget.onSelectionChanged(_selected);
                        Navigator.pop(context);
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
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