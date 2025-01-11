import 'dart:convert';
import 'package:http/http.dart' as http;

class LightCategoriesService {
  Future<List<Map<String, dynamic>>> fetchLightCategories() async {
    final response = await http.get(
      Uri.parse('https://api.gehnamall.com/api/lightCategories?wholeseller=BANSAL'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('API Response: $data'); // Debugging purposes

      // Convert to list of Map
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load light categories');
    }
  }
}
  