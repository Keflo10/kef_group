import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/models/transaction_model.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:sales_app/services/firestore_service.dart';
import 'package:sales_app/widgets/bottom_nav_bar.dart';
import 'package:sales_app/widgets/app_drawer.dart';
import 'package:sales_app/widgets/transaction_tile.dart';
import 'package:sales_app/pages/transactions/add_transaction_screen.dart';
import 'package:sales_app/pages/reports/reporting_screen.dart';
import 'package:sales_app/core/utils/greeting_util.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String _userName = "";
  double _totalBalance = 0.0;
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestoreService.getUserData(user.uid);
        if (userDoc.exists && mounted) {
          setState(() => _userName = userDoc.get('name') ?? "User");
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
      }

      _firestoreService.getTransactions(user.uid).listen(
        (transactions) {
          if (mounted) {
            double balance = 0;
            for (var t in transactions) {
              balance +=
                  (t.type == TransactionType.income ? t.amount : -t.amount);
            }
            setState(() {
              _recentTransactions = transactions;
              _totalBalance = balance;
              _isLoading = false;
            });
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
        },
      );
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 60),
          child: Text(
              "Hello ${_userName.isEmpty ? "User" : _userName.split(' ')[0]}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
              )),
        ),
      ),
      drawer: AppDrawer(
        userName: _userName,
        email: _authService.currentUser?.email,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Current Balance",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildBalanceCard(),
                    const SizedBox(height: 30),
                    const Text("Quick Actions",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildQuickActions(),
                    const SizedBox(height: 30),
                    const Text("Recent Transactions",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_recentTransactions.isEmpty)
                      const Center(child: Text("No transactions yet"))
                    else
                      ..._recentTransactions
                          .take(5)
                          .map((t) => TransactionTile(transaction: t)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReportingScreen()));
          }
        },
        onFabTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          "ugx ${_totalBalance.toStringAsFixed(2)}",
          style: const TextStyle(
              color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _actionButton(
                    "Add Income",
                    Icons.add_circle_outline,
                    AppColors.income,
                    () => _navigateToAdd(TransactionType.income))),
            const SizedBox(width: 15),
            Expanded(
                child: _actionButton(
                    "Add Expense",
                    Icons.shopping_bag_outlined,
                    AppColors.expense,
                    () => _navigateToAdd(TransactionType.expense))),
          ],
        ),
        const SizedBox(height: 15),
        _wideActionButton("View Report", Icons.bar_chart, AppColors.primary,
            () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ReportingScreen()));
        }),
      ],
    );
  }

  void _navigateToAdd(TransactionType type) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddTransactionScreen(initialType: type)));
  }

  Widget _actionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _wideActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 15),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
