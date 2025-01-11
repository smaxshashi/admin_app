import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gehnaorg/core/constants/constants.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/login_bloc.dart';

class ProductGridPage extends StatefulWidget {
  @override
  _ProductGridPageState createState() => _ProductGridPageState();
}

class _ProductGridPageState extends State<ProductGridPage> {
  List<dynamic> products = [];
  List<String> categories = [];
  String? selectedCategory;
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  final int size = 10;
  int totalProducts = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProducts();

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
    setState(() {
      isLoading = true;
    });

    String url =
        "https://api.gehnamall.com/admin/products/latest?wholeseller=BANSAL&page=$page&size=$size";

    // Adding category filter if selected
    if (selectedCategory != null) {
      url += "&category=$selectedCategory";
    }

    final dio = Dio();
    final loginState = context.read<LoginBloc>().state;

    if (loginState is LoginSuccess) {
      final String token = loginState.login.token;

      try {
        final response = await dio.get(
          url,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

        if (response.data['status'] == 0) {
          final List<dynamic> newProducts = response.data['products'];
          final int fetchedTotalProducts = response.data['totalProducts'];

          setState(() {
            // Filter products by category if selectedCategory is not null
            if (selectedCategory != null) {
              // Only add products that match the selected category
              products.addAll(newProducts.where(
                  (product) => product['categoryName'] == selectedCategory));
            } else {
              // If no category is selected, add all products
              products.addAll(newProducts);
            }
            page++;
            hasMore =
                newProducts.length == size; // Check if there are more products
            totalProducts =
                fetchedTotalProducts; // Update the total count of products
          });
        } else {
          print("Failed to fetch products: ${response.data['message']}");
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching products')),
        );
      }
    }

    setState(() {
      isLoading = false; // End loading state
    });
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
        backgroundColor: kPrimary,
        elevation: 5,
      ),
      body: Column(
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
              itemCount: products.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < products.length) {
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
                            child: Image.network(
                              product['imageUrls'][0],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              product['productName'] ?? "No Name",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void refreshGrid() {
    setState(() {
      isLoading = true;
      products.clear();
      page = 1;
      hasMore = true;
    });
    fetchProducts();
  }
}

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailPage({required this.product});
  Future<bool> deleteProduct(BuildContext context, String productId) async {
    const String urlBase = "https://api.gehnamall.com/admin/deleteProduct/";
    final String url = "$urlBase$productId";

    final dio = Dio();
    final loginState = context.read<LoginBloc>().state;
    if (loginState is LoginSuccess) {
      final String identity = loginState.login.identity;
      final String token = loginState.login.token;

      try {
        final response = await dio.delete(
          url,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

        if (response.statusCode == 200 && response.data['status'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product deleted successfully!')),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to delete product: ${response.data['message']}')),
          );
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred while deleting product.')),
        );
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['productName'] ?? "Product Details",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product['imageUrls'][0],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text("Product Name: ${product['productName']}",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
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
                        context, product['productId'].toString());
                    if (shouldRefresh) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    'Delete this product',
                    style: TextStyle(color: Colors.red),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _detail(String detailtext) {
  return Text(
    detailtext,
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  );
}
