import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/widget/banner_add.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/constants.dart';
import '../bloc/login_bloc.dart';

class BannerAndTestimonialPage extends StatefulWidget {
  @override
  _BannerAndTestimonialPageState createState() =>
      _BannerAndTestimonialPageState();
}

class _BannerAndTestimonialPageState extends State<BannerAndTestimonialPage> {
  List<Map<String, dynamic>> _banners = []; // Store banner details
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBanners();
    
  }

  Future<void> fetchBanners() async {
    final prefs = await SharedPreferences.getInstance();
    final wholesalerId = prefs.getInt('wholesalerId');
    if (wholesalerId == null) {
      throw Exception('wholesalerId not found in shared preferences');
    }

    final url = Uri.parse(
        'https://upload-service-254137058023.asia-south1.run.app/upload/$wholesalerId/getbanners?isActive=true');
    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _banners = List<Map<String, dynamic>>.from(data.map((item) => item));
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch banners');
      }
    } catch (error) {
      print('Error fetching banners: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteBanner(String bannerId) async {
   
    final url = Uri.parse(
        "https://upload-service-254137058023.asia-south1.run.app/upload/$bannerId/deleteBanner");

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _banners.removeWhere(
              (banner) => banner['bannerId'].toString() == bannerId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Banner deleted successfully!")),
        );
      } else {
        throw Exception('Opss... Failed to delete banner');
      }
    } catch (error) {
      print('Error deleting banner: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete banner")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: k2,
      appBar: AppBar(
        title: const Text(
          'Banner Screen',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: kWhite),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return BannnerUpload();
                },
              ));
            },
            icon: Icon(
              Icons.add,
              color: kWhite,
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: kPrimary,
        elevation: 5,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _banners.isEmpty
              ? Center(child: Text('No banners available'))
              : ListView.builder(
                  itemCount: _banners.length,
                  itemBuilder: (context, index) {
                    final banner = _banners[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            banner['imageUrl'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : Center(
                                      child: CircularProgressIndicator(
                                        value: progress.expectedTotalBytes !=
                                                null
                                            ? progress.cumulativeBytesLoaded /
                                                (progress.expectedTotalBytes ??
                                                    1)
                                            : null,
                                      ),
                                    );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              banner['bannerName'] ?? "No Name",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Delete Banner"),
                                      content: Text(
                                          "Are you sure you want to delete this banner?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            deleteBanner(
                                                banner['bannerId'].toString());
                                          },
                                          child: Text(
                                            "Delete",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
