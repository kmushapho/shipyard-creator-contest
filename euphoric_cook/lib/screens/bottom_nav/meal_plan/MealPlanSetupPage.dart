import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../providers/user_provider.dart';

class MealPlanSetupPage extends StatefulWidget {
  const MealPlanSetupPage({super.key});

  @override
  State<MealPlanSetupPage> createState() => _MealPlanSetupPageState();
}

class _MealPlanSetupPageState extends State<MealPlanSetupPage> {
  final PageController _pageController = PageController();
  final TextEditingController _avoidController = TextEditingController();
  int _currentPage = 0;

  String _selectedGoal = 'Weight loss';
  final List<String> _includedMeals = ['Breakfast', 'Lunch', 'Dinner'];

  void _nextPage() => _pageController.nextPage(
      duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);

  void _prevPage() => _pageController.previousPage(
      duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = userProvider.isDarkMode;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final textColor = isDark ? AppColors.lightText : AppColors.darkText;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage > 0) _buildHeader(textColor),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _screen0Welcome(userProvider, textColor),
                  _screen1Profile(userProvider, isDark, textColor),
                  _screen2Goals(isDark, textColor),
                  _screen3Frequency(isDark, textColor),
                  _screen4Nutrition(isDark, textColor),
                  _screen5CookingTime(isDark, textColor),
                  _screen6PantryAndGenerate(userProvider, isDark, textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SCREEN 0: WELCOME ---
  Widget _screen0Welcome(UserProvider up, Color txt) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 100, color: AppColors.vibrantOrange),
            const SizedBox(height: 40),
            Text(
              "Welcome, ${up.name}!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: txt, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),
            Text(
              "Ready to craft your perfect meals?",
              textAlign: TextAlign.center,
              style: TextStyle(color: txt.withOpacity(0.65), fontSize: 20, height: 1.4),
            ),
            const SizedBox(height: 60),
            PremiumButton(text: "Start Planning →", color: AppColors.vibrantOrange, onPressed: _nextPage),
          ],
        ),
      ),
    );
  }

  // --- SCREEN 1: SMART PROFILE ---
  Widget _screen1Profile(UserProvider user, bool isDark, Color txt) {
    final dietaryItems = [
      "Vegetarian",
      "Vegan",
      "Gluten-Free",
      "Dairy-Free",
      "Kosher",
      "Halal",
      "Paleo",
      "Pescatarian"
    ];
    final nutritionItems = [
      "Healthy",
      "Low Calorie",
      "Low Carb",
      "Low Fat",
      "Low Sodium",
      "Low Sugar",
      "Low Cholesterol",
      "High Fiber",
      "Kidney Friendly"
    ];
    final allergyItems = ["Peanut Free", "Soy Free", "Tree Nut Free", "Shellfish Free"];

    return _pageWrapper(
      title: "Smart Profile",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MultiSelectDropdown(title: "Dietary Restrictions", items: dietaryItems, user: user),
          const SizedBox(height: 24),
          _MultiSelectDropdown(title: "Nutritional & Health Tags", items: nutritionItems, user: user),
          const SizedBox(height: 24),
          _MultiSelectDropdown(title: "Allergy-Specific Tags", items: allergyItems, user: user),
          const SizedBox(height: 24),
          _buildTagInput(
            "Foods to Avoid",
            user.foodsToAvoid,
            _avoidController,
            user.addFoodToAvoid,
            user.removeFoodToAvoid,
            isDark,
            txt,
          ),
        ],
      ),
      footer: PremiumButton(text: "Continue", color: AppColors.vibrantOrange, onPressed: _nextPage),
    );
  }

  // --- SCREEN 2: GOALS ---
  Widget _screen2Goals(bool isDark, Color txt) {
    final goals = [
      {'t': 'Weight loss', 'i': '🔥'},
      {'t': 'Muscle gain', 'i': '💪'},
      {'t': 'Energy & wellness', 'i': '⚡'},
      {'t': 'Medical management', 'i': '🩺'},
    ];
    return _pageWrapper(
      title: "Goals in Motion",
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: goals
            .map(
              (g) => InkWell(
            onTap: () => setState(() => _selectedGoal = g['t']!),
            child: Container(
              decoration: BoxDecoration(
                color: _selectedGoal == g['t']
                    ? AppColors.vibrantOrange.withOpacity(0.12)
                    : (isDark ? AppColors.cardBgDark : Colors.white),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: _selectedGoal == g['t']
                        ? AppColors.vibrantOrange
                        : Colors.transparent,
                    width: 2),
                boxShadow: [
                  if (_selectedGoal == g['t'])
                    BoxShadow(
                        color: AppColors.vibrantOrange.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(g['i']!, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    g['t']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        )
            .toList(),
      ),
      footer: PremiumButton(text: "Continue", color: AppColors.vibrantOrange, onPressed: _nextPage),
    );
  }

  // --- SCREEN 3: FREQUENCY ---
  Widget _screen3Frequency(bool isDark, Color txt) {
    final meals = ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Dessert'];
    return _pageWrapper(
      title: "Meal Frequency",
      child: Column(
        children: meals
            .map(
              (m) => Card(
            color: isDark ? AppColors.cardBgDark : Colors.white,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: CheckboxListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(m, style: TextStyle(color: txt, fontWeight: FontWeight.w600)),
              value: _includedMeals.contains(m),
              activeColor: AppColors.vibrantOrange,
              onChanged: (val) =>
                  setState(() => val! ? _includedMeals.add(m) : _includedMeals.remove(m)),
            ),
          ),
        )
            .toList(),
      ),
      footer: PremiumButton(text: "Set Schedule", color: AppColors.vibrantOrange, onPressed: _nextPage),
    );
  }

  // --- SCREEN 4: NUTRITION ---
  Widget _screen4Nutrition(bool isDark, Color txt) {
    return _pageWrapper(
      title: "Nutrition Targets",
      child: Column(
        children: [
          _buildTargetField("Calories", "2400 kcal", txt, isDark),
          _buildTargetField("Protein (g)", "150g", txt, isDark),
          _buildTargetField("Fats (g)", "70g", txt, isDark),
          _buildTargetField("Water (L)", "2 L", txt, isDark),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: 0.7,
              minHeight: 14,
              backgroundColor: Colors.grey.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.vibrantBlue),
            ),
          ),
        ],
      ),
      footer: PremiumButton(text: "Next", color: AppColors.vibrantOrange, onPressed: _nextPage),
    );
  }

  // --- SCREEN 5: COOKING TIME ---
  Widget _screen5CookingTime(bool isDark, Color txt) {
    return _pageWrapper(
      title: "Cooking Time",
      child: Column(
        children: ['10–20 min', '20–40 min', '40+ min']
            .map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: PremiumOutlineButton(text: t, color: AppColors.vibrantGreen, onPressed: _nextPage),
        ))
            .toList(),
      ),
    );
  }

  // --- SCREEN 6: PANTRY & GENERATE ---
  Widget _screen6PantryAndGenerate(UserProvider up, bool isDark, Color txt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PremiumButton(
              text: "Add Pantry & Generate Meals",
              color: AppColors.vibrantBlue,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantryGenerateScreen(),
                    ));
              },
            ),
            const SizedBox(height: 22),
            PremiumButton(
              text: "Generate Suggested Meals",
              color: AppColors.vibrantOrange,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Generate Suggested Meals clicked!")));
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE WRAPPERS ---
  Widget _pageWrapper({required String title, required Widget child, Widget? footer}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.vibrantOrange,
                  letterSpacing: 0.5)),
          const SizedBox(height: 26),
          Expanded(child: SingleChildScrollView(child: child)),
          if (footer != null) ...[const SizedBox(height: 20), footer],
        ],
      ),
    );
  }

  Widget _buildHeader(Color txt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 24, 0),
      child: Row(
        children: [
          IconButton(
              onPressed: _prevPage,
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: txt)),
          Expanded(
            child: LinearProgressIndicator(
              value: _currentPage / 6,
              backgroundColor: txt.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation(AppColors.vibrantOrange),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 16),
          Text("Step $_currentPage/6",
              style: TextStyle(color: txt.withOpacity(0.4), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTagInput(
      String label,
      List<String> tags,
      TextEditingController ctrl,
      Function(String) onAdd,
      Function(String) onRem,
      bool isDark,
      Color txt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags
              .map((t) => Chip(
            label: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
            onDeleted: () => onRem(t),
            backgroundColor: AppColors.vibrantOrange.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ))
              .toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          style: TextStyle(color: txt),
          decoration: InputDecoration(
            hintText: "Add item...",
            suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.vibrantOrange),
                onPressed: () {
                  if (ctrl.text.isNotEmpty) {
                    onAdd(ctrl.text);
                    ctrl.clear();
                  }
                }),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetField(String label, String hint, Color txt, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        style: TextStyle(color: txt, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: txt.withOpacity(0.7), fontWeight: FontWeight.w600),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

/// --- PREMIUM BUTTON WIDGETS ---
class PremiumButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const PremiumButton({required this.text, required this.color, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          shadowColor: color.withOpacity(0.3),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
      ),
    );
  }
}

class PremiumOutlineButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const PremiumOutlineButton({required this.text, required this.color, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
      ),
    );
  }
}

/// --- MULTISELECT DROPDOWN ---
class _MultiSelectDropdown extends StatelessWidget {
  final String title;
  final List<String> items;
  final UserProvider user;

  const _MultiSelectDropdown({required this.title, required this.items, required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final selected = user.isTagSelected(item);
            return ChoiceChip(
              label: Text(item, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black)),
              selected: selected,
              onSelected: (_) => user.toggleTag(item),
              selectedColor: AppColors.vibrantOrange,
              backgroundColor: Colors.grey.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// --- PANTRY + GENERATE MEAL SCREEN ---
class PantryGenerateScreen extends StatelessWidget {
  PantryGenerateScreen({super.key});
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Pantry"), backgroundColor: AppColors.vibrantBlue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: user.pantryItems
                    .map((t) => Chip(
                  label: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                  onDeleted: () => user.removePantryItem(t),
                  backgroundColor: AppColors.vibrantBlue.withOpacity(0.2),
                ))
                    .toList(),
              ),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Add item...",
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.vibrantBlue, size: 28),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      user.addPantryItem(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            PremiumButton(
              text: "Generate Meal",
              color: AppColors.vibrantGreen,
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Generate Meal clicked!")));
              },
            ),
          ],
        ),
      ),
    );
  }
}
