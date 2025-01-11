import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/constants/constants.dart';
import '../features/add_product/presentation/bloc/login_bloc.dart';

class TestimonialUpload extends StatefulWidget {
  const TestimonialUpload({super.key});

  @override
  State<TestimonialUpload> createState() => _TestimonialUploadState();
}

class _TestimonialUploadState extends State<TestimonialUpload> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _bannerImages;
  List<XFile>? _testimonialImages;
  TextEditingController _bannerNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _designationController = TextEditingController();

  // Method to pick images for Banner
  Future<void> _pickBannerImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _bannerImages = selectedImages;
      });
    }
  }

  Future<void> _pickTestimonialImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _testimonialImages = selectedImages;
      });
    }
  }

  // Method to upload testimonial to server
  Future<void> _uploadTestimonial() async {
    final String name = _nameController.text;
    final String designation = _designationController.text;

    if (name.isEmpty ||
        designation.isEmpty ||
        _testimonialImages == null ||
        _testimonialImages!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select images.')),
      );
      return;
    }

    final String url = 'https://api.gehnamall.com/admin/upload/testimonial';
    final dio = Dio();
    final loginState = context.read<LoginBloc>().state;
    if (loginState is LoginSuccess) {
      final String identity = loginState.login.identity;
      final String token = loginState.login.token;
      print("Login successful! Identity: $identity, Token: $token");

      try {
        // Prepare form data for the testimonial
        final formData = FormData.fromMap({
          'name': name,
          'designation': designation,
          for (var image in _testimonialImages!)
            'images': await MultipartFile.fromFile(image.path),
        });

        // Sending data to the server
        final response = await dio.post(url,
            data: formData,
            options: Options(
              headers: {
                'Content-Type': 'multipart/form-data',
                'Authorization': 'Bearer $token',
              },
            ));

        if (response.data['status'] == 0) {
          print('Testimonial uploaded successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Testimonial uploaded successfully!')),
          );
        } else {
          print('Failed: ${response.data['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.data['message']}')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred during upload!')),
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
          'Add more Testimonial',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: kWhite),
        ),
        backgroundColor: kPrimary,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start
          ,
          children: [
            Text("Testimonial Name",
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter Testimonial Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text("Designation",
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _designationController,
              decoration: InputDecoration(
                hintText: 'Enter Designation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Center(
              child: Text("Select Images",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Center(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  onPressed: _pickTestimonialImages,
                  child: const Text(
                    'Pick Testimonioal',
                    style: TextStyle(color: kWhite),
                  ),
                ),
            ),
            SizedBox(height: 16),
            _testimonialImages == null
                ? Center(child: Text("No images selected"))
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
            SizedBox(height: 16),
            // Submit Button to Upload Testimonial
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
    );
  }
}
