import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/widget/banner_add.dart';
import 'package:gehnaorg/widget/testimonial_add.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../bloc/login_bloc.dart';

class TestimonialPage extends StatefulWidget {
  const TestimonialPage({super.key});

  @override
  State<TestimonialPage> createState() => _TestimonialPageState();
}

class _TestimonialPageState extends State<TestimonialPage> {
  List<Map<String, dynamic>> _testimonials = []; // Store testimonial details
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTestimonials();
  }

  Future<void> fetchTestimonials() async {
    final url = Uri.parse('https://api.gehnamall.com/api/testimonial');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _testimonials =
              List<Map<String, dynamic>>.from(data.map((item) => item));
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load testimonials');
      }
    } catch (error) {
      print('Error fetching testimonials: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteTestimonial(String id) async {
    final url =
        Uri.parse('https://api.gehnamall.com/admin/delete/testimonial/$id');
    final loginState = context.read<LoginBloc>().state;
    if (loginState is LoginSuccess) {
      final String token = loginState.login.token;

      try {
        final response = await http.post(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            _testimonials.removeWhere(
                (testimonial) => testimonial['testimonialId'].toString() == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Testimonial deleted successfully")),
          );
        } else {
          throw Exception('Failed to delete testimonial');
        }
      } catch (error) {
        print('Error deleting testimonial: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete testimonial")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: k2,
      appBar: AppBar(
        title: const Text(
          'Testimoial Section',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: kWhite),
        ),
         actions: [
           IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return TestimonialUpload();
                },
              ));
            },
            icon: Icon(Icons.add,color: kWhite,),
          ),
         ],
        centerTitle: true,
        backgroundColor: kPrimary,
        elevation: 5,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _testimonials.isEmpty
              ? Center(child: Text('No testimonials available'))
              : ListView.builder(
                  itemCount: _testimonials.length,
                  itemBuilder: (context, index) {
                    final testimonial = _testimonials[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                             Image.network(
                            testimonial['imageUrl'],
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
                              testimonial['customerName'] ?? "No Name",
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
                                      title: Text("Delete Testimonial"),
                                      content: Text(
                                          "Are you sure you want to delete this testimonial?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            deleteTestimonial(
                                                testimonial['testimonialId']
                                                    .toString());
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
