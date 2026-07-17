import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/models/transaction_model.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:sales_app/services/firestore_service.dart';
import 'package:sales_app/core/widgets/app_drawer.dart';
import 'package:sales_app/core/widgets/transaction_tile.dart';
import 'package:sales_app/pages/lists/widgets/transaction_search_widget.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String _userName = "";
  String _currency = "UGX";
  bool _isLoading = true;
  List<TransactionModel> _transactions = [];

  // --- Search State ---
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  StreamSubscription<List<TransactionModel>>? _transactionsSub;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _transactionsSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await _firestoreService.getUserData(user.uid);
      if (userDoc.exists && mounted) {
        final data = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          _userName = data?['name'] ?? "User";
          _currency = data?['currency'] ?? "UGX";
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }

    _transactionsSub?.cancel();
    _transactionsSub = _firestoreService.getTransactions(user.uid).listen(
      (transactions) {
        if (!mounted) return;
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      },
    );
  }

  // ---Here is Filter Logic ---
  List<TransactionModel> get _filteredTransactions {
    if (_searchQuery.isEmpty) return _transactions;

    final query = _searchQuery.toLowerCase();
    return _transactions.where((transaction) {
      final noteMatch =
          transaction.note?.toLowerCase().contains(query) ?? false;
      final titleMatch = transaction.title.toLowerCase().contains(query);
      final categoryMatch = transaction.category.toLowerCase().contains(query);

      final amountMatch =
          transaction.amount.toString().toLowerCase().contains(query);

      return noteMatch || titleMatch || categoryMatch || amountMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedTransactions = _filteredTransactions;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TransactionSearchWidget(
          isSearching: _isSearching,
          searchController: _searchController,
          onQueryChanged: (value) {
            setState(() => _searchQuery = value);
          },
          onStartSearching: () {
            setState(() => _isSearching = true);
          },
          onClearSearch: () {
            _searchController.clear();
            setState(() => _searchQuery = "");
          },
          onBackPressedWhenSearching: () {
            setState(() {
              _isSearching = false;
              _searchQuery = "";
              _searchController.clear();
            });
          },
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
                  topRight: Radius.circular(30),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayedTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          itemCount: displayedTransactions.length,
                          itemBuilder: (context, index) {
                            return TransactionTile(
                              transaction: displayedTransactions[index],
                              currency: _currency,
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
