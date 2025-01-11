import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/constants/constants.dart';
import '../features/add_product/presentation/bloc/login_bloc.dart';

class BannnerUpload extends StatefulWidget {
  const BannnerUpload({super.key});

  @override
  State<BannnerUpload> createState() => _BannnerUploadState();
}

class _BannnerUploadState extends State<BannnerUpload> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _bannerImages;

  TextEditingController _bannerNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  // Method to pick images for Banner
  Future<void> _pickBannerImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _bannerImages = selectedImages;
      });
    }
  }

  // Method to upload banner to server
  Future<void> _uploadBanner() async {
    final String bannerName = _bannerNameController.text;
    final String description = _descriptionController.text;

    if (bannerName.isEmpty ||
        description.isEmpty ||
        _bannerImages == null ||
        _bannerImages!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select images.')),
      );
      return;
    }

    final String url = 'https://api.gehnamall.com/admin/upload/Banner';
    final dio = Dio();
    final loginState = context.read<LoginBloc>().state;
    if (loginState is LoginSuccess) {
      final String identity = loginState.login.identity;
      final String token = loginState.login.token;
      print("Login successful! Identity: $identity, Token: $token");

      try {
        // Prepare form data
        final formData = FormData.fromMap({
          'bannerName': bannerName,
          'description': description,
          for (var image in _bannerImages!)
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
          print('Banner uploaded successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Banner uploaded successfully!')),
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
          'Add more Banner',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: kWhite),
        ),
        backgroundColor: kPrimary,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start
          ,
            children: [
              Text("Banner Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _bannerNameController,
                decoration: InputDecoration(
                  hintText: 'Enter Banner Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              Text("Description",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              Center(
                child: Text("Select Banner",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  onPressed: _pickBannerImages,
                  child: const Text(
                    'Pick Banner',
                    style: TextStyle(color: kWhite),
                  ),
                ),
              ),

              _bannerImages == null
                  ? Center(child: Text("No Banner selected"))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _bannerImages!
                          .map((image) => Image.file(
                                File(image.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ))
                          .toList(),
                    ),
              SizedBox(height: 16),

              // Submit Button to Upload Banner
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  onPressed: _uploadBanner,
                  child: const Text(
                    'Upload Banner',
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
