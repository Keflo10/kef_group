import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:sales_app/services/firestore_service.dart';
import 'package:currency_picker/currency_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String _currentCurrency = 'UGX';

  @override
  void initState() {
    super.initState();
    _loadUserCurrency();
  }

  void _loadUserCurrency() async {
    final user = _authService.currentUser;
    if (user != null) {
      final doc = await _firestoreService.getUserData(user.uid);
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>?;
        setState(() {
          _currentCurrency = data?['currency'] ?? 'UGX';
        });
      }
    }
  }

  void _showCurrencyPicker() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) async {
        final user = _authService.currentUser;
        if (user != null) {
          await _firestoreService.updateCurrency(user.uid, currency.code);
          setState(() {
            _currentCurrency = currency.code;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Currency updated to ${currency.name}')),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            user?.email ?? 'User',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSettingItem(Icons.person_outline, 'Edit Profile'),
                  _buildSettingItem(Icons.lock_outline, 'Change Password'),
                  _buildSettingItem(
                    Icons.currency_exchange, 
                    'Currency', 
                    subtitle: _currentCurrency,
                    onTap: _showCurrencyPicker,
                  ),
                  _buildSettingItem(Icons.notifications_outlined, 'Notifications'),
                  _buildSettingItem(Icons.backup_outlined, 'Backup Data'),
                  _buildSettingItem(Icons.info_outline, 'About App'),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      await _authService.signOut();
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    );
  }
}
