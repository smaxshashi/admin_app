import 'package:dio/dio.dart';
import 'package:gehnaorg/features/add_product/data/models/subcategory.dart';

class SubCategoryApi {
  final Dio _dio;

  SubCategoryApi(this._dio);

  Future<List<SubCategory>> getSubCategories({
    required int categoryCode,
    required int genderCode,
    required String wholeseller,
  }) async {
    try {
      final response = await _dio.get(
        'http://3.110.34.172:8080/api/subCategories/$categoryCode',
        queryParameters: {'genderCode': genderCode, 'wholeseller': wholeseller},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => SubCategory.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load subcategories');
      }
    } catch (e) {
      throw Exception('Error fetching subcategories: $e');
    }
  }
}
