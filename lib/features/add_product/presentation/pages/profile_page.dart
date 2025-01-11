import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gehnaorg/features/add_product/data/models/login.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/constants.dart';

class ProfilePage extends StatefulWidget {
  final Login? loginData;

  const ProfilePage({Key? key, this.loginData}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
   bool isEditing = false;
  List<File?> selectedImages = List.generate(6, (index) => null); // To store images

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int index) async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery); // Open gallery
    if (pickedImage != null) {
      setState(() {
        selectedImages[index] = File(pickedImage.path); // Update the selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: k2,
      appBar: AppBar(
        centerTitle: true,
        title:  Text(
          'Profile',
           style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: kWhite,
          ),
        ),
         backgroundColor: kPrimary,
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit,color: kWhite,),
            onPressed: () {
              setState(() {
                isEditing = !isEditing; // Toggle editing state
              });
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverGrid.builder(
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: isEditing
                      ? () {
                          _pickImage(index); // Open image picker on tap
                        }
                      : null,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: selectedImages[index] != null
                        ? Image.file(
                            selectedImages[index]!,
                            fit: BoxFit.cover,
                          ) // Display selected image
                        : const Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.black,
                            ),
                          ), // Default camera icon
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 20,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _form('Name', isEditing),
                _form('Shop Name', isEditing),
                _form('Shop Address', isEditing),
                _form('Shop Contact', isEditing),
                _form('GSTIN number', isEditing),
                _form('Minimum Order Quantity (MOQ)', isEditing),
                _form('Description', isEditing),
                _form('Return Policy', isEditing),
                _form('Order Number 1', isEditing),
                _form('Order Number 2', isEditing),
                _form('Order Number 3', isEditing),
                _form('Bank Name', isEditing),
                _form('Bank Account Number', isEditing),
                _form('IFSC Code', isEditing),
                _form('UPI ID', isEditing),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary
                    )
                      ,onPressed: () {
                        // Handle logout
                      },
                      child: const Text('Logout',style: TextStyle(
                        color: kWhite
                      ),),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(String labeltext, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        enabled: isEnabled, // Enable or disable based on editing state
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labeltext,
        ),
      ),
    );
  }
}
