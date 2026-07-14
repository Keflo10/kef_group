import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sales_app/models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of transactions for a user
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

      // Sort in-memory to avoid needing a Firestore composite index
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return transactions;
    });
  }

  // Add a transaction
  Future<void> addTransaction(TransactionModel transaction) {
    return _db.collection('transactions').add(transaction.toMap());
  }

  // Get user data
  Future<DocumentSnapshot> getUserData(String userId) {
    return _db.collection('users').doc(userId).get();
  }
}
