import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/pages/home/home_screen.dart';
import 'package:sales_app/pages/lists/list_screen.dart';
import 'package:sales_app/pages/lists/customers_screen.dart';
import 'package:sales_app/pages/admin/admin_products_screen.dart';
import 'package:sales_app/pages/settings/settings_screen.dart';
import 'package:sales_app/pages/reports/reporting_screen.dart';
import 'package:sales_app/pages/transactions/record_sale_screen.dart';
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
            leading: const Icon(Icons.home_outlined, color: AppColors.primary),
            title: const Text("Home"),
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined,
                color: AppColors.primary),
            title: const Text("Products"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminProductsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined,
                color: AppColors.primary),
            title: const Text("Sales"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RecordSaleScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline, color: AppColors.primary),
            title: const Text("Customers"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CustomersScreen())),
          ),
          ListTile(
            leading:
                const Icon(Icons.history_outlined, color: AppColors.primary),
            title: const Text("Transactions"),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TransactionListScreen())),
          ),
          ListTile(
            leading:
                const Icon(Icons.bar_chart_outlined, color: AppColors.primary),
            title: const Text("Reports"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReportingScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined,
                color: AppColors.primary),
            title: const Text("Notifications"),
            onTap: () {},
          ),
          ListTile(
            leading:
                const Icon(Icons.settings_outlined, color: AppColors.primary),
            title: const Text("Settings"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
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
