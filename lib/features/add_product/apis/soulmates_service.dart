import 'dart:convert';
import 'package:http/http.dart' as http;

class SoulmateService {
  Future<List<String>> fetchSoulmateOptions() async {
    final response = await http.get(
      Uri.parse('https://api.gehnamall.com/api/soulmate'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Soulmate API Response: $data'); // Debugging purposes

      // Extract soulmateName field (replace with the correct key)
      return data.map((item) => item['giftingName'].toString()).toList();
    } else {
      throw Exception('Failed to load soulmate options');
    }
  } 
}
