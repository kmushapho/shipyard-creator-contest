import 'package:flutter/material.dart';
import '../../constants/colors.dart'; // adjust path if needed

class AllDayMealsMenu extends StatefulWidget {
  const AllDayMealsMenu({super.key});

  @override
  State<AllDayMealsMenu> createState() => _AllDayMealsMenuState();
}

class _AllDayMealsMenuState extends State<AllDayMealsMenu> {
  int selectedIndex = 0;

  final List<_MealCategory> meals = const [
    _MealCategory("Breakfast", "🍳"),
    _MealCategory("Lunch", "🥪"),
    _MealCategory("Dinner", "🍝"),
    _MealCategory("Snack", "🍪"),
    _MealCategory("Dessert", "🧁"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        /// 🔥 Horizontal Pill Menu
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _pillButton("All Day Meals", 0),
            ],
          ),
        ),

        const SizedBox(height: 16),

        /// 🧩 Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              return _MealCard(meal: meals[index]);
            },
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _pillButton(String title, int index) {
    final bool selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => setState(() => selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: selected
                ? const LinearGradient(
              colors: [
                AppColors.vibrantOrange,
                AppColors.vibrantGreen,
              ],
            )
                : null,
            color: selected ? null : AppColors.cardBgLight,
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.vibrantOrange.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? AppColors.lightText : AppColors.darkText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🧩 Meal Card
class _MealCard extends StatelessWidget {
  final _MealCategory meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBgLight,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // TODO: Hook navigation later
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              meal.emoji,
              style: const TextStyle(fontSize: 38),
            ),
            const SizedBox(height: 10),
            Text(
              meal.title,
              style: const TextStyle(
                color: AppColors.darkText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🧠 Model
class _MealCategory {
  final String title;
  final String emoji;

  const _MealCategory(this.title, this.emoji);
}
