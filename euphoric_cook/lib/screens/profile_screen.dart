import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ModeProvider>();
    final user = context.watch<UserProvider>();

    final accent = mode.accentColor;
    final textColor = mode.textPrimary;
    final cardColor = mode.cardColor;
    final bgColor = mode.bgColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── USER HEADER ───────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: accent.withOpacity(0.15),
                  child: Icon(Icons.person, color: accent, size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    Text(
                      user.isGuest ? "Sign in to sync your data" : "Logged in",
                      style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.6)),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ─── PREMIUM CARD ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Euphoric Cook Premium",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    "Unlimited meal plans, no ads, advanced features & more",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 14),
                  Center(
                    child: Text("Upgrade Now",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            _section("Preferences"),
            _tile(icon: Icons.dark_mode, title: "Switch to Dark Mode", trailing: Switch(
              value: mode.isDark,
              onChanged: (_) => mode.toggleTheme(),
              activeColor: accent,
            )),

            _tile(icon: Icons.notifications, title: "Notifications"),

            _tile(icon: Icons.straighten, title: "Units: Metric"),

            const SizedBox(height: 20),

            _section("Dietary Restrictions"),
            _multiSelectDropdown(context, "Dietary Restrictions", [
              "Vegetarian",
              "Vegan",
              "Gluten-Free",
              "Dairy-Free",
              "Kosher",
              "Halal",
              "Paleo",
              "Pescatarian",
            ]),

            const SizedBox(height: 20),

            _section("Nutritional & Health Tags"),
            _multiSelectDropdown(context, "Nutritional & Health Tags", [
              "Healthy",
              "Low Calorie",
              "Low Carb",
              "Low Fat",
              "Low Sodium",
              "Low Sugar",
              "Low Cholesterol",
              "High Fiber",
              "Kidney Friendly",
            ]),

            const SizedBox(height: 20),

            _section("Allergy-Specific Tags"),
            _multiSelectDropdown(context, "Allergy-Specific Tags", [
              "Peanut Free",
              "Soy Free",
              "Tree Nut Free",
              "Shellfish Free",
            ]),

            const SizedBox(height: 24),

            _section("Foods to Avoid"),
            Wrap(
              spacing: 10,
              children: user.foodsToAvoid.map((f) => Chip(
                label: Text(f),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () => user.removeFoodToAvoid(f),
              )).toList(),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _showAddFoodDialog(context, user),
              icon: const Icon(Icons.add),
              label: const Text("Add food to avoid"),
            ),

            const SizedBox(height: 30),

            if (!user.isGuest)
              Center(
                child: OutlinedButton.icon(
                  onPressed: user.logoutToGuest,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text("Log Out", style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }

  Widget _tile({required IconData icon, required String title, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _multiSelectDropdown(BuildContext context, String title, List<String> items) {
    return ExpansionTile(
      title: Text(title),
      children: items.map((item) {
        return CheckboxListTile(
          title: Text(item),
          value: context.read<UserProvider>().isTagSelected(item),
          onChanged: (_) => context.read<UserProvider>().toggleTag(item),
        );
      }).toList(),
    );
  }

  void _showAddFoodDialog(BuildContext context, UserProvider user) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Food to Avoid"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "e.g. peanuts"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              user.addFoodToAvoid(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
