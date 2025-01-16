import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gehnaorg/features/add_product/data/models/subcategory.dart';

class SubCategoryRepository {
  final Dio dio;

  SubCategoryRepository(this.dio);

  Future<List<SubCategory>> fetchSubCategories({
    required int categoryId,
    required String? gender, // Changed from int? to String?
  }) async {
    try {
      // Fetch wholesalerId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final wholesalerId =
          prefs.getInt('wholesalerId'); // Assumes it's stored as an int

      if (wholesalerId == null) {
        throw Exception('Wholesaler ID not found in SharedPreferences');
      }

      // Construct the API URL
      final apiUrl =
          'https://upload-service-254137058023.asia-south1.run.app/upload/$wholesalerId/getSubCategories/$categoryId';

      // Build query parameters
      final queryParams = {
        if (gender != null) 'gender': gender, // Pass gender as String
      };

      // Make the API request
      final response = await dio.get(apiUrl, queryParameters: queryParams);

      if (response.statusCode == 200) {
        // Map response data to SubCategory model
        return (response.data as List)
            .map((json) => SubCategory.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch subcategories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching subcategories: $e');
    }
  }
}
