import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import '../core/constants/constants.dart';
import '../features/add_product/presentation/pages/testimonial_page.dart';

class TestimonialUpload extends StatefulWidget {
  const TestimonialUpload({super.key});

  @override
  State<TestimonialUpload> createState() => _TestimonialUploadState();
}

class _TestimonialUploadState extends State<TestimonialUpload> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _testimonialImages;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  Future<void> _pickTestimonialImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _testimonialImages = selectedImages;
      });
    }
  }

  Future<void> _uploadTestimonial() async {
  final String name = _nameController.text.trim();
  final String designation = _designationController.text.trim();

  if (name.isEmpty ||
      designation.isEmpty ||
      _testimonialImages == null ||
      _testimonialImages!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields and select images.')),
    );
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final int? wholesalerId = prefs.getInt('wholesalerId');

  if (wholesalerId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('wholesalerId not found. Please log in again.')),
    );
    return;
  }

  final String url = 'https://upload-service-254137058023.asia-south1.run.app/upload/$wholesalerId/uploadTestimonial';

  final dio = Dio();
  try {
    // Prepare form data for the testimonial
    final formData = FormData.fromMap({
      'testimonialName': name,
      'description': designation,
      for (var image in _testimonialImages!)
        'image': await MultipartFile.fromFile(
          image.path,
          contentType: MediaType('image', 'jpeg'), // Adjust the MIME type as needed
        ),
    });

    // Sending data to the server
    final response = await dio.post(
      url,
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Testimonial uploaded successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Testimonial uploaded successfully!')),
      );

      // Delay navigation for 2 seconds to show snackbar
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TestimonialPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      print('Failed: ${response.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${response.data['message']}')),
      );
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error occurred during upload!')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: k2,
      appBar: AppBar(
        title: const Text(
          'Add More Testimonial',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kWhite),
        ),
        backgroundColor: kPrimary,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Testimonial Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Testimonial Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Designation",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _designationController,
                decoration: const InputDecoration(
                  hintText: 'Enter Designation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text("Select Images",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  onPressed: _pickTestimonialImages,
                  child: const Text(
                    'Pick Testimonial Images',
                    style: TextStyle(color: kWhite),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _testimonialImages == null
                  ? const Center(child: Text("No images selected"))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _testimonialImages!
                          .map((image) => Image.file(
                                File(image.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ))
                          .toList(),
                    ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  onPressed: _uploadTestimonial,
                  child: const Text(
                    'Upload Testimonial',
                    style: TextStyle(color: kWhite),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
