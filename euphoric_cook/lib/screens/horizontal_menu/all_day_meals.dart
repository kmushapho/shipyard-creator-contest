import 'package:flutter/material.dart';
import '../../constants/colors.dart'; // adjust path if needed

class AllDayMealsMenu extends StatelessWidget {
  const AllDayMealsMenu({super.key});

  final List<_MealCategory> meals = const [
    _MealCategory(
      title: "Breakfast",
      emoji: "🍳",
      description: "Quick & energizing morning meals",
    ),
    _MealCategory(
      title: "Lunch",
      emoji: "🥪",
      description: "Balanced midday refuels & hearty bowls",
    ),
    _MealCategory(
      title: "Dinner",
      emoji: "🍝",
      description: "Comforting evening plates & family meals",
    ),
    _MealCategory(
      title: "Snack",
      emoji: "🍪",
      description: "Light bites between meals",
    ),
    _MealCategory(
      title: "Dessert",
      emoji: "🧁",
      description: "Sweet treats & indulgent finishes",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // Vertical list of meal cards/buttons
          ...meals.map((meal) => _MealItem(meal: meal)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MealItem extends StatelessWidget {
  final _MealCategory meal;

  const _MealItem({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to meal category screen
          // e.g. Navigator.pushNamed(context, '/meals/${meal.title.toLowerCase()}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppColors.cardBgLight,
                AppColors.cardBgLight.withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: AppColors.vibrantOrange.withOpacity(0.15),
              highlightColor: AppColors.vibrantGreen.withOpacity(0.1),
              onTap: () {}, // Handled by GestureDetector for animation
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    // Emoji with subtle shadow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightBg.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        meal.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title + Description column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            meal.description,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.darkText.withOpacity(0.75),
                              height: 1.35,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Trailing icon with subtle color accent
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.vibrantOrange.withOpacity(0.8),
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MealCategory {
  final String title;
  final String emoji;
  final String description;

  const _MealCategory({
    required this.title,
    required this.emoji,
    required this.description,
  });
}