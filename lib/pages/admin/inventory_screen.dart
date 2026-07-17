import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/models/product_model.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:sales_app/services/firestore_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String _currency = 'UGX';
  StreamSubscription<DocumentSnapshot>? _userSub;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  void _loadCurrency() {
    final user = _authService.currentUser;
    if (user != null) {
      _userSub?.cancel();
      _userSub = _firestoreService.getUserDataStream(user.uid).listen((doc) {
        if (doc.exists && mounted) {
          final data = doc.data() as Map<String, dynamic>?;
          setState(() {
            _currency = data?['currency'] ?? "UGX";
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
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
              child: StreamBuilder<List<ProductModel>>(
                stream: _firestoreService.getProductsForShop(shopId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final products = snapshot.data ?? [];
                  if (products.isEmpty) {
                    return const Center(child: Text('No products in inventory'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final bool isLowStock = product.stock <= 5;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isLowStock ? Colors.red[50] : Colors.grey[100],
                            child: Icon(
                              Icons.inventory_2_outlined, 
                              color: isLowStock ? Colors.red : AppColors.primary
                            ),
                          ),
                          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${product.category} • $_currency ${product.price.toStringAsFixed(0)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${product.stock}',
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: isLowStock ? Colors.red : Colors.black
                                ),
                              ),
                              Text(
                                isLowStock ? 'Low Stock' : 'In Stock',
                                style: TextStyle(fontSize: 10, color: isLowStock ? Colors.red : Colors.green),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
