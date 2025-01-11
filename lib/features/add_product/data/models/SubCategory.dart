import 'package:equatable/equatable.dart';

enum Description {
  GOLD_FEMALE_SUBCATEGORY,
  GOLD_MENS_SUBCATEGORY;

  factory Description.fromJson(String json) => Description.values.firstWhere(
      (e) => e.toString().split('.').last == json,
      orElse: () => Description
          .GOLD_FEMALE_SUBCATEGORY); // Defaulting to GOLD_FEMALE_SUBCATEGORY if not found

  String toJson() => toString().split('.').last;
}

enum Gender {
  MEN,
  WOMEN;

  factory Gender.fromJson(String json) =>
      Gender.values.firstWhere((e) => e.toString().split('.').last == json,
          orElse: () => Gender.MEN); // Defaulting to MEN

  String toJson() => toString().split('.').last;
}

enum Wholeseller {
  BANSAL;

  factory Wholeseller.fromJson(String json) =>
      Wholeseller.values.firstWhere((e) => e.toString().split('.').last == json,
          orElse: () => Wholeseller.BANSAL); // Defaulting to BANSAL

  String toJson() => toString().split('.').last;
}

class SubCategory extends Equatable {
  const SubCategory({
    required this.subcategoryId,
    required this.subcategoryName,
    required this.subcategoryCode,
    required this.categoryCode,
    required this.description,
    required this.price,
    required this.exfield1,
    this.exfield2,
    required this.gender,
    required this.genderCode,
    required this.createDate,
    required this.modiDate,
    required this.wholeseller,
  });

  // Factory constructor for JSON deserialization
  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subcategoryId: json['subcategoryId'] ?? 0,
      subcategoryName: json['subcategoryName'] ?? '',
      subcategoryCode: json['subcategoryCode'] ?? 0,
      categoryCode: json['categoryCode'] ?? 0,
      description: Description.fromJson(json['description'] ?? ''),
      price: json['price'] ?? 0,
      exfield1: json['exfield1'] ?? '',
      exfield2: json['exfield2'],
      gender: Gender.fromJson(json['gender'] ?? ''),
      genderCode: json['genderCode'] ?? 0,
      createDate: DateTime.parse(json['createDate']),
      modiDate: DateTime.parse(json['modiDate']),
      wholeseller: Wholeseller.fromJson(json['wholeseller'] ?? ''),
    );
  }

  final int categoryCode;
  final DateTime createDate;
  final Description description;
  final String exfield1;
  final String? exfield2; // Nullable field
  final Gender gender;
  final int genderCode;
  final DateTime modiDate;
  final int price;
  final int subcategoryCode;
  final int subcategoryId;
  final String subcategoryName;
  final Wholeseller wholeseller;

  @override
  List<Object?> get props => [
        subcategoryId,
        subcategoryName,
        subcategoryCode,
        categoryCode,
        description,
        price,
        exfield1,
        exfield2,
        gender,
        genderCode,
        createDate,
        modiDate,
        wholeseller,
      ];

  // Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'subcategoryCode': subcategoryCode,
      'categoryCode': categoryCode,
      'description': description.toJson(),
      'price': price,
      'exfield1': exfield1,
      'exfield2': exfield2,
      'gender': gender.toJson(),
      'genderCode': genderCode,
      'createDate': createDate.toIso8601String(),
      'modiDate': modiDate.toIso8601String(),
      'wholeseller': wholeseller.toJson(),
    };
  }
}
