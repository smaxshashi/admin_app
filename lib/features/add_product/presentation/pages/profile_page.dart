import 'package:flutter/material.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          ? Center(child: CircularProgressIndicator()) // Token load hone tak loader dikhayenge
          : FutureBuilder<List<User>>(
              future: fetchUsers(token!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
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
                            Text('Name: ${user.name ?? 'null'}'),
                            Text('Phone Number: ${user.phoneNumber ?? 'null'}'),
                            Text('Email: ${user.email ?? 'null'}'),
                            Text('Address: ${user.address ?? 'null'}'),
                            Text('Pincode: ${user.pincode ?? 'null'}'),
                            Text('Gender: ${user.gender ?? 'null'}'),
                            Text('Date of Birth: ${user.dateOfBirth ?? 'null'}'),
                            Text('Spouse Date of Birth: ${user.spouseDateOfBirth ?? 'null'}'),
                            Text('Anniversary: ${user.anniversary ?? 'null'}'),
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

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // Navigate to LoginPage
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}
