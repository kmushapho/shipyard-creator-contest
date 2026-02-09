import 'package:flutter/material.dart';

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
    // First two as requested
    {'name': 'Water', 'emoji': '💧'},
    {'name': 'Salt', 'emoji': '🧂'},
    // Removed Sugar & Butter
    {'name': 'Eggs', 'emoji': '🥚'},
    {'name': 'Milk', 'emoji': '🥛'},
    {'name': 'Flour', 'emoji': '🌾'},
    {'name': 'Chicken', 'emoji': '🍗'},
    {'name': 'Rice', 'emoji': '🍚'},
    {'name': 'Pasta', 'emoji': '🍝'},
    {'name': 'Cheese', 'emoji': '🧀'},
  ];

  final List<Map<String, String>> _drinkIngredients = [
    // Water first
    {'name': 'Water', 'emoji': '💧'},
    // Removed Bubble Tea
    {'name': 'Coffee', 'emoji': '☕'},
    {'name': 'Tea', 'emoji': '🍵'},
    {'name': 'Juice', 'emoji': '🧃'},
    {'name': 'Lemonade', 'emoji': '🍋'},
    {'name': 'Cocktail', 'emoji': '🍸'},
    {'name': 'Beer', 'emoji': '🍺'},
    {'name': 'Wine', 'emoji': '🍷'},
    {'name': 'Margarita', 'emoji': '🍹'},
  ];

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

        // Title + animated icon
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

        // Selected chips
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

        // Grid of ingredients
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

        // Add Custom button
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: implement custom ingredient dialog
            },
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

        // Main action button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected.isNotEmpty
                  ? () {
                // TODO: navigate to results
                print('Selected: $selected');
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
}