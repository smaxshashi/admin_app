import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gehnaorg/core/constants/constants.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ProductGridPage extends StatefulWidget {
  @override
  _ProductGridPageState createState() => _ProductGridPageState();
}

class _ProductGridPageState extends State<ProductGridPage> {
  List<dynamic> products = [];
  bool isLoading = false;
  bool hasMore = true;
  int page = 0;
  final int size = 10;
  int totalProducts = 0;
  List<Category> categories = [];
  String selectedCategory = "All"; // Default category

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategoriesList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        fetchProducts();
      }
    });
  }

  Future<void> fetchProducts() async {
    if (isLoading) return; // Prevent multiple simultaneous requests

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final wholesalerId = prefs.getInt('wholesalerId');
    if (wholesalerId == null) {
      throw Exception('wholesalerId not found in shared preferences');
    }

    String url =
        "https://product-service-254137058023.asia-south1.run.app/product/$wholesalerId?page=$page&size=$size";

    // Agar "All" nahi hai toh categoryId add karo
    if (selectedCategory != "All") {
      url +=
          "&categoryId=${categories.firstWhere((cat) => cat.categoryName == selectedCategory).categoryId}";
    }

    final dio = Dio();

    try {
      final response = await dio.get(url);

      if (response.data['status'] == 0) {
        final List<dynamic> newProducts = response.data['products'];

        setState(() {
        
          products.addAll(newProducts);
          page++;
          hasMore = newProducts.length == size;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("Failed to fetch products: ${response.data['message']}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products')),
      );
    }
  }

  Future<List<Category>> fetchCategories({
    required int layoutPosition,
  }) async {
    final dio = Dio(); 
    try {
      final prefs = await SharedPreferences.getInstance();
      final wholesalerId = prefs.getInt('wholesalerId');
      if (wholesalerId == null) {
        throw Exception('wholesalerId not found in shared preferences');
      }

      // Make the API call with adminId
      final response = await dio.get(
        'https://upload-service-254137058023.asia-south1.run.app/upload/$wholesalerId/getCategory',
        queryParameters: {
          'layoutPosition': layoutPosition,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => Category.fromJson(e))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch categories: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  void fetchCategoriesList() async {
    try {
      List<Category> fetchedCategories =
          await fetchCategories(layoutPosition: 1);
      setState(() {
        categories = fetchedCategories;
        categories.insert(
            0,
            Category(
              categoryId: 0,
              categoryName: "All",
              description: "",
              price: 0,
              exfield1: null,
              exfield2: null,
              createDate: DateTime.now(),
              modiDate: DateTime.now(),
              imageUrl: "",
              wholesalerId: 0,
              layoutPosition: 0,
              wholesaler: "",
            ));
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: k2,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Welcome to GehnaMall',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: kWhite,
          ),
        ),
        actions: [
          PopupMenuButton<Category>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (Category category) {
              setState(() {
                selectedCategory = category.categoryName;
                page = 0; 
                hasMore = true;
                products.clear(); 
              });
              fetchProducts(); 
            },
            itemBuilder: (BuildContext context) {
              return categories.map((Category category) {
                return PopupMenuItem<Category>(
                  value: category,
                  child: Text(category.categoryName),
                );
              }).toList();
            },
          ),
        ],
        backgroundColor: kPrimary,
        elevation: 5,
      ),
      body: products.isEmpty && isLoading
          ? _buildShimmerGrid()
          : products.isEmpty
              ? Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: products.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == products.length && hasMore) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final product = products[index];
                          return GestureDetector(
                            onTap: () async {
                              final bool? shouldRefresh = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(product: product),
                                ),
                              );

                              if (shouldRefresh == true) {
                                refreshGrid();
                              }
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10.0),
                                      ),
                                      child: Image.network(
                                        product['imageUrls'][0],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      product['productName'] ?? "No Name",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  void refreshGrid() {
    setState(() {
      products.clear();
      page = 0;
      hasMore = true;
    });
    fetchProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailPage({required this.product});

  Future<bool> deleteProduct(BuildContext context, String productId) async {
    const String urlBase =
        "https://upload-service-254137058023.asia-south1.run.app/upload/delete/";
    final String url = "$urlBase$productId";

    final dio = Dio();

    try {
      final response = await dio.delete(url);

      if (response.statusCode == 200 && response.data['status'] == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product deleted successfully!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to delete product: ${response.data['message']}'),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred while deleting product.')),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product['productName'] ?? "Product Details",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                product['imageUrls'][0],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Product Name: ${product['productName']}",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _detail("Category: ${product['categoryName']}"),
            SizedBox(height: 8),
            _detail("Subcategory: ${product['subCategoryName']}"),
            SizedBox(height: 8),
            _detail("Weight: ${product['weight']}"),
            SizedBox(height: 8),
            _detail("Karat: ${product['karat']}"),
            SizedBox(height: 8),
            _detail("Occasion: ${product['occasion']}"),
            SizedBox(height: 8),
            _detail("Soulmate: ${product['soulmateName']}"),
            SizedBox(height: 8),
            _detail("Gifting: ${product['giftingName']}"),
            SizedBox(height: 16),
            _detail(
                "Description: ${product['description'] ?? 'No description'}"),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final shouldRefresh = await deleteProduct(
                    context,
                    product['productId'].toString(),
                  );
                  if (shouldRefresh) {
                    Navigator.pop(context, true);
                  }
                },
                child: Text(
                  'Delete this product',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _detail(String detailText) {
  return Text(
    detailText,
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  );
}
Widget _buildShimmerGrid() {
  return GridView.builder(
    padding: EdgeInsets.all(8.0),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // 
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      childAspectRatio: 0.8,
    ),
    itemCount: 6, // Shimmer ke liye 6 empty items
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10.0)),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 15,
                width: 100,
                color: Colors.white,
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
