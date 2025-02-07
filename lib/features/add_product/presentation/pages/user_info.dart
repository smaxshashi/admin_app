import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/constants.dart';
import '../bloc/login_bloc.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({Key? key}) : super(key: key);

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  List<dynamic> _userResponses = [];
  bool _isLoading = true;
  String _errorMessage = "";

  Future<void> _fetchUserResponses() async {
    final dio = Dio();
    const String url =
        'https://user-service-254137058023.asia-south1.run.app/user/wholesaler/cart';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      setState(() {
        if (response.statusCode == 204) {
          _userResponses = [];
          _errorMessage = "";
        } else {
          _userResponses = response.data;
          _errorMessage = "";
        }
        _isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.message}';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchUserDetail(String userId) async {
    final dio = Dio();

    try {
      final prefs = await SharedPreferences.getInstance();
      final wholesalerId = prefs.getInt('wholesalerId')?.toString();

      if (wholesalerId == null) {
        print("Wholesaler ID not found in SharedPreferences.");
        return null;
      }

      final String url =
          "https://user-service-254137058023.asia-south1.run.app/user/$userId?wholesalerId=$wholesalerId";

      print("Fetching user details from: $url");

      final response = await dio.get(url);

      print("Response status code: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200) {
        return response.data; // Assuming this returns the user details
      } else {
        print("Error: ${response.statusCode} - ${response.statusMessage}");
      }
    } catch (e) {
      print("Error fetching user detail: $e");
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserResponses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: k2,
      appBar: AppBar(
        title: const Text(
          'User Response',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: kWhite),
        ),
        centerTitle: true,
        backgroundColor: kPrimary,
        elevation: 5,
      ),
      body: _isLoading
          ? _buildShimmerList()
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _userResponses.isEmpty
                  ? const Center(child: Text('No data available'))
                  : ListView.builder(
                      itemCount: _userResponses.length,
                      itemBuilder: (context, index) {
                        final response = _userResponses[index];
                        final userId = response['userId'].toString();
                        final List<dynamic> products =
                            response['finalProductList'];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          elevation: 5,
                          shadowColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${response['name'] ?? 'N/A'}',
                                  style: GoogleFonts.calistoga(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    
                                  ),
                                ),
                                Text(
                                  'Mobile No: ${response['mobileNumber'] ?? 'N/A'}',
                                  style: GoogleFonts.calistoga(
                                    fontSize: 16,
                                    
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Row for Buttons
                                Column(
                                  
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                   
                                    // View More Details Button (Always visible)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimary,
                                      ),
                                      onPressed: () async {
                                        final userDetails =
                                            await _fetchUserDetail(userId);
                                        if (userDetails != null) {
                                          _showUserDetailsDialog(
                                              context, userDetails);
                                        } else {
                                          print('User details not found');
                                        }
                                      },
                                      child: const Text("View More Detail",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    SizedBox(width: 8),
                                     if (products
                                        .isNotEmpty) // Show Products Button (Only if cart has products)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimary,
                                        ),
                                        onPressed: () {
                                          _showProductsDialog(
                                              context, products);
                                        },
                                        child: const Text(
                                            "Show Products Added in Cart",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
Widget _buildShimmerList() {
  return ListView.builder(
    itemCount: 5, // Shimmer ke liye 5 items dikhayenge
    itemBuilder: (context, index) {
      return Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(height: 20, width: 150), // Name
              SizedBox(height: 10),
              _buildShimmerBox(height: 20, width: 200), // Phone Number
              SizedBox(height: 10),
              _buildShimmerBox(height: 20, width: 250), // Email
              SizedBox(height: 10),
              _buildShimmerBox(height: 20, width: 300), // Address
               SizedBox(height: 10),
              _buildShimmerBox(height: 20, width: 300), // Address
              
              
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildShimmerBox({required double height, required double width}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Widget _details(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 18,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    ),
  );
}

void _showProductsDialog(BuildContext context, List<dynamic> products) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title:  Text("Products in Cart",style: GoogleFonts.calistoga(decoration: TextDecoration.underline), ),
        
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: products.map((product) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Product Name: ${product['productName'] ?? 'N/A'}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Category: ${product['categoryName'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87)),
                    if (product['subCategoryName'] != null)
                      Text('Sub Category: ${product['subCategoryName']}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87)),
                    Text("Wastage: ${product['wastage'] ?? 'N/A'}",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87)),
                    Text('Weight: ${product['weight'] ?? 'N/A'}g',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87)),
                    Text('Karat: ${product['karat'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87)),
                    if (product['gender'] != null)
                      Text('Gender: ${product['gender']}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87)),
                    SizedBox(height: 8),
                    if (product['imageUrls'] != null &&
                        product['imageUrls'].isNotEmpty)
                      Center(child: Image.network(product['imageUrls'][0], height: 100)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimary)),
          ),
        ],
      );
    },
  );
}

void _showUserDetailsDialog(
    BuildContext context, Map<String, dynamic> userDetails) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
       
        title: Center(
          child: Text(
            userDetails['name'] ?? "User Details",
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userDetails['email'] != null)
                _details("Email: ${userDetails['email']}"),
              if (userDetails['gender'] != null)
               _details("Gender: ${userDetails['gender']}"),
              if (userDetails['dateOfBirth'] != null)
                _details("DOB: ${userDetails['dateOfBirth']}"),
              if (userDetails['spouseDob'] != null)
                _details("Spouse DOB: ${userDetails['spouseDob']}"),
              if (userDetails['address'] != null)
                _details("Address: ${userDetails['address']}"),
              if (userDetails['pincode'] != null)
                _details("Pincode: ${userDetails['pincode']}"),
              if (userDetails['anniversary'] != null)
                _details("Anniversary: ${userDetails['anniversary']}"),
              if (userDetails['image'] != null)
                Center(child: Image.network(userDetails['image'], height: 100)),
              
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimary)),
          ),
        ],
      );
    },
  );
}
