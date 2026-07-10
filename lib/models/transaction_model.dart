enum TransactionType { sale, expense }

class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? note;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type.name, // saves as 'sale' or 'expense'
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'General',
      type: map['type'] == 'sale'
          ? TransactionType.sale
          : TransactionType.expense,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      note: map['note'],
    );
  }
}
