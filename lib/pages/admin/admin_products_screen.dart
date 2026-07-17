import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/models/product_model.dart';
import 'package:sales_app/services/auth_service.dart';
import 'package:sales_app/services/firestore_service.dart';
import 'package:sales_app/pages/admin/add_product_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
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
        title: const Text('Products'),
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
                    return const Center(child: Text('No products found'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.shopping_bag, color: AppColors.primary),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${product.category} • $_currency ${product.price.toStringAsFixed(0)}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddProductScreen(product: product)),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
