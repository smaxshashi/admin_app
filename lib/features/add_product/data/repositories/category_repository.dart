//lib\features\add_product\data\repositories\category_repository.dart

import 'package:dio/dio.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';

class CategoryRepository {
  final Dio dio;

  CategoryRepository(this.dio);

  Future<List<Category>> fetchCategories(String wholeseller) async {
    final response = await dio.get(
        'http://3.110.34.172:8080/api/categories?wholeseller=$wholeseller');
    return (response.data as List).map((e) => Category.fromJson(e)).toList();
  }
}
