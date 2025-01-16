import 'dart:convert';

List<SubCategory> subCategoryFromJson(String str) => List<SubCategory>.from(
    json.decode(str).map((x) => SubCategory.fromJson(x)));

String subCategoryToJson(List<SubCategory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SubCategory {
  final int subcategoryId;
  final String subCategoryName;
  final int categoryId;
  final dynamic categoryName;
  final String description;
  final int price;
  final dynamic exfield1;
  final dynamic exfield2;
  final String gender;
  final dynamic imageUrl;
  final DateTime createDate;
  final DateTime modiDate;
  final String wholesalerName;
  final int wholesalerId;
  final dynamic subCategoryType;

  SubCategory({
    required this.subcategoryId,
    required this.subCategoryName,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.price,
    required this.exfield1,
    required this.exfield2,
    required this.gender,
    required this.imageUrl,
    required this.createDate,
    required this.modiDate,
    required this.wholesalerName,
    required this.wholesalerId,
    required this.subCategoryType,
  });

  SubCategory copyWith({
    int? subcategoryId,
    String? subCategoryName,
    int? categoryId,
    dynamic categoryName,
    String? description,
    int? price,
    dynamic exfield1,
    dynamic exfield2,
    String? gender,
    dynamic imageUrl,
    DateTime? createDate,
    DateTime? modiDate,
    String? wholesalerName,
    int? wholesalerId,
    dynamic subCategoryType,
  }) =>
      SubCategory(
        subcategoryId: subcategoryId ?? this.subcategoryId,
        subCategoryName: subCategoryName ?? this.subCategoryName,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        description: description ?? this.description,
        price: price ?? this.price,
        exfield1: exfield1 ?? this.exfield1,
        exfield2: exfield2 ?? this.exfield2,
        gender: gender ?? this.gender,
        imageUrl: imageUrl ?? this.imageUrl,
        createDate: createDate ?? this.createDate,
        modiDate: modiDate ?? this.modiDate,
        wholesalerName: wholesalerName ?? this.wholesalerName,
        wholesalerId: wholesalerId ?? this.wholesalerId,
        subCategoryType: subCategoryType ?? this.subCategoryType,
      );

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
        subcategoryId: json["subcategoryId"],
        subCategoryName: json["subCategoryName"],
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
        description: json["description"],
        price: json["price"],
        exfield1: json["exfield1"],
        exfield2: json["exfield2"],
        gender: json["gender"],
        imageUrl: json["imageUrl"],
        createDate: DateTime.parse(json["createDate"]),
        modiDate: DateTime.parse(json["modiDate"]),
        wholesalerName: json["wholesalerName"],
        wholesalerId: json["wholesalerId"],
        subCategoryType: json["subCategoryType"],
      );

  Map<String, dynamic> toJson() => {
        "subcategoryId": subcategoryId,
        "subCategoryName": subCategoryName,
        "categoryId": categoryId,
        "categoryName": categoryName,
        "description": description,
        "price": price,
        "exfield1": exfield1,
        "exfield2": exfield2,
        "gender": gender,
        "imageUrl": imageUrl,
        "createDate": createDate.toIso8601String(),
        "modiDate": modiDate.toIso8601String(),
        "wholesalerName": wholesalerName,
        "wholesalerId": wholesalerId,
        "subCategoryType": subCategoryType,
      };
}
