import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';

class CategoryRepository {
  final Dio dio;

  CategoryRepository(this.dio);

  Future<List<Category>> fetchCategories({
    required int layoutPosition,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wholesalerId = prefs.getInt('wholesalerId');
      if (wholesalerId == null) {
        throw Exception('wholesalerId not found in shared preferences');
      }

      // Make the API call with adminId
      final response = await dio.get(
        'https://upload-service-254137058023.asia-south1.run.app/upload/$wholesalerId/getCategory',
        queryParameters: {
          'layoutPosition': layoutPosition,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => Category.fromJson(e))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch categories: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}