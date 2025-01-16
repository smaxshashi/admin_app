import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int categoryId;
  final String categoryName;
  final String description;
  final int price;
  final String? exfield1; // Nullable field
  final String? exfield2; // Nullable field
  final DateTime createDate;
  final DateTime modiDate;
  final String imageUrl;
  final int wholesalerId;
  final int layoutPosition;
  final String wholesaler;

  const Category({
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.price,
    this.exfield1,
    this.exfield2,
    required this.createDate,
    required this.modiDate,
    required this.imageUrl,
    required this.wholesalerId,
    required this.layoutPosition,
    required this.wholesaler,
  });

  // Factory constructor for JSON deserialization
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      exfield1: json['exfield1'],
      exfield2: json['exfield2'],
      createDate: DateTime.parse(json['createDate']),
      modiDate: DateTime.parse(json['modiDate']),
      imageUrl: json['imageUrl'] ?? '',
      wholesalerId: json['wholesalerId'] ?? 0,
      layoutPosition: json['layoutPosition'] ?? 0,
      wholesaler: json['wholesaler'] ?? '',
    );
  }

  // Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
      'price': price,
      'exfield1': exfield1,
      'exfield2': exfield2,
      'createDate': createDate.toIso8601String(),
      'modiDate': modiDate.toIso8601String(),
      'imageUrl': imageUrl,
      'wholesalerId': wholesalerId,
      'layoutPosition': layoutPosition,
      'wholesaler': wholesaler,
    };
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        description,
        price,
        exfield1,
        exfield2,
        createDate,
        modiDate,
        imageUrl,
        wholesalerId,
        layoutPosition,
        wholesaler,
      ];
}
