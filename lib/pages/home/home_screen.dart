import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/models/customer_model.dart';
import 'package:sales_app/models/transaction_model.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:sales_app/services/firestore_service.dart';
import 'package:sales_app/core/widgets/app_drawer.dart';
import 'package:sales_app/core/widgets/transaction_tile.dart';
import 'package:sales_app/pages/transactions/add_transaction_screen.dart';
import 'package:sales_app/pages/transactions/record_sale_screen.dart';
import 'package:sales_app/pages/reports/reporting_screen.dart';
import 'package:sales_app/pages/lists/list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String _userName = "";
  String _currency = "UGX";
  double _totalBalance = 0.0;
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;

  // Prevent Firestore listener buildup
  StreamSubscription<List<TransactionModel>>? _transactionsSub;
  StreamSubscription<List<CustomerModel>>? _customersSub;
  StreamSubscription<DocumentSnapshot>? _userSub;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _transactionsSub?.cancel();
    _customersSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }

  double _todayIncome = 0.0;
  double _todayExpense = 0.0;
  int _totalCustomers = 0;

  void _loadData() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _userSub?.cancel();
    _userSub = _firestoreService.getUserDataStream(user.uid).listen((doc) {
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>?;
        setState(() {
          _userName = data?['name'] ?? "User";
          _currency = data?['currency'] ?? "UGX";
        });
      }
    });

    try {
      _customersSub?.cancel();
      _customersSub =
          _firestoreService.getCustomersForShop(user.uid).listen((customers) {
        if (mounted) setState(() => _totalCustomers = customers.length);
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }

    _transactionsSub?.cancel();
    _transactionsSub = _firestoreService.getTransactions(user.uid).listen(
      (transactions) {
        if (mounted) {
          double balance = 0;
          double todayIncome = 0;
          double todayExpense = 0;

          final now = DateTime.now();

          for (var t in transactions) {
            final isToday = t.date.year == now.year &&
                t.date.month == now.month &&
                t.date.day == now.day;

            if (t.type == TransactionType.income) {
              balance += t.amount;
              if (isToday) todayIncome += t.amount;
            } else {
              balance -= t.amount;
              if (isToday) todayExpense += t.amount;
            }
          }
          setState(() {
            _recentTransactions = transactions;
            _totalBalance = balance;
            _todayIncome = todayIncome;
            _todayExpense = todayExpense;
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
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                _loadData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Recent Transactions",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const TransactionListScreen()),
                            );
                          },
                          child: const Text("See all"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_recentTransactions.isEmpty)
                      const Center(child: Text("No transactions yet"))
                    else
                      Column(
                        children: _recentTransactions
                            .take(8)
                            .map((t) => Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AddTransactionScreen(
                                              transaction: t,
                                            ),
                                          ),
                                        );
                                      },
                                      child: TransactionTile(
                                        transaction: t,
                                        currency: _currency,
                                      ),
                                    ),
                                  ],
                                ))
                            .toList()
                          ..removeLast(),
                      ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                "Current Balance",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                "$_currency ${_totalBalance.toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          children: [
            _buildGridStatCard(
              "Today's Sales",
              _todayIncome,
              Icons.trending_up,
              AppColors.income,
            ),
            _buildGridStatCard(
              "Today's Expense",
              _todayExpense,
              Icons.trending_down,
              AppColors.expense,
            ),
            _buildGridStatCard(
              "Profit",
              _todayIncome - _todayExpense,
              Icons.account_balance_wallet,
              Colors.orange,
            ),
            _buildGridStatCard(
              "Total Customers",
              _totalCustomers.toDouble(),
              Icons.people,
              Colors.purple,
              isCurrency: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridStatCard(
      String label, double amount, IconData icon, Color color,
      {bool isCurrency = true}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              Icon(icon, color: color.withValues(alpha: 0.7), size: 16),
            ],
          ),
          Text(
            isCurrency
                ? "$_currency ${amount.toStringAsFixed(0)}"
                : amount.toInt().toString(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.blueGrey[800]),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _wideActionButton(
            "Record a Sale ", Icons.receipt_long, AppColors.income, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RecordSaleScreen()));
        }),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
                child: _actionButton(
                    "Quick Income",
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
        _wideActionButton("View Reports", Icons.bar_chart, AppColors.primary,
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
