import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_app/models/transaction_model.dart';
import 'package:sales_app/models/product_model.dart';
import 'package:sales_app/models/customer_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of transactions for a shop (new schema).
  // Falls back to in-memory sorting; filtering is done by Firestore.
  Stream<List<TransactionModel>> getTransactionsForShop(String shopId) {
    debugPrint("Fetching transactions for shop: $shopId (Sorted in-memory)");
    return _db
        .collection('transactions')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort in-memory to keep consistent ordering.
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    });
  }

  // Products

  Stream<List<ProductModel>> getProductsForShop(String shopId) {
    return _db
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Loads products for a shop once (not a stream).
  Future<List<ProductModel>> getProductsForShopOnce(String shopId) async {
    final snapshot = await _db
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Creates or updates a product for a shop.
  Future<void> addOrUpdateProductForShop(
    String shopId,
    ProductModel product,
  ) async {
    final name = product.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('Product name is required');
    }

    if (product.id.isEmpty) {
      await _db.collection('products').add(product.toMap());
      return;
    }

    await _db.collection('products').doc(product.id).set(product.toMap());
  }

  /// Updates stock for a product.
  Future<void> updateProductStock(String productId, int newStock) async {
    await _db.collection('products').doc(productId).update({'stock': newStock});
  }

  // Customers

  Stream<List<CustomerModel>> getCustomersForShop(String shopId) {
    return _db
        .collection('customers')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addCustomer(String shopId, CustomerModel customer) async {
    final data = customer.toMap();
    data['shopId'] = shopId;
    await _db.collection('customers').add(data);
  }

  // Backward-compatible stream for legacy userId-based documents.
  Stream<List<TransactionModel>> getTransactions(String userId) {
    debugPrint("Fetching transactions for user: $userId (Sorted in-memory)");

    return _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();

      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    });
  }

  // Add a transaction
  Future<void> addTransaction(TransactionModel transaction) {
    return _db.collection('transactions').add(transaction.toMap());
  }

  // Update a transaction
  Future<void> updateTransaction(TransactionModel transaction) {
    return _db
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) {
    return _db.collection('transactions').doc(transactionId).delete();
  }

  // Get user data
  Future<DocumentSnapshot> getUserData(String userId) {
    return _db.collection('users').doc(userId).get();
  }

  Stream<DocumentSnapshot> getUserDataStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  Future<void> updateCurrency(String userId, String currency) {
    return _db.collection('users').doc(userId).update({'currency': currency});
  }
}
