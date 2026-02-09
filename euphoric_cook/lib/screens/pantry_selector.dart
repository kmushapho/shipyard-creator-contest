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

  final List<Map<String, String>> _foodIngredients = [
    {'name': 'Water', 'emoji': '💧'},
    {'name': 'Salt', 'emoji': '🧂'},
    {'name': 'Eggs', 'emoji': '🥚'},
    {'name': 'Milk', 'emoji': '🥛'},
    {'name': 'Flour', 'emoji': '🌾'},
    {'name': 'Chicken', 'emoji': '🍗'},
    {'name': 'Rice', 'emoji': '🍚'},
    {'name': 'Pasta', 'emoji': '🍝'},
    {'name': 'Cheese', 'emoji': '🧀'},
  ];

  final List<Map<String, String>> _drinkIngredients = [
    {'name': 'Water', 'emoji': '💧'},
    {'name': 'Coffee', 'emoji': '☕'},
    {'name': 'Tea', 'emoji': '🍵'},
    {'name': 'Juice', 'emoji': '🧃'},
    {'name': 'Lemonade', 'emoji': '🍋'},
    {'name': 'Cocktail', 'emoji': '🍸'},
    {'name': 'Beer', 'emoji': '🍺'},
    {'name': 'Wine', 'emoji': '🍷'},
    {'name': 'Margarita', 'emoji': '🍹'},
  ];

  Future<List<Map<String, dynamic>>> fetchRecipesByIngredients(Set<String> selected) async {
    if (selected.isEmpty) return [];

    // Edamam Meal Planner Endpoint
    final String appId = '6cff42be';
    final String appKey = 'c9667882039fd44fc94f1f4efa2cae1b';
    final String url = 'https://api.edamam.com';

    // Auth: Basic Auth (Base64 of ID:Key)
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$appId:$appKey'));

    // Prepare ingredients for the JSON body
    List<Map<String, String>> preselected = selected.map((ing) => {"preselected": ing}).toList();

    final Map<String, dynamic> requestBody = {
      "plan": {
        "accept": {
          "all": preselected // Forces recipes to include these ingredients
        }
      },
      "rules": {
        "daily_meals": [
          {"label": "Suggested Meal", "type": "selection"}
        ]
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
          'Edamam-Account-User': 'unique_user_id_123', // Required for Free Tier (10 max)
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Edamam Meal Planner returns a structure containing 'selection'
        // You can extract recipes and nutrition facts directly from the response
        List<Map<String, dynamic>> meals = [];
        if (data['selection'] != null) {
          for (var day in data['selection']) {
            for (var section in day['sections'].values) {
              // Access nutrition via section['assigned']['recipe']['totalNutrients']
              meals.add(section['assigned']);
            }
          }
        }
        return meals;
      } else {
        print('Status Code: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to fetch meal plan');
      }
    } catch (e) {
      print('Error: $e');
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
    final titleText = widget.isFood ? "Wats Cookin'" : "Wats Mixin'";
    final animatedEmoji = widget.isFood ? "🍳" : "🥤";
    final selectedCount = selected.length;

    return Column(
      children: [
        const SizedBox(height: 3),

        Center(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    titleText,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: widget.accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        alignment: Alignment.center,
                        child: Text(
                          animatedEmoji,
                          style: const TextStyle(fontSize: 36),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tap to add ingredients!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$selectedCount ingredient${selectedCount == 1 ? '' : 's'} selected',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.accentColor.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

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
                labelStyle: TextStyle(color: widget.accentColor, fontSize: 14.5),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: StadiumBorder(
                  side: BorderSide(color: widget.accentColor.withOpacity(0.4)),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 36),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.86,
              crossAxisSpacing: 18,
              mainAxisSpacing: 22,
            ),
            itemCount: ingredients.length,
            itemBuilder: (context, i) {
              final ing = ingredients[i];
              final name = ing['name']!;
              final emoji = ing['emoji']!;
              final isSelected = selected.contains(name);

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
                          radius: 40,
                          backgroundColor: widget.accentColor.withOpacity(0.14),
                          child: Text(emoji, style: const TextStyle(fontSize: 38)),
                        ),
                        if (isSelected)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                              ),
                              child: const Icon(Icons.check, size: 18, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13.5, height: 1.2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 36),

        Center(
          child: OutlinedButton.icon(
            onPressed: () => _showCustomBottomSheet(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Add Custom'),
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.accentColor,
              side: BorderSide(color: widget.accentColor),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),

        const SizedBox(height: 48),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected.isNotEmpty
                  ? () async {
                await fetchRecipesByIngredients(selected);
              }
                  : null,

              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: selected.isNotEmpty ? 6 : 0,
              ),
              child: Text(
                widget.isFood ? "Let's Cook!" : "Let's Party!",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),

        const SizedBox(height: 80),
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
//     Bottom Sheet – input always above keyboard
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
  State<CustomIngredientBottomSheet> createState() =>
      _CustomIngredientBottomSheetState();
}

class _CustomIngredientBottomSheetState
    extends State<CustomIngredientBottomSheet> {
  late Set<String> _selected;
  final _controller = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
    _controller.addListener(() {
      if (_errorMessage != null) {
        setState(() => _errorMessage = null);
      }
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
    final actionText = "Done";

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
            // Drag handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Header
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

            // Scrollable selected chips
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

            // Bottom fixed input area
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
                  // Input row
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
                            hintText: 'e.g. Milk',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: widget.accentColor.withOpacity(0.06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
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
                        icon: Icon(
                          Icons.add_circle_rounded,
                          color: widget.accentColor,
                          size: 36,
                        ),
                        onPressed: _addIngredient,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Helper text – one at a time
                  Text(
                    'One at a time • + to add • Done when finished',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Action button
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        elevation: 2,
                      ),
                      child: Text(
                        actionText,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
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