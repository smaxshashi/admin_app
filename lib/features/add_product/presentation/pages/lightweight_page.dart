import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../../core/constants/constants.dart';
import '../../apis/light_category.dart';
import '../../data/models/post.dart';
import '../bloc/login_bloc.dart';

class LightweightPage extends StatefulWidget {
  const LightweightPage({super.key});

  @override
  State<LightweightPage> createState() => _LightweightPageState();
}

class _LightweightPageState extends State<LightweightPage> {
  String? _selectedKarat = '18K';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _wastageController = TextEditingController();
  final _weightController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages = [];

  Map<String, dynamic>? _selectedCategory;

  List<Map<String, dynamic>> _lightCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLightCategories();
  }


  Future<void> _pickImages(ImageSource source) async {
    print("Picking images from gallery...");
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null &&
        _selectedImages!.length + pickedImages.length <= 7) {
      print("Picked ${pickedImages.length} images.");
      setState(() {
        _selectedImages!.addAll(pickedImages);
      });
    } else {
      print("Exceeded image limit. Showing error message.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can select a maximum of 7 images.')),
      );
    }
  }
   // Function to capture an image from camera
  Future<void> _captureImage() async {
    print("Capturing image from camera...");
    if (_selectedImages!.length >= 7) {
      print("Exceeded image limit. Showing error message.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can select a maximum of 7 images.')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      print("Captured image: ${image.path}");
      setState(() {
        _selectedImages!.add(image);
      });
    }
  }

  // Function to remove a selected image
  void _removeImage(int index) {
    print("Removing image at index: $index");
    setState(() {
      _selectedImages!.removeAt(index);
    });
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
    print("Starting product submission...");

    // Step 1: Validate form fields
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed.");
      return;
    }

    // Step 2: Validate image selection (1 to 7 images allowed)
    if (_selectedImages!.isEmpty || _selectedImages!.length > 7) {
      print(
          "Invalid image selection: ${_selectedImages!.length} images selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select between 1 and 7 images.')),
      );
      return;
    }

    // Step 3: Validate category selection
    if (_selectedCategory == null) {
      print("Category not selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category is required!')),
      );
      return;
    }

  



    // Step 5: Get Wholesaler ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? identity = prefs.getString('identity');
    final int? wholesalerId = prefs.getInt('wholesalerId');
    if (wholesalerId == null) {
      print("Wholesaler ID not found in SharedPreferences.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to retrieve wholesaler information.')),
      );
      return;
    }

    // Step 6: Prepare the product upload request data
    var uploadRequest = ProductUploadRequest(
      productName: _productNameController.text,
      description: _descriptionController.text,
      wastage: _wastageController.text,
      weight: _weightController.text,
      karat: _selectedKarat!,
      categoryName: _selectedCategory!['categoryName'],
      categoryId: _selectedCategory!['categoryId'].toString(),
      subCategoryName: '',
      subCategoryId: '',
      tagNumber: '',
      length: '',
      size: '',
      wholesaler: identity ?? '',
      wholesalerId: wholesalerId.toString(),
      occasion: '',
      soulmate: '',
      gifting:  '',
      gender: '',
      productType: 'light',
    );

    // Step 7: Upload the product
    await uploadProduct(token!, uploadRequest);
  }



Future<void> uploadProduct(
  String token, ProductUploadRequest uploadRequest) async {
  var uri = Uri.parse(
      'https://upload-service-254137058023.asia-south1.run.app/upload/product');

  // Step 1: Create the MultipartRequest for the form upload
  var request = http.MultipartRequest('POST', uri)
    ..headers.addAll({
      'Authorization': 'Bearer $token', // Add Authorization header
    });

  // Step 2: Serialize the ProductUploadRequest into JSON
  // Convert the uploadRequest to a raw byte array and add the content type
var jsonString = jsonEncode({
  'productName': uploadRequest.productName,
  'description': uploadRequest.description,
  'wastage': uploadRequest.wastage,
  'weight': uploadRequest.weight,
  'karat': uploadRequest.karat,
  'categoryName': uploadRequest.categoryName,
  'categoryId': uploadRequest.categoryId,
  'subCategoryName': uploadRequest.subCategoryName,
  'subCategoryId': uploadRequest.subCategoryId,
  'tagNumber': uploadRequest.tagNumber,
  'length': uploadRequest.length,
  'size': uploadRequest.size,
  'wholesaler': uploadRequest.wholesaler,
  'wholesalerId': uploadRequest.wholesalerId,
  'occasion': uploadRequest.occasion,
  'soulmate': uploadRequest.soulmate,
  'gifting': uploadRequest.gifting,
  'gender': uploadRequest.gender,
  'productType': uploadRequest.productType,
});

// Add the raw JSON as a part of the multipart form
request.files.add(http.MultipartFile.fromBytes(
  'uploadRequest', // Field name expected by the API
  utf8.encode(jsonString), // Convert JSON to bytes
  filename: 'uploadRequest.json',
  contentType: MediaType('application', 'json'), // Set content type as JSON
));

  // Step 4: Attach images to the request (if any)
  if (_selectedImages!.isEmpty) {
    print("No images selected.");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select at least one image.')),
    );
    return;
  }

  // Attach images to the request
  for (var image in _selectedImages!) {
    var file = await http.MultipartFile.fromPath(
      'images', // Field name expected by the API
      image.path, // Image path
      contentType: MediaType('image', 'jpeg'), // Specify the correct content type for the image
    );
    request.files.add(file);
  }

  print("Request fields: ${request.fields}");
print("Request files: ${request.files}");

  // Step 5: Send the request and handle the response
  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      print("Product uploaded successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully!')),
      );
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LightweightPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      print("Failed to upload product. Status code: ${response.statusCode}");
      String responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload product: $responseBody')),
      );
    }
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error uploading product: $e')),
    );
  }
}

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Product',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Map<String, dynamic>>(
                      isExpanded: true,
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Category',
                      ),
                      items: _lightCategories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category['categoryName'] ?? ''),
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
               TextFormField(
                 controller: _productNameController,
                 decoration: const InputDecoration(
                     labelText: 'Product Name',
                     border: OutlineInputBorder()),
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Please enter product name';
                   }
                   return null;
                 },
               ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _wastageController,
                decoration: const InputDecoration(
                    labelText: 'Wastage', border: OutlineInputBorder()),
               keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter wastage';
                  }
                  return null;
                },
              ),
               const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                          labelText: 'Weight(g)',
                          border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter weight';
                        }
                        return null;
                      },
                    ),
                     const SizedBox(height: 16),

              // Karat Dropdown
              DropdownButtonFormField<String>(
              
                      
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
                 const SizedBox(height: 20),
                 // Image Picker Buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimary),
                            onPressed: () => _pickImages(ImageSource.gallery),
                            child: const Text(
                              'Pick Images',
                              style: TextStyle(color: kWhite),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimary),
                            onPressed: _captureImage,
                            child: const Text(
                              'Capture Image',
                              style: TextStyle(color: kWhite),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Display Selected Images
                    if (_selectedImages!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          children: _selectedImages!.map((image) {
                            return Stack(
                              children: [
                                Image.file(
                                  File(image.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _removeImage(
                                        _selectedImages!.indexOf(image)),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
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
