import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/pages/home/home_screen.dart';
import 'package:sales_app/pages/lists/list_screen.dart';
import 'package:sales_app/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String? email;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(userName.isEmpty ? "User" : userName,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                )),
            accountEmail: Text(email ?? ""),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text("Home"),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const HomeScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashoard"),
            onTap: () {
              Navigator.pop(context);
              // Navigation to the dashboard can be
            },
          ),
          // const Divider(
          //   height: 0,
          //   // thickness: 1,
          //   // indent: 0,
          //   // endIndent: 0,
          //   color: Colors.grey,
          // ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("List"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TransactionListScreen()));
              // Navigation to the list  can be
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authService.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
