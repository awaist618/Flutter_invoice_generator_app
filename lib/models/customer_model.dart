import 'package:uuid/uuid.dart';

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final bool isFavorite;

  Customer({
    String? id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.isFavorite = false,
  }) : id = id ?? const Uuid().v4();

  Customer copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    bool? isFavorite,
  }) {
    return Customer(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'isFavorite': isFavorite,
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    address: json['address'],
    isFavorite: json['isFavorite'] ?? false,
  );
}
