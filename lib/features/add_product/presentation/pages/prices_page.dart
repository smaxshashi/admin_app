import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/constants.dart';
import '../../apis/prices_api.dart';
import '../../data/models/prices.dart';
import '../bloc/login_bloc.dart';

class PricesPage extends StatefulWidget {
  const PricesPage({super.key});

  @override
  State<PricesPage> createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
  late Future<List<MetalPrice>> _prices;
  List<TextEditingController> controllers = [];
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _prices = fetchPrices().then((prices) {
      controllers = List.generate(
        prices.length * 4,
        (index) => TextEditingController(),
      );

      // Set initial values in controllers
      for (var i = 0; i < prices.length; i++) {
        controllers[i * 4].text = prices[i].karat18.toString();
        controllers[i * 4 + 1].text = prices[i].karat14.toString();
        controllers[i * 4 + 2].text = prices[i].karat24.toString();
        controllers[i * 4 + 3].text = prices[i].karat22.toString();
      }
      return prices;
    });
  }

  void _setChanged() {
    setState(() {
      _isChanged = true;
    });
  }

  Future<void> _submitPrices(List<MetalPrice> prices) async {
    bool allSuccess = true;

    for (var price in prices) {
      try {
        await _updatePriceOnServer(price.metalName, '18K', price.karat18);
        await _updatePriceOnServer(price.metalName, '14K', price.karat14);
        await _updatePriceOnServer(price.metalName, '24K', price.karat24);
        await _updatePriceOnServer(price.metalName, '22K', price.karat22);
      } catch (e) {
        allSuccess = false;
        print('Error: $e');
      }
    }

    if (allSuccess) {
      setState(() {
        _isChanged = false;
      });
    } else {
      print('Some prices failed to update.');
    }
  }

  Future<void> _updatePriceOnServer(
    String metalType, String karat, double price) async {
  final String authToken = await _getAuthToken(); // Fetch token from login state
  final url = 'https://api.gehnamall.com/admin/update/price';

  // Create the request body as JSON
  final requestBody = json.encode({
    'metalType': metalType,
    'karat': karat,
    'price': price,
  });

  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: requestBody, // Add the body here
    );

    if (response.statusCode == 200) {
      print('Price updated successfully: $metalType $karat $price');
    } else {
      print('Failed to update price: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('Error updating price: $e');
  }
}

Future<String> _getAuthToken() async {
  // Fetch token from the login state
  final loginState = context.read<LoginBloc>().state;
  if (loginState is LoginSuccess) {
    final String token = loginState.login.token;
    print("Token: $token"); // Log token for debugging
    return token;
  } else {
    throw Exception("User is not logged in");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: k2,
      appBar: AppBar(
        title: const Text(
          'Prices',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: kWhite),
        ),
        backgroundColor: kPrimary,
        elevation: 5,
      ),
      body: FutureBuilder<List<MetalPrice>>(
        future: _prices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            final prices = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("Metal Name")),
                          DataColumn(label: Text('18K')),
                          DataColumn(label: Text('14K')),
                          DataColumn(label: Text('24K')),
                          DataColumn(label: Text('22K')),
                        ],
                        rows: prices.asMap().entries.map((entry) {
                          final index = entry.key;
                          final price = entry.value;

                          return DataRow(cells: [
                            DataCell(Text(price.metalName)),
                            DataCell(
                              TextField(
                                controller: controllers[index * 4],
                                onChanged: (value) {
                                  price.karat18 =
                                      double.tryParse(value) ?? price.karat18;
                                  _setChanged();
                                },
                              ),
                            ),
                            DataCell(
                              TextField(
                                controller: controllers[index * 4 + 1],
                                onChanged: (value) {
                                  price.karat14 =
                                      double.tryParse(value) ?? price.karat14;
                                  _setChanged();
                                },
                              ),
                            ),
                            DataCell(
                              TextField(
                                controller: controllers[index * 4 + 2],
                                onChanged: (value) {
                                  price.karat24 =
                                      double.tryParse(value) ?? price.karat24;
                                  _setChanged();
                                },
                              ),
                            ),
                            DataCell(
                              TextField(
                                controller: controllers[index * 4 + 3],
                                onChanged: (value) {
                                  price.karat22 =
                                      double.tryParse(value) ?? price.karat22;
                                  _setChanged();
                                },
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isChanged ? Colors.lightGreen : Colors.red,
                    ),
                    onPressed: _isChanged
                        ? () {
                            _submitPrices(prices);
                          }
                        : null,
                    child: const Text(
                      'Submit New Price',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
