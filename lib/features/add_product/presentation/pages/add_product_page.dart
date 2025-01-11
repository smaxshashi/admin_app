import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';
import 'package:gehnaorg/features/add_product/data/models/subcategory.dart';
import 'package:gehnaorg/features/add_product/data/repositories/category_repository.dart';
import 'package:gehnaorg/features/add_product/data/repositories/subcategory_repository.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/add_product_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/login_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/subcategory_bloc/subcategory_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/constants.dart';
import '../../apis/gifting_service.dart';
import '../../apis/occasions.dart';
import '../../apis/soulmates_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _wastageController = TextEditingController();
  final _weightController = TextEditingController();

  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;
  int? _selectedGender;
  String? _selectedKarat = '18K';

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  Future<void> _pickImages(ImageSource source) async {
    print("Picking images from gallery...");
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null &&
        _selectedImages.length + pickedImages.length <= 7) {
      print("Picked ${pickedImages.length} images.");
      setState(() {
        _selectedImages.addAll(pickedImages);
      });
    } else {
      print("Exceeded image limit. Showing error message.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can select a maximum of 7 images.')),
      );
    }
  }

  List<String> _soulmateOptions = [];
  bool _isLoadingSoulmateOptions = true;
  String? _selectedSoulmate;

  void _loadSoulmateOptions() async {
    try {
      final options = await SoulmateService().fetchSoulmateOptions();
      setState(() {
        _soulmateOptions = options;
        _isLoadingSoulmateOptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSoulmateOptions = false;
      });
      print('Error fetching soulmate options: $e');
    }
  }

  List<String> _occasionOptions = [];
  bool _isLoadingOccasionOptions = true;
  String? _selectedOccasion;

  @override
  void initState() {
    super.initState();
    _loadGiftingOptions();
    _loadOccasionOptions();
    _loadSoulmateOptions();
  }

  void _loadOccasionOptions() async {
    try {
      final options = await OccasionService().fetchOccasionOptions();
      setState(() {
        _occasionOptions = options;
        _isLoadingOccasionOptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOccasionOptions = false;
      });
      print('Error fetching occasion options: $e');
    }
  }

  List<String> _giftingOptions = [];
  bool _isLoadingGiftingOptions = true;
  String? _selectedGifting;

  void _loadGiftingOptions() async {
    try {
      final options = await GiftingService().fetchGiftingOptions();
      setState(() {
        _giftingOptions = options;
        _isLoadingGiftingOptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGiftingOptions = false;
      });
      print('Error fetching gifting options: $e');
    }
  }

  // Function to capture an image from camera
  Future<void> _captureImage() async {
    print("Capturing image from camera...");
    if (_selectedImages.length >= 7) {
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
        _selectedImages.add(image);
      });
    }
  }

  // Function to remove a selected image
  void _removeImage(int index) {
    print("Removing image at index: $index");
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitProduct() async {
    print("Submitting product...");
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed.");
      return;
    }

    if (_selectedImages.isEmpty || _selectedImages.length > 7) {
      print("Invalid image selection.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select between 1 and 7 images.')),
      );
      return;
    }

    if (_selectedCategory == null) {
      print("Category not selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category is required!')),
      );
      return;
    }

    final dio = Dio();
    final String categoryCode = _selectedCategory!.categoryCode.toString();
    final String? subCategoryCode =
        _selectedSubCategory?.subcategoryCode.toString();

    final loginState = context.read<LoginBloc>().state;
    if (loginState is LoginSuccess) {
      final String identity = loginState.login.identity;
      final String token = loginState.login.token;
      print("Login successful! Identity: $identity, Token: $token");

      // Dynamically generate the URL based on subcategory presence
      final String url = subCategoryCode == null || subCategoryCode.isEmpty
          ? 'https://api.gehnamall.com/admin/upload/Products?category=$categoryCode&wholeseller=$identity'
          : 'https://api.gehnamall.com/admin/upload/Products?category=$categoryCode&subCategory=$subCategoryCode&wholeseller=$identity';

      print("URL for product upload: $url");

      try {
        List<MultipartFile> imageFiles = await Future.wait(_selectedImages.map(
          (XFile image) async {
            final bytes = await image.readAsBytes();
            return MultipartFile.fromBytes(
              bytes,
              filename: image.name,
              contentType: DioMediaType.parse('image/jpeg'),
            );
          },
        ));

        final formData = FormData.fromMap({
          'productName': _productNameController.text,
          'description': _descriptionController.text,
          'wastage': _wastageController.text,
          'weight': _weightController.text,
          'karat': _selectedKarat,
          'genderCode': _selectedGender == 1 ? '1' : '2',
          'images': imageFiles,
          'gifting': _selectedGifting, // Add gifting selection
          'soulmate': _selectedSoulmate, // Add soulmate selection
          'occasion': _selectedOccasion, // Add occasion selection
        });

        print("Sending data to server...");
        final response = await dio.post(
          url,
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
              'Authorization': 'Bearer $token',
            },
          ),
        );

        if (response.data['status'] == 0) {
          print("Product added successfully!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AddProductPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(
                    milliseconds: 500), // Adjust transition speed
              ),
            );
          });
        } else {
          print("Failed with status: ${response.data['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.data['message']}')),
          );
        }
      } on DioException catch (e) {
        print("DioException: ${e.response?.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${e.response?.statusCode}')),
        );
      } catch (e) {
        print("Unexpected error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected error occurred!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building UI...");
    final dio = Dio();
    final categoryRepository = CategoryRepository(dio);
    final subCategoryRepository = SubCategoryRepository(dio);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AddProductBloc(
            categoryRepository: categoryRepository,
            subCategoryRepository: subCategoryRepository,
          )..loadCategories('BANSAL'),
        ),
        BlocProvider(
          create: (_) => SubCategoryBloc(subCategoryRepository),
        ),
      ],
      child: Scaffold(
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
        body: BlocBuilder<AddProductBloc, List<Category>>(
          builder: (context, categories) {
            if (categories.isEmpty) {
              print("Loading categories...");
              return const Center(child: CircularProgressIndicator());
            }
            print("Categories loaded: ${categories.length}");
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Category Dropdown
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<Category>(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        dropdownColor: kPrimary,
                        style: TextStyle(color: kWhite, fontSize: 18),
                        isExpanded: true,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.categoryName),
                          );
                        }).toList(),
                        onChanged: (selectedCategory) {
                          print(
                              "Category selected: ${selectedCategory?.categoryName}");
                          setState(() {
                            _selectedCategory = selectedCategory;
                          });

                          if (selectedCategory != null &&
                              ['Gold', 'Silver', 'Diamond']
                                  .contains(selectedCategory.categoryName)) {
                            // For Gold, Silver, Diamond, pass genderCode: 1
                            context.read<SubCategoryBloc>().loadSubCategories(
                                  categoryCode: selectedCategory.categoryCode,
                                  genderCode:
                                      1, // Default gender for Gold, Silver, Diamond
                                  wholeseller: 'BANSAL',
                                );
                          } else {
                            // For other categories, pass genderCode: null (if genderCode is nullable)
                            context.read<SubCategoryBloc>().loadSubCategories(
                                  categoryCode:
                                      selectedCategory?.categoryCode ??
                                          0, // Default value if null
                                  genderCode:
                                      null, // Null gender for other categories
                                  wholeseller: 'BANSAL',
                                );
                          }
                        },
                        decoration:
                             InputDecoration(labelText: 'Select Category',border: OutlineInputBorder(),
                             ),
                      ),
                    ),

                    // Gender Radio Buttons (Only for Gold, Silver, and Diamond)
                    if (_selectedCategory != null &&
                        ['Gold', 'Silver', 'Diamond']
                            .contains(_selectedCategory!.categoryName))
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: RadioListTile<int>(
                                activeColor: kPrimary,
                                title: const Text('Male'),
                                value: 1,
                                groupValue: _selectedGender,
                                onChanged: (value) {
                                  print("Gender selected: Male");
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                  if (value != null) {
                                    context
                                        .read<SubCategoryBloc>()
                                        .loadSubCategories(
                                          categoryCode:
                                              _selectedCategory!.categoryCode,
                                          genderCode: value,
                                          wholeseller: 'BANSAL',
                                        );
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<int>(
                                activeColor: kPrimary,
                                title: const Text('Female'),
                                value: 2,
                                groupValue: _selectedGender,
                                onChanged: (value) {
                                  print("Gender selected: Female");
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                  if (value != null) {
                                    context
                                        .read<SubCategoryBloc>()
                                        .loadSubCategories(
                                          categoryCode:
                                              _selectedCategory!.categoryCode,
                                          genderCode: value,
                                          wholeseller: 'BANSAL',
                                        );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    BlocBuilder<SubCategoryBloc, SubCategoryState>(
                      builder: (context, state) {
                        if (state is SubCategoryLoading) {
                          print("Loading subcategories...");
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is SubCategoryLoaded) {
                          final subCategories = state.subcategories;
                          print(
                              "Subcategories loaded: ${subCategories.length}");
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DropdownButtonFormField<SubCategory>(
                               dropdownColor: kPrimary,
                        style: TextStyle(color: kWhite, fontSize: 18),
                              isExpanded: true,
                              items: subCategories.map((subCategory) {
                                return DropdownMenuItem(
                                  value: subCategory,
                                  child: Text(subCategory.subcategoryName),
                                );
                              }).toList(),
                              onChanged: (selectedSubCategory) {
                                print(
                                    "Subcategory selected: ${selectedSubCategory?.subcategoryName}");
                                setState(() {
                                  _selectedSubCategory = selectedSubCategory;
                                });
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Select SubCategory',
                                  border: OutlineInputBorder()),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    // Other input fields for product details
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _productNameController,
                        decoration:
                            const InputDecoration(labelText: 'Product Name',border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _wastageController,
                        decoration: const InputDecoration(labelText: 'Wastage',
                        border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter wastage';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _weightController,
                        decoration:
                            const InputDecoration(labelText: 'Weight(g)',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter weight';
                          }
                          return null;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoadingGiftingOptions
                          ? const Center(child: CircularProgressIndicator())
                          : _giftingOptions.isEmpty
                              ? const Text('No gifting options available')
                              : DropdownButtonFormField<String>(
                                 dropdownColor: kPrimary,
                        style: TextStyle(color: kWhite, fontSize: 18),
                                  isExpanded: true,
                                  value: _selectedGifting,
                                  decoration: const InputDecoration(
                                      labelText: 'Gifting',
                                      border: OutlineInputBorder()),
                                  onChanged: (value) {
                                    print('Gifting selected: $value');
                                    setState(() {
                                      _selectedGifting = value;
                                    });
                                  },
                                  items: _giftingOptions
                                      .map(
                                          (gifting) => DropdownMenuItem<String>(
                                                value: gifting,
                                                child: Text(gifting),
                                              ))
                                      .toList(),
                                ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoadingSoulmateOptions
                          ? const Center(child: CircularProgressIndicator())
                          : _soulmateOptions.isEmpty
                              ? const Text('No soulmate options available')
                              : DropdownButtonFormField<String>(
                                 dropdownColor: kPrimary,
                        style: TextStyle(color: kWhite, fontSize: 18),
                                  isExpanded: true,
                                  value: _selectedSoulmate,
                                  decoration: const InputDecoration(
                                      labelText: 'Soulmate',border: OutlineInputBorder()),
                                  onChanged: (value) {
                                    print('Soulmate selected: $value');
                                    setState(() {
                                      _selectedSoulmate = value;
                                    });
                                  },
                                  items: _soulmateOptions
                                      .map((soulmate) =>
                                          DropdownMenuItem<String>(
                                            value: soulmate,
                                            child: Text(soulmate),
                                          ))
                                      .toList(),
                                ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoadingOccasionOptions
                          ? const Center(child: CircularProgressIndicator())
                          : _occasionOptions.isEmpty
                              ? const Text('No occasion options available')
                              : DropdownButtonFormField<String>(
                                 dropdownColor: kPrimary,
                        style: TextStyle(color: kWhite, fontSize: 18),
                                  isExpanded: true,
                                  value: _selectedOccasion,
                                  decoration: const InputDecoration(
                                      labelText: 'Occasion',border: OutlineInputBorder()),
                                  onChanged: (value) {
                                    print('Occasion selected: $value');
                                    setState(() {
                                      _selectedOccasion = value;
                                    });
                                  },
                                  items: _occasionOptions
                                      .map((occasion) =>
                                          DropdownMenuItem<String>(
                                            value: occasion,
                                            child: Text(occasion),
                                          ))
                                      .toList(),
                                ),
                    ),

                    // Karat Dropdown
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<String>(
                         dropdownColor: kPrimary,
                        style: TextStyle(color: kWhite, fontSize: 18),
                        isExpanded: true,
                        value: _selectedKarat,
                        onChanged: (value) {
                          print("Karat selected: $value");
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
                        decoration:
                            const InputDecoration(labelText: 'Select Karat',border: OutlineInputBorder()),
                      ),
                    ),
                    // Image Picker Buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary
                            ),
                            onPressed: () => _pickImages(ImageSource.gallery),
                            child: const Text('Pick Images',style: TextStyle(color: kWhite),),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                             style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary
                            ),
                            onPressed: _captureImage,
                            child: const Text('Capture Image',style: TextStyle(color: kWhite),),
                          ),
                        ],
                      ),
                    ),

                    // Display Selected Images
                    if (_selectedImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          children: _selectedImages.map((image) {
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
                                        _selectedImages.indexOf(image)),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                          
                              backgroundColor: kPrimary,
                              fixedSize: Size(450,55)
                            ),
                        onPressed: _submitProduct,
                        child: const Text('Submit Product',style: TextStyle(color: kWhite,fontSize: 22),),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
