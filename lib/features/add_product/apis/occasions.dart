import 'dart:convert';
import 'package:http/http.dart' as http;

class OccasionService {
  Future<List<String>> fetchOccasionOptions() async {
    final response = await http.get(
      Uri.parse('https://api.gehnamall.com/api/occasion'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('API Response: $data'); // Debugging purposes

      // Extract giftingName field
      return data.map((item) => item['giftingName'].toString()).toList();
    } else {
      throw Exception('Failed to load occasion options');
    }
  }
}

