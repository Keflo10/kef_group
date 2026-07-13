import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sales_app/core/utils/greeting_util.dart';
import 'package:sales_app/core/widgets/custom_drawer.dart';
import 'package:sales_app/models/transaction_model.dart';
import 'package:currency_picker/currency_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  String _userName = "";

  List<TransactionModel> _recentTransactions = [];
  double _totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTransactions();
  }

  void _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userName = doc.data()?['name'] ?? "";
        });
      }
    }
  }

  void _loadTransactions() {
    final user = _authService.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .limit(10)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          double balance = 0;
          final transactions = snapshot.docs.map((doc) {
            final t = TransactionModel.fromMap(doc.data(), doc.id);
            if (t.type == TransactionType.sale) {
              balance += t.amount;
            } else {
              balance -= t.amount;
            }
            return t;
          }).toList();

          setState(() {
            _recentTransactions = transactions;
            _totalBalance = balance;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: CustomDrawer(
        userName: _userName,
        email: _authService.currentUser?.email,
        authService: _authService,
      ),
      body: Column(
        children: [
          // Header on the blue background
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName.isEmpty
                        ? getGreeting()
                        : "${getGreeting()}\n${_userName.split(' ')[0]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),

          // White content fills the remaining space
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Balance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "UGX ${_totalBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              // Navigate to Add Income
                            },
                            child: _quickActionButton(
                              "Add Income",
                              Icons.add_circle_outline,
                              AppColors.income,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              // Navigate to Add Expense
                            },
                            child: _quickActionButton(
                              "Add Expense",
                              Icons.shopping_bag_outlined,
                              AppColors.expense,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    InkWell(
                      onTap: () {
                        // Navigate to Report or list
                      },
                      child: _wideActionButton(
                        "View Report",
                        Icons.bar_chart_rounded,
                        AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Transactions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_recentTransactions.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() => _selectedIndex = 1);
                            },
                            child: const Text("See All"),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(),

                    if (_recentTransactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            "No transactions yet",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._recentTransactions
                          .map((t) => _transactionItem(t))
                          .toList(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          onPressed: () {
            //
          },
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 35),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 70,
        notchMargin: 10,
        color: AppColors.white,
        elevation: 20,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () => setState(() => _selectedIndex = 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home,
                    color:
                        _selectedIndex == 0 ? AppColors.primary : Colors.grey,
                  ),
                  Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          _selectedIndex == 0 ? AppColors.primary : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            InkWell(
              onTap: () => setState(() => _selectedIndex = 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.list_alt,
                    color:
                        _selectedIndex == 1 ? AppColors.primary : Colors.grey,
                  ),
                  Text(
                    "List",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          _selectedIndex == 1 ? AppColors.primary : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideActionButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _transactionItem(TransactionModel transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isExpense
                      ? AppColors.expense.withOpacity(0.1)
                      : AppColors.income.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isExpense
                      ? Icons.shopping_cart_outlined
                      : Icons.account_balance_wallet_outlined,
                  color: isExpense ? AppColors.expense : AppColors.income,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatDate(transaction.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: isExpense ? AppColors.expense : AppColors.income,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _formatDate(transaction.date),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Today';
    if (checkDate == yesterday) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
