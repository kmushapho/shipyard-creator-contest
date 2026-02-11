import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

// ────────────────────────────────────────────────
//   Simple UserProvider – put this in providers/user_provider.dart
// ────────────────────────────────────────────────
class UserProvider with ChangeNotifier {
  String _name = "Kgothatso";
  bool _isPremium = false;
  bool _notificationsEnabled = true;
  String _units = "Metric"; // "Metric" or "Imperial"

  List<String> _dietaryPreferences = [];
  List<String> _ingredientsToAvoid = [];

  String get name => _name;
  bool get isPremium => _isPremium;
  bool get notificationsEnabled => _notificationsEnabled;
  String get units => _units;

  List<String> get dietaryPreferences => _dietaryPreferences;
  List<String> get ingredientsToAvoid => _ingredientsToAvoid;

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void setUnits(String value) {
    if (value == "Metric" || value == "Imperial") {
      _units = value;
      notifyListeners();
    }
  }

  void toggleDietaryPreference(String label) {
    if (_dietaryPreferences.contains(label)) {
      _dietaryPreferences.remove(label);
    } else {
      _dietaryPreferences.add(label);
    }
    notifyListeners();
  }

  void addIngredientToAvoid(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isNotEmpty && !_ingredientsToAvoid.contains(trimmed)) {
      _ingredientsToAvoid.add(trimmed);
      notifyListeners();
    }
  }

  void removeIngredientToAvoid(String ingredient) {
    _ingredientsToAvoid.remove(ingredient);
    notifyListeners();
  }

  // For demo / future login
  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }
}

// ────────────────────────────────────────────────
//   Profile Screen
// ────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);
    final user = Provider.of<UserProvider>(context);

    final accent = mode.accentColor;
    final textColor = mode.textColor;
    final bgColor = mode.bgColor;
    final cardColor = mode.cardColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User header ───────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: accent.withOpacity(0.18),
                  child: Icon(Icons.person_rounded, size: 46, color: accent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.isPremium ? "Premium Member" : "Free Account",
                        style: TextStyle(
                          fontSize: 14,
                          color: user.isPremium ? Colors.amber : textColor.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Premium upsell ────────────────────────────────────
            if (!user.isPremium)
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Upgrade screen – coming soon")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Symbols.crown, color: Colors.white, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "Go Premium",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Unlimited meal plans • No ads • Advanced filters • AI suggestions",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "Upgrade Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // ── Settings section ──────────────────────────────────
            _sectionHeader("Settings", textColor),
            _switchTile(
              icon: Icons.dark_mode_rounded,
              title: "Dark Mode",
              value: mode.isDark,
              onChanged: (_) => mode.toggleTheme(),
              accent: accent,
            ),
            _switchTile(
              icon: Icons.notifications_rounded,
              title: "Notifications",
              value: user.notificationsEnabled,
              onChanged: (_) => user.toggleNotifications(),
              accent: accent,
            ),
            _dropdownTile(
              icon: Icons.straighten_rounded,
              title: "Units",
              value: user.units,
              options: const ["Metric", "Imperial"],
              onChanged: (val) {
                if (val != null) user.setUnits(val);
              },
              accent: accent,
              textColor: textColor,
            ),

            const SizedBox(height: 32),

            // ── Dietary preferences ───────────────────────────────
            _sectionHeader("Dietary Preferences", textColor),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final label in [
                  "Vegan",
                  "Vegetarian",
                  "Pescatarian",
                  "Gluten-free",
                  "Dairy-free",
                  "Nut-free",
                  "Low-carb",
                  "Keto",
                  "Paleo",
                  "Halal",
                  "Kosher",
                ])
                  FilterChip(
                    label: Text(label),
                    selected: user.dietaryPreferences.contains(label),
                    onSelected: (_) => user.toggleDietaryPreference(label),
                    selectedColor: accent.withOpacity(0.25),
                    checkmarkColor: accent,
                    backgroundColor: cardColor,
                    labelStyle: TextStyle(color: textColor),
                    side: BorderSide(color: cardColor),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Avoid ingredients ─────────────────────────────────
            _sectionHeader("Ingredients to Avoid", textColor),
            if (user.ingredientsToAvoid.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "No ingredients added yet",
                  style: TextStyle(color: textColor.withOpacity(0.6)),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.ingredientsToAvoid
                    .map((ing) => Chip(
                  label: Text(ing),
                  backgroundColor: Colors.red.withOpacity(0.12),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => user.removeIngredientToAvoid(ing),
                  deleteIconColor: Colors.redAccent,
                  labelStyle: const TextStyle(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ))
                    .toList(),
              ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () => _showAddAvoidDialog(context, user),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text("Add Ingredient"),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent.withOpacity(0.7)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),

            const SizedBox(height: 48),

            // ── Logout ────────────────────────────────────────────
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: real logout logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Logged out")),
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text("Log Out", style: TextStyle(color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor.withOpacity(0.65),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color accent,
  }) {
    return ListTile(
      leading: Icon(icon, color: accent),
      title: Text(title),
      trailing: Switch(
        value: value,
        activeColor: accent,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _dropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required Color accent,
    required Color textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: accent),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        iconEnabledColor: accent,
        style: TextStyle(color: textColor),
        items: options.map((opt) {
          return DropdownMenuItem(value: opt, child: Text(opt));
        }).toList(),
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showAddAvoidDialog(BuildContext context, UserProvider user) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Ingredient to Avoid"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "e.g. peanuts, shellfish, avocado",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                user.addIngredientToAvoid(text);
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}