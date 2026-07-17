enum ProductCategory {
  general,
  groceries,
  transport,
  entertainment,
  shopping,
}

class ProductModel {
  final String id;
  final String shopId;

  final String name;
  final double price;
  final String category;
  final int stock;

  const ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.price,
    this.category = 'General',
    this.stock = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      shopId: (map['shopId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      price: (map['price'] ?? 0.0).toDouble(),
      category: (map['category'] ?? 'General').toString(),
      stock: int.tryParse(map['stock']?.toString() ?? '0') ?? 0,
    );
  }
}
