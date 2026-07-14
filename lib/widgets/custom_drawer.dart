import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:sales_app/wrapper.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String? email;
  final AuthService authService;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.email,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
            accountName: Text(userName.isEmpty ? "User" : userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(email ?? ""),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Profile"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Settings"),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Wrapper()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
