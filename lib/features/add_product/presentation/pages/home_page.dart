import 'package:flutter/material.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/user_info.dart';
import 'package:gehnaorg/widget/home_grid.dart';
import '../../../../core/constants/constants.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Track the selected index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: _getBody(), // Dynamically load body based on selected index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Set the current index
        selectedItemColor: kPrimary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
         
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });

          if (index == 1) {
            // Modal Bottom Sheet for Add
            showModalBottomSheet(
              backgroundColor: kPrimary,
              context: context,
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add, color: kWhite),
                      title: const Text(
                        'Add Products',
                        style: TextStyle(color: kWhite),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close the bottom sheet
                        Navigator.pushNamed(context, '/add_product');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add_card, color: kWhite),
                      title: const Text(
                        'Add Lightweight Products',
                        style: TextStyle(color: kWhite),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close the bottom sheet
                        Navigator.pushNamed(context, '/light_weight');
                      },
                    ),
                     ListTile(
                      leading: const Icon(Icons.branding_watermark_rounded, color: kWhite),
                      title: const Text(
                        'Banner',
                        style: TextStyle(color: kWhite),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close the bottom sheet
                        Navigator.pushNamed(context, '/others');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.text_snippet, color: kWhite),
                      title: const Text(
                        'Testimonial',
                        style: TextStyle(color: kWhite),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close the bottom sheet
                        Navigator.pushNamed(context, '/testi');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.price_change, color: kWhite),
                      title: const Text(
                        'Prices',
                        style: TextStyle(color: kWhite),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close the bottom sheet
                        Navigator.pushNamed(context, '/prices');
                      },
                    ),
                  ],
                );
              },
            );
          } 
        },
      ),
    );
  }

  Widget _getBody() {
    // Return the body widget based on the selected index
    switch (_currentIndex) {
      case 0:
        return ProductGridPage(); // Home Page
      case 2:
        return const UserInfo(); // Orders Page
      case 3:
        return  ProfilePage(); // Profile Page
      default:
        return ProductGridPage(); // Default to Home Page
    }
  }
}
