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

    return Scaffold(
      backgroundColor: mode.bgColor,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: mode.cardColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: mode.accentColor.withOpacity(0.2),
              child: Icon(Icons.person, size: 50, color: mode.accentColor),
            ),
            const SizedBox(height: 16),

            Text(
              user.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: mode.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              user.isGuest ? "Guest User" : "Logged In User",
              style: TextStyle(color: mode.textSecondary),
            ),

            const SizedBox(height: 32),

            SwitchListTile(
              title: const Text("Dark Mode"),
              value: mode.isDark,
              onChanged: (_) => mode.toggleTheme(),
            ),

            const Spacer(),

            if (user.isGuest)
              ElevatedButton(
                onPressed: () {
                  user.login(uid: "123", name: "Kgothatso", isPremium: false);
                },
                child: const Text("Simulate Login"),
              )
            else
              ElevatedButton(
                onPressed: () {
                  user.logoutToGuest();
                },
                child: const Text("Log out to Guest"),
              ),
          ],
        ),
      ),
    );
  }
}
