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
  final TextEditingController _pantryController = TextEditingController();
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
      resizeToAvoidBottomInset: true, // Prevents keyboard layout crashes
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
            Text("Welcome, ${up.name}!", textAlign: TextAlign.center, style: TextStyle(color: txt, fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text("Ready to craft your perfect meals?", style: TextStyle(color: txt.withOpacity(0.7), fontSize: 18)),
            const SizedBox(height: 60),
            _largeBtn("Start Planning →", _nextPage, AppColors.vibrantOrange),
          ],
        ),
      ),
    );
  }

  // --- SCREEN 1: PROFILE ---
  Widget _screen1Profile(UserProvider up, bool isDark, Color txt) {
    return _pageWrapper(
      title: "Smart Profile",
      child: Column(
        children: [
          _buildDropdown("Dietary Preference", ["Vegan", "Keto", "Paleo", "Anything"], txt, isDark),
          const SizedBox(height: 24),
          _buildTagInput("Foods to Avoid", up.foodsToAvoid, _avoidController, up.addFoodToAvoid, up.removeFoodToAvoid, isDark, txt),
        ],
      ),
      footer: Column(
        children: [
          Text("Is everything correct?", style: TextStyle(color: txt.withOpacity(0.5))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _outlineBtn("✏️ Edit", () {}, txt)),
              const SizedBox(width: 12),
              Expanded(child: _largeBtn("✅ Confirm", _nextPage, AppColors.vibrantGreen)),
            ],
          )
        ],
      ),
    );
  }

  // --- SCREEN 2: GOALS ---
  Widget _screen2Goals(bool isDark, Color txt) {
    final goals = [
      {'t': 'Weight loss', 'i': '🔥'}, {'t': 'Muscle gain', 'i': '💪'},
      {'t': 'Energy & wellness', 'i': '⚡'}, {'t': 'Medical management', 'i': '🩺'},
    ];
    return _pageWrapper(
      title: "Goals in Motion",
      child: GridView.count(
        shrinkWrap: true, // FIXED: Required for layout inside SingleChildScrollView
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16,
        children: goals.map((g) => InkWell(
          onTap: () => setState(() => _selectedGoal = g['t']!),
          child: Container(
            decoration: BoxDecoration(
              color: _selectedGoal == g['t'] ? AppColors.vibrantOrange.withOpacity(0.1) : (isDark ? AppColors.cardBgDark : Colors.white),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _selectedGoal == g['t'] ? AppColors.vibrantOrange : Colors.transparent, width: 2),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(g['i']!, style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              Text(g['t']!, textAlign: TextAlign.center, style: TextStyle(color: txt, fontWeight: FontWeight.bold)),
            ]),
          ),
        )).toList(),
      ),
      footer: _largeBtn("Continue", _nextPage, AppColors.vibrantOrange),
    );
  }

  // --- SCREEN 3: FREQUENCY ---
  Widget _screen3Frequency(bool isDark, Color txt) {
    final meals = ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Dessert'];
    return _pageWrapper(
      title: "Meal Frequency",
      child: Column(
        children: meals.map((m) => Card(
          color: isDark ? AppColors.cardBgDark : Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: CheckboxListTile(
            title: Text(m, style: TextStyle(color: txt, fontWeight: FontWeight.w600)),
            value: _includedMeals.contains(m),
            activeColor: AppColors.vibrantOrange,
            onChanged: (val) => setState(() => val! ? _includedMeals.add(m) : _includedMeals.remove(m)),
          ),
        )).toList(),
      ),
      footer: _largeBtn("Set Schedule", _nextPage, AppColors.vibrantOrange),
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
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: 0.7, minHeight: 12, backgroundColor: Colors.grey.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation(AppColors.vibrantBlue)),
          ),
        ],
      ),
      footer: _largeBtn("Next", _nextPage, AppColors.vibrantOrange),
    );
  }

  // --- SCREEN 5: COOKING TIME ---
  Widget _screen5CookingTime(bool isDark, Color txt) {
    return _pageWrapper(
      title: "Cooking Time",
      child: Column(
        children: ['10–20 min', '20–40 min', '40+ min'].map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _outlineBtn(t, _nextPage, AppColors.vibrantGreen),
        )).toList(),
      ),
    );
  }

  // --- SCREEN 6: PANTRY & GEN ---
  Widget _screen6PantryAndGenerate(UserProvider up, bool isDark, Color txt) {
    return _pageWrapper(
      title: "Ready to Generate",
      child: Column(
        children: [
          _buildTagInput("Quick Pantry Add", up.pantryItems, _pantryController, up.addPantryItem, up.removePantryItem, isDark, txt),
        ],
      ),
      footer: Column(
        children: [
          _largeBtn("Add My Pantry & Generate →", () {}, AppColors.vibrantOrange),
          const SizedBox(height: 12),
          _outlineBtn("Generate Suggested Meals →", () {}, AppColors.vibrantOrange),
        ],
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
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.vibrantOrange)),
          const SizedBox(height: 24),
          Expanded(child: SingleChildScrollView(child: child)), // Child is now scrollable independently
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
          IconButton(onPressed: _prevPage, icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: txt)),
          Expanded(child: LinearProgressIndicator(value: _currentPage / 6, backgroundColor: txt.withOpacity(0.05), valueColor: const AlwaysStoppedAnimation(AppColors.vibrantOrange), borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 16),
          Text("Step $_currentPage/6", style: TextStyle(color: txt.withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTagInput(String label, List<String> tags, TextEditingController ctrl, Function(String) onAdd, Function(String) onRem, bool isDark, Color txt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: txt, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: tags.map((t) => Chip(
          label: Text(t), onDeleted: () => onRem(t),
          backgroundColor: AppColors.vibrantOrange.withOpacity(0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )).toList()),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          style: TextStyle(color: txt),
          decoration: InputDecoration(
            hintText: "Add item...",
            suffixIcon: IconButton(icon: const Icon(Icons.add_circle, color: AppColors.vibrantOrange), onPressed: () {
              if(ctrl.text.isNotEmpty) { onAdd(ctrl.text); ctrl.clear(); }
            }),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, Color txt, bool isDark) {
    return DropdownButtonFormField(
      decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: txt.withOpacity(0.5))),
      dropdownColor: isDark ? AppColors.cardBgDark : Colors.white,
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: TextStyle(color: txt)))).toList(),
      onChanged: (v) {},
    );
  }

  Widget _buildTargetField(String label, String hint, Color txt, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        style: TextStyle(color: txt),
        decoration: InputDecoration(
          labelText: label, hintText: hint, filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _largeBtn(String text, VoidCallback press, Color col) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: press,
      style: ElevatedButton.styleFrom(backgroundColor: col, elevation: 0, padding: const EdgeInsets.all(20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    ),
  );

  Widget _outlineBtn(String text, VoidCallback press, Color col) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: press,
      style: OutlinedButton.styleFrom(side: BorderSide(color: col, width: 2), padding: const EdgeInsets.all(20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      child: Text(text, style: TextStyle(color: col, fontWeight: FontWeight.w800)),
    ),
  );
}
