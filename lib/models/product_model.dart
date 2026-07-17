import 'package:uuid/uuid.dart';

class Product {
  final String id;
  final String name;
  final double unitPrice;
  final String description;

  Product({
    String? id,
    required this.name,
    required this.unitPrice,
    this.description = '',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unitPrice': unitPrice,
    'description': description,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    unitPrice: (json['unitPrice'] as num).toDouble(),
    description: json['description'] ?? '',
  );
}
