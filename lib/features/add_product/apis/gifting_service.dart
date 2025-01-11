import 'dart:convert';
import 'package:http/http.dart' as http;

class GiftingService {
  Future<List<String>> fetchGiftingOptions() async {
    final response = await http.get(
      Uri.parse('https://api.gehnamall.com/api/gifting'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      
      // Extract only giftingName for the dropdown
      return data.map((item) => item['giftingName'].toString()).toList();
    } else {
      throw Exception('Failed to load gifting options');
    }
  }
}
