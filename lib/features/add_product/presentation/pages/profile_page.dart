import 'package:flutter/material.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/constants.dart';
import '../../apis/profile.dart';
import '../../data/models/profile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: k2,
      appBar: AppBar(
        title: const Text(
          'User Details',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: kWhite),
        ),
        centerTitle: true,
        backgroundColor: kPrimary,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kWhite),
            onPressed: () => logout(context),
          ),
        ],
      ),
    body: token == null
    ? Center(child: CircularProgressIndicator())
    : FutureBuilder<List<User>>(
        future: fetchUsers(token!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerList();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No user data available'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _details("Name: ${user.name ?? 'null'}"),
                      _details('Phone Number: ${user.phoneNumber ?? 'null'}'),
                      _details('Email: ${user.email ?? 'null'}'),
                      _details('Address: ${user.address ?? 'null'}'),
                      _details('Pincode: ${user.pincode ?? 'null'}'),
                      _details('Gender: ${user.gender ?? 'null'}'),
                      _details('Date of Birth: ${user.dateOfBirth ?? 'null'}'),
                      _details('Spouse Date of Birth: ${user.spouseDateOfBirth ?? 'null'}'),
                      _details('Anniversary: ${user.anniversary ?? 'null'}'),
                    ],
                  ),
                ),
              );
            },
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


Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // Navigate to LoginPage
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}

Widget _details(String text) {
  return Text(
    text,
    style: GoogleFonts.calistoga(
      fontSize: 15,
    
      color: Colors.black87,
    ),
  );
}
