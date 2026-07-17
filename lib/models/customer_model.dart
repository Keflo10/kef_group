class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? address;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CustomerModel(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'],
    );
  }
}
