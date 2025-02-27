import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gehnaorg/core/constants/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  EditProductPage({required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];

  // Controllers for form fields
  late TextEditingController _productNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _wastageController;
  late TextEditingController _weightController;
  late TextEditingController _karatController;
  late TextEditingController _tagNumberController;
  late TextEditingController _lengthController;
  late TextEditingController _sizeController;
  late TextEditingController _occasionController;
  late TextEditingController _soulmateController;
  late TextEditingController _giftingController;
  late TextEditingController _genderController;
  late TextEditingController _productTypeController;
  late TextEditingController _categoryNameController;
  late TextEditingController _subCategoryNameController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _productNameController =
        TextEditingController(text: widget.product['productName']);
    _descriptionController =
        TextEditingController(text: widget.product['description'] ?? '');
    _categoryNameController =
        TextEditingController(text: widget.product['categoryName'] ?? '');
    _subCategoryNameController =
        TextEditingController(text: widget.product['subCategoryName'] ?? '');

    _wastageController =
        TextEditingController(text: widget.product['wastage'] ?? '');
    _weightController =
        TextEditingController(text: widget.product['weight'] ?? '');
    _karatController =
        TextEditingController(text: widget.product['karat'] ?? '');
    _tagNumberController =
        TextEditingController(text: widget.product['tagNumber'] ?? '');
    _lengthController =
        TextEditingController(text: widget.product['length'] ?? '');
    _sizeController = TextEditingController(text: widget.product['size'] ?? '');
    _occasionController =
        TextEditingController(text: widget.product['occasion'] ?? '');
    _soulmateController =
        TextEditingController(text: widget.product['soulmateName'] ?? '');
    _giftingController =
        TextEditingController(text: widget.product['giftingName'] ?? '');
    _genderController =
        TextEditingController(text: widget.product['gender'] ?? '');
    _productTypeController =
        TextEditingController(text: widget.product['productType'] ?? '');

    // Load existing images
    if (widget.product['imageUrls'] != null) {
      _existingImageUrls = List<String>.from(widget.product['imageUrls']);
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _productNameController.dispose();
    _descriptionController.dispose();
    _categoryNameController.dispose();
    _subCategoryNameController.dispose();
    _wastageController.dispose();
    _weightController.dispose();
    _karatController.dispose();
    _tagNumberController.dispose();
    _lengthController.dispose();
    _sizeController.dispose();
    _occasionController.dispose();
    _soulmateController.dispose();
    _giftingController.dispose();
    _genderController.dispose();
    _productTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages
            .addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }

 Future<void> _updateProduct() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final dio = Dio();
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  setState(() {
    _isLoading = true;
  });

  try {
    final String productId = widget.product['productId'].toString();
    final url = "https://upload-service-254137058023.asia-south1.run.app/upload/updateV2/$productId";

    final prefs = await SharedPreferences.getInstance();
    final wholesalerId = prefs.getInt('wholesalerId');
    final token = prefs.getString('token');

    if (wholesalerId == null || token == null) {
      throw Exception('wholesalerId or token not found in SharedPreferences');
    }

    final String uploadRequestJson = jsonEncode({
      "productName": _productNameController.text,
      "description": _descriptionController.text,
      "wastage": _wastageController.text,
      "weight": _weightController.text,
      "karat": _karatController.text,
      "categoryName": widget.product['categoryName'],
      "categoryId": widget.product['categoryId'].toString(),
      "subCategoryName": widget.product['subCategoryName'],
      "subCategoryId": widget.product['subCategoryId'].toString(),
      "tagNumber": _tagNumberController.text,
      "length": _lengthController.text,
      "size": _sizeController.text,
      "wholesaler": widget.product['wholesaler'] ?? "",
      "wholesalerId": wholesalerId.toString(),
      "occasion": _occasionController.text,
      "soulmate": _soulmateController.text,
      "gifting": _giftingController.text,
      "gender": _genderController.text,
      "productType": _productTypeController.text
    });

    final formData = FormData.fromMap({
      "uploadRequest": MultipartFile.fromString(uploadRequestJson, contentType: MediaType("application", "json")),
      "images": await Future.wait(_selectedImages.map((image) async {
        return MultipartFile.fromFile(image.path, filename: image.path.split('/').last);
      })),
    });

    print('Final FormData Fields: ${formData.fields}');
    print('Final FormData Files: ${formData.files}');

    final options = Options(
      contentType: 'multipart/form-data',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final response = await dio.put(url, data: formData, options: options);

    if (response.statusCode == 200 && response.data['status'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: ${response.data['message']}')),
      );
    }
  } catch (e) {
    print("Error updating product: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error occurred while updating product: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Product',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kWhite,
          ),
        ),
        backgroundColor: kPrimary,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Images Section
                    if (_existingImageUrls.isNotEmpty) ...[
                      Text(
                        'Current Images',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingImageUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _existingImageUrls[index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],

                    // New Images Section
                    Text(
                      'Add New Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImages,
                          icon: Icon(Icons.add_photo_alternate, color: kWhite),
                          label: Text('Add Images'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: kWhite,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${_selectedImages.length} new images selected',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedImages.isNotEmpty) ...[
                      SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImages[index],
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: 20),

                    // Form Fields
                    TextFormField(
                      controller: _productNameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: TextEditingController(
                          text: widget.product['categoryName'] ?? ''),
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: TextEditingController(
                          text: widget.product['subCategoryName'] ?? ''),
                      decoration: InputDecoration(
                        labelText: 'Sub Category Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: 'Weight',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _karatController,
                            decoration: InputDecoration(
                              labelText: 'Karat',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _wastageController,
                            decoration: InputDecoration(
                              labelText: 'Wastage',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _tagNumberController,
                            decoration: InputDecoration(
                              labelText: 'Tag Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lengthController,
                            decoration: InputDecoration(
                              labelText: 'Length',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _sizeController,
                            decoration: InputDecoration(
                              labelText: 'Size',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    TextFormField(
                      controller: _occasionController,
                      decoration: InputDecoration(
                        labelText: 'Occasion',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _soulmateController,
                            decoration: InputDecoration(
                              labelText: 'Soulmate',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _giftingController,
                            decoration: InputDecoration(
                              labelText: 'Gifting',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _genderController,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _productTypeController,
                            decoration: InputDecoration(
                              labelText: 'Product Type',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: kWhite,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                        ),
                        child: Text(
                          'Update Product',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
