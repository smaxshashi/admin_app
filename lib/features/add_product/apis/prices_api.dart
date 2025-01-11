import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/models/prices.dart';


Future<List<MetalPrice>> fetchPrices() async {
  final response = await http.get(Uri.parse('https://api.gehnamall.com/api/prices'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => MetalPrice.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load prices');
  }
}
