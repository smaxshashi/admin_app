import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  // Fetch user responses from the API
  Future<void> _fetchUserResponses() async {
    final dio = Dio();
    const String url = 'https://api.gehnamall.com/admin/allUserResponse';

    try {
      final loginState = context.read<LoginBloc>().state;
      if (loginState is LoginSuccess) {
        final String token = loginState.login.token;

        final response = await dio.post(
          url,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

        setState(() {
          _userResponses = response.data; // Assuming response is a JSON array
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Unauthorized: Please login again.";
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.message}';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchUserDetail(String userId) async {
    final dio = Dio();
    final String url = "https://api.gehnamall.com/auth/getUserDetail/$userId";

    try {
      final loginState = context.read<LoginBloc>().state;
      if (loginState is LoginSuccess) {
        final String token = loginState.login.token;

        final response = await dio.get(
          url,
          options: Options(
            headers: {
              'Authorization':
                  'Bearer $token', // Include the Authorization header
              'Content-Type': 'application/json', // Include Content-Type header
            },
          ),
        );

        if (response.statusCode == 200) {
          return response.data; // Assuming this returns the user details
        } else {
          print("Error: ${response.statusCode} - ${response.statusMessage}");
        }
      } else {
        print("User not logged in or invalid login state.");
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
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _userResponses.isEmpty
                  ? const Center(child: Text('No data available'))
                  : ListView.builder(
                      itemCount: _userResponses.length,
                      itemBuilder: (context, index) {
                        final response = _userResponses[index];
                        final product = response['product'];
                        final userId = response['userId'].toString();

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (response['name'] != null)
                                  Text(
                                    'Name: ${response['name']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (response['mobileNumber'] != null)
                                  Text(
                                    'Mobile: ${response['mobileNumber']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                if (product != null) ...[
                                  if (product['productName'] != null)
                                    Text(
                                      'Product: ${product['productName']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  if (product['categoryName'] != null)
                                    Text(
                                      'Category: ${product['categoryName']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Weight: ${product['weight'] ?? 'N/A'}g',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Karat: ${product['karat'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ] else
                                  const Text(
                                    'No product information available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimary),
                                  onPressed: () async {
                                    final userDetails =
                                        await _fetchUserDetail(userId);
                                    if (userDetails != null) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: k2,
                                            title: Center(
                                              child: Text(userDetails['name'] ??
                                                  "User Details",style: TextStyle(color: kGray,fontWeight: FontWeight.bold,fontSize: 20,),),
                                            ),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (userDetails['email'] !=
                                                      null)
                                                    _details(
                                                        "Email: ${userDetails['email']}"),
                                                  if (userDetails[
                                                          'dateOfBirth'] !=
                                                      null)
                                                    _details(
                                                        "DOB: ${userDetails['dateOfBirth']}"),
                                                  if (userDetails[
                                                          'spouseDob'] !=
                                                      null)
                                                    _details(
                                                        "Spouse Date: ${userDetails['spouseDob']}"),
                                                  if (userDetails['address'] !=
                                                      null)
                                                    _details(
                                                        "Address: ${userDetails['address']}"),
                                                  if (userDetails['pincode'] !=
                                                      null)
                                                    _details(
                                                        "Pincode: ${userDetails['pincode']}"),
                                                  if (userDetails[
                                                          'anniversary'] !=
                                                      null)
                                                    _details(
                                                        "Anniversary: ${userDetails['anniversary']}"),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                  if (userDetails['image'] !=
                                                      null)
                                                    Center(
                                                      child: Container(
                                                      height: 200,
                                                        child: Image.network(
                                                            userDetails['image']),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text(
                                                  "Close",
                                                  style: TextStyle(
                                                     fontSize: 20,
                                                     fontWeight: FontWeight.bold,
                                                      color: kPrimary),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      print('userId not found');
                                    }
                                  },
                                  child: const Text(
                                    "View More Detail",
                                    style: TextStyle(color: kWhite),
                                  ),
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

Widget _details(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 18,
      color: kDark,
      fontWeight: FontWeight.w500,
    ),
  );
}
