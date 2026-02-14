class ProductModel {
  final String id;
  final String name;
  final double price;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'isAvailable': isAvailable,
    };
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      isAvailable: map['isAvailable'] ?? true, // Default to true
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    bool? isAvailable,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
