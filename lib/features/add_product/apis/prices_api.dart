import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/prices.dart';


Future<List<MetalPrice>> fetchPrices() async {
   final prefs = await SharedPreferences.getInstance();
    final wholesalerId = prefs.getInt('wholesalerId');
    if (wholesalerId == null) {
      throw Exception('wholesalerId not found in shared preferences');
    }
  final response = await http.get(Uri.parse('https://upload-service-254137058023.asia-south1.run.app/upload/$wholesalerId/getMetalPrice'),
  headers: {
     'Accept': 'application/json'
  } );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => MetalPrice.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load prices');
  }
}
