import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/constants.dart';
import '../../apis/light_category.dart';
import '../bloc/login_bloc.dart';

class LightweightPage extends StatefulWidget {
  const LightweightPage({super.key});

  @override
  State<LightweightPage> createState() => _LightweightPageState();
}

class _LightweightPageState extends State<LightweightPage> {
  String? _selectedKarat = '18K';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles = [];

  // Form Fields
  String? _productName;
  String? _description;
  String? _wastage;
  String? _weight;
  Map<String, dynamic>? _selectedCategory;

  List<Map<String, dynamic>> _lightCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLightCategories();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? selectedImages = await _picker.pickMultiImage();
      if (selectedImages != null) {
        setState(() {
          _imageFiles = selectedImages; // Update the image list
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<void> _loadLightCategories() async {
  try {
    final categories = await LightCategoriesService().fetchLightCategories();
    setState(() {
      _lightCategories = categories;
      _selectedCategory = categories.isNotEmpty ? categories.first : null;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching categories: $e')),
    );
  }
}
Future<void> _submitProduct() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    // Ensure that _selectedCategory is not null and that categoryCode exists
    if (_selectedCategory == null || _selectedCategory!['categoryCode'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid category')),
      );
      return;
    }

    // Get the categoryCode from _selectedCategory
    final categoryCode = _selectedCategory!['categoryCode'];

    final apiUrl =
        'https://api.gehnamall.com/admin/upload/Products?category=$categoryCode&wholeseller=Bansal&lightWeight=light';

    final loginState = context.read<LoginBloc>().state;
    if (loginState is LoginSuccess) {
      final String token = loginState.login.token;

      try {
        final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

        // Add headers
        request.headers['Authorization'] = 'Bearer $token';

        // Add form fields
        request.fields['productName'] = _productName ?? '';
        request.fields['description'] = _description ?? '';
        request.fields['wastage'] = _wastage ?? '';
        request.fields['weight'] = _weight ?? '';
        request.fields['karat'] = _selectedKarat ?? '';

        // Add images
        if (_imageFiles != null && _imageFiles!.isNotEmpty) {
          for (var image in _imageFiles!) {
            request.files
                .add(await http.MultipartFile.fromPath('images', image.path));
          }
        }

        // Send the request
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          // Parse response if it's in JSON format
          final responseData = jsonDecode(responseBody);
          final serverMessage =
              responseData['message'] ?? 'Product added successfully';
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(serverMessage)));
        } else {
          // Parse error response if it's in JSON format
          final errorData = jsonDecode(responseBody);
          final errorMessage = errorData['error'] ?? 'Failed to add product';
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } catch (e) {
        print('Error submitting product: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
          title: const Text(
            'Add Product',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: kWhite),
          ),
          centerTitle: true,
          backgroundColor: kPrimary,
          elevation: 5,
        ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Category Dropdown
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Map<String, dynamic>>(
                     dropdownColor: kPrimary,
                        style: TextStyle(color: kWhite, fontSize: 18),
                      isExpanded: true,
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Category',
                      ),
                      items: _lightCategories
                          .map((category) =>
                              DropdownMenuItem<Map<String, dynamic>>(
                                value: category,
                                child:
                                    Text(category['categoryName'] ?? 'Unknown'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),

              const SizedBox(height: 16),

              // Product Name
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Product Name',
                ),
                onSaved: (value) => _productName = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter product name'
                    : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
                maxLines: 3,
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 16),

              // Wastage %
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Wastage %',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _wastage = value,
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Weight (g) *',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter weight' : null,
                onSaved: (value) => _weight = value,
              ),
              const SizedBox(height: 16),

              // Image Selector
              InkWell(
                onTap: _pickImages,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageFiles == null || _imageFiles!.isEmpty
                      ? const Center(
                          child:
                              Icon(Icons.image, size: 50, color: kPrimary),
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          children: _imageFiles!
                              .map(
                                (image) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(
                                    File(image.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Karat Dropdown
              DropdownButtonFormField<String>(
                 dropdownColor: kPrimary,
                        style: TextStyle(color: kWhite, fontSize: 18),
                isExpanded: true,
                value: _selectedKarat,
                onChanged: (value) {
                  setState(() {
                    _selectedKarat = value;
                  });
                },
                items: ['18K', '22K', '24K']
                    .map((karat) => DropdownMenuItem<String>(
                          value: karat,
                          child: Text(karat),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Select Karat',
                border: OutlineInputBorder()),
              ),
              const SizedBox(height: 40),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  elevation: 4,
                  fixedSize: Size(450, 55)
                ),
                onPressed: _submitProduct,
                child: const Text('Add Product', style: TextStyle(color: kWhite,fontSize: 20),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
