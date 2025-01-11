//lib\features\add_product\data\models\category.dart

import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int categoryId;
  final String categoryName;
  final int categoryCode;
  final String description;
  final int price;
  final String exfield1;
  final String? exfield2; // Nullable field
  final DateTime createDate;
  final DateTime modiDate;
  final String wholeseller;

  const Category({
    required this.categoryId,
    required this.categoryName,
    required this.categoryCode,
    required this.description,
    required this.price,
    required this.exfield1,
    this.exfield2,
    required this.createDate,
    required this.modiDate,
    required this.wholeseller,
  });

  // Factory constructor for JSON deserialization
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      categoryCode: json['categoryCode'] ?? 0,
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      exfield1: json['exfield1'] ?? '',
      exfield2: json['exfield2'],
      createDate: DateTime.parse(json['createDate']),
      modiDate: DateTime.parse(json['modiDate']),
      wholeseller: json['wholeseller'] ?? '',
    );
  }

  // Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryCode': categoryCode,
      'description': description,
      'price': price,
      'exfield1': exfield1,
      'exfield2': exfield2,
      'createDate': createDate.toIso8601String(),
      'modiDate': modiDate.toIso8601String(),
      'wholeseller': wholeseller,
    };
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        categoryCode,
        description,
        price,
        exfield1,
        exfield2,
        createDate,
        modiDate,
        wholeseller,
      ];
}
