class ProductUploadRequest {
  final String productName;
  final String description;
  final String wastage;
  final String weight;
  final String karat;
  final String categoryName;
  final String categoryId;
  final String subCategoryName;
  final String subCategoryId;
  final String tagNumber;
  final String length;
  final String size;
  final String wholesaler;
  final String wholesalerId;
  final String occasion;
  final String soulmate;
  final String gifting;
  final String gender;
  final String productType;

  ProductUploadRequest({
    required this.productName,
    required this.description,
    required this.wastage,
    required this.weight,
    required this.karat,
    required this.categoryName,
    required this.categoryId,
    required this.subCategoryName,
    required this.subCategoryId,
    required this.tagNumber,
    required this.length,
    required this.size,
    required this.wholesaler,
    required this.wholesalerId,
    required this.occasion,
    required this.soulmate,
    required this.gifting,
    required this.gender,
    required this.productType,
  });
}
