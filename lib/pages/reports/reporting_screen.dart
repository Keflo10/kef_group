import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/models/transaction_model.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:sales_app/services/firestore_service.dart';
import 'package:sales_app/pages/reports/reporting_widget.dart';
// import 'package:sales_app/core/widgets/bottom_nav_bar.dart';
// import 'package:sales_app/pages/transactions/add_transaction_screen.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String _currency = 'UGX';

  // Prevent Firestore listener buildup
  StreamSubscription<List<TransactionModel>>? _transactionsSub;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _transactionsSub?.cancel();
    super.dispose();
  }

  void _fetchData() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final userDoc = await _firestoreService.getUserData(user.uid);
      if (userDoc.exists && mounted) {
        final data = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          _currency = data?['currency'] ?? "UGX";
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }

    _transactionsSub?.cancel();
    _transactionsSub = _firestoreService.getTransactions(user.uid).listen(
      (transactions) {
        if (mounted) {
          setState(() {
            _transactions = transactions;
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
        title: const Text('Reports',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: ReportingWidget(
        transactions: _transactions,
        isLoading: _isLoading,
        currency: _currency,
      ),
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: 1,
      //   onTap: (index) {
      //     if (index == 0) {
      //       Navigator.pop(context);
      //     }
      //   },
      //   onFabTap: () => Navigator.push(context,
      //       MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
      // ),
    );
  }
}
