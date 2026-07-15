import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/models/transaction_model.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:sales_app/services/firestore_service.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType initialType;
  const AddTransactionScreen(
      {super.key, this.initialType = TransactionType.expense});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  late TransactionType _type;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Groceries',
      'icon': Icons.shopping_cart,
      'type': TransactionType.expense
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_bus,
      'type': TransactionType.expense
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'type': TransactionType.expense
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'type': TransactionType.expense
    },
    {
      'name': 'Salary',
      'icon': Icons.account_balance_wallet,
      'type': TransactionType.income
    },
    {
      'name': 'Sales',
      'icon': Icons.account_balance_wallet,
      'type': TransactionType.income
    },
    {
      'name': 'Netflix',
      'icon': Icons.subscriptions,
      'type': TransactionType.expense
    },
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final user = _authService.currentUser;
      if (user == null) return;

      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final transaction = TransactionModel(
        id: '',
        userId: user.uid,
        title: _selectedCategory ?? "Transaction",
        amount: amount,
        category: _selectedCategory ?? "Other",
        type: _type,
        date: _selectedDate,
        note: _noteController.text,
        // Backward compatible: treat the old single-amount entry as one line item.
        items: [
          TransactionItemModel(
            productId: 'legacy',
            productName: _selectedCategory ?? 'Transaction',
            quantity: 1,
            unitPrice: amount,
            lineTotal: amount,
          ),
        ],
      );

      try {
        await _firestoreService.addTransaction(transaction);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
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
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: const Text("Add Transaction",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Category"),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 20),
                      _buildLabel("Amount"),
                      _buildAmountField(),
                      const SizedBox(height: 20),
                      _buildLabel("Date"),
                      _buildDateField(),
                      const SizedBox(height: 20),
                      _buildLabel("Note"),
                      _buildNoteField(),
                      const SizedBox(height: 40),
                      const Divider(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Save",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCategoryDropdown() {
    final filteredCategories =
        _categories.where((cat) => cat['type'] == _type).toList();

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      hint: const Text("Select Category"),
      decoration: InputDecoration(
        prefixIcon: Icon(
          _selectedCategory != null
              ? _categories
                  .firstWhere((cat) => cat['name'] == _selectedCategory)['icon']
              : Icons.folder_open,
          color: Colors.grey.shade600,
        ),
        suffixIcon: Icon(Icons.chevron_right, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: filteredCategories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat['name'],
          child: Text(cat['name']),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedCategory = val;
        });
      },
      validator: (val) => val == null ? "Required" : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        prefixText: "\$ ",
        hintText: "0.00",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return "Required";
        if (double.tryParse(val) == null) return "Invalid number";
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.black54),
            const SizedBox(width: 10),
            Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
            const Spacer(),
            const Icon(Icons.calendar_month_outlined, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "Add a note",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}
