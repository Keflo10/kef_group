enum TransactionType { income, expense }

class TransactionItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  /// quantity * unitPrice
  final double lineTotal;

  const TransactionItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      productId: (map['productId'] ?? '').toString(),
      productName: (map['productName'] ?? '').toString(),
      quantity: (map['quantity'] ?? 0) is int
          ? map['quantity']
          : int.tryParse((map['quantity'] ?? '0').toString()) ?? 0,
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      lineTotal: (map['lineTotal'] ?? 0.0).toDouble(),
    );
  }
}

class TransactionModel {
  final String id;
  final String userId;

  /// Backward compatibility fields (existing UI uses these)
  final String title;
  final String category;

  /// Keep a top-level amount for easy totals.
  /// For shop/MVP this equals sum(items.lineTotal).
  final double amount;

  final TransactionType type;
  final DateTime date;
  final String? note;

  /// Phase One (ShopLedger MVP) inventory requires line items.
  final List<TransactionItemModel> items;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type.name,
      'date': date.toIso8601String(),
      'note': note,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  factory TransactionModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    final itemsRaw = map['items'];
    final items = (itemsRaw is List)
        ? itemsRaw
            .whereType<Map<String, dynamic>>()
            .map((e) => TransactionItemModel.fromMap(e))
            .toList()
        : <TransactionItemModel>[];

    // If old documents exist (no items), compute amount from top-level.
    final amount = (map['amount'] ?? 0.0).toDouble();

    return TransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: (map['title'] ?? '').toString(),
      amount: amount,
      category: (map['category'] ?? 'General').toString(),
      type: map['type'] == 'income' || map['type'] == 'sale'
          ? TransactionType.income
          : TransactionType.expense,
      date: map['date'] != null
          ? DateTime.parse(map['date'].toString())
          : DateTime.now(),
      note: map['note'],
      items: items,
    );
  }
}
