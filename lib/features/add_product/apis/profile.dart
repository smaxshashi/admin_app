import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/models/profile.dart';

Future<List<User>> fetchUsers(String token) async {
  const url = 'https://user-service-254137058023.asia-south1.run.app/user/wholesaler/getLoginUser';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token', // Add the token in the Authorization header
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => User.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}
