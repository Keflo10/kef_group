import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/models/product_model.dart';
import 'package:sales_app/models/customer_model.dart';
import 'package:sales_app/models/transaction_model.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:sales_app/services/firestore_service.dart';

import 'package:sales_app/pages/admin/add_customer_screen.dart';
import 'package:sales_app/pages/admin/add_product_screen.dart';

class RecordSaleScreen extends StatefulWidget {
  const RecordSaleScreen({super.key});

  @override
  State<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _RecordSaleScreenState extends State<RecordSaleScreen> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedCustomerId;
  String? _selectedProductId;
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  String _paymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();

  List<CustomerModel> _customers = [];
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final shopId = _authService.currentUser?.uid ?? '';
    try {
      final userDoc = await _firestoreService.getUserData(shopId);
      final products = await _firestoreService.getProductsForShopOnce(shopId);
      final customersSnapshot =
          await _firestoreService.getCustomersForShop(shopId).first;

      setState(() {
        _products = products;
        _customers = customersSnapshot;
        if (userDoc.exists) {}
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product')));
      return;
    }

    final shopId = _authService.currentUser?.uid ?? '';
    final product = _products.firstWhere((p) => p.id == _selectedProductId);
    final quantity = int.parse(_quantityController.text);
    final price = double.parse(_priceController.text);

    if (product.stock < quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Not enough stock! Available: ${product.stock}')),
      );
      return;
    }

    final transaction = TransactionModel(
      id: '',
      userId: shopId,
      shopId: shopId,
      title: 'Sale: ${product.name}',
      amount: price * quantity,
      category: 'Sale',
      type: TransactionType.income,
      date: _selectedDate,
      note: 'Payment: $_paymentMethod',
      items: [
        TransactionItemModel(
          productId: product.id,
          productName: product.name,
          quantity: quantity,
          unitPrice: price,
          lineTotal: price * quantity,
        ),
      ],
    );

    try {
      await _firestoreService.addTransaction(transaction);

      // Update stock
      final newStock = product.stock - quantity;
      await _firestoreService.updateProductStock(product.id, newStock);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Record Sale'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Customer',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const AddCustomerScreen()))
                                      .then((_) => _loadData());
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('New'),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCustomerId,
                            decoration: InputDecoration(
                              hintText: 'Select Customer (Optional)',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text('Guest / Walk-in')),
                              ..._customers.map((c) => DropdownMenuItem(
                                  value: c.id, child: Text(c.name))),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedCustomerId = v),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Select Product',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const AddProductScreen()))
                                      .then((_) => _loadData());
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('New'),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedProductId,
                            decoration: InputDecoration(
                              hintText: 'Select Product',
                              prefixIcon:
                                  const Icon(Icons.shopping_bag_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            items: _products
                                .map((p) => DropdownMenuItem(
                                    value: p.id, child: Text(p.name)))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedProductId = v;
                                if (v != null) {
                                  _priceController.text = _products
                                      .firstWhere((p) => p.id == v)
                                      .price
                                      .toString();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Quantity',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _quantityController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: '1',
                                        prefixIcon: const Icon(
                                            Icons.format_list_numbered),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Price',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        prefixIcon:
                                            const Icon(Icons.attach_money),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('Payment Method',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _paymentMethod,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.payment_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            items: ['Cash', 'Mobile Money', 'Credit']
                                .map((m) =>
                                    DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _paymentMethod = v!),
                          ),
                          const SizedBox(height: 16),
                          const Text('Date',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                "${_selectedDate.toLocal()}".split(' ')[0]),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null)
                                setState(() => _selectedDate = date);
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _saveSale,
                            child: const Text('Complete Sale'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
