import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/service/database.dart';
import 'package:food_delivery/widget/widget_support.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {

  List<String> foodItems = [];
  String? value;
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    getCategories(); // Fetch categories when the widget is initialized
  }

  Future<void> getCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('Categories').get();
      setState(() {
        foodItems = querySnapshot.docs.map((doc) => doc['CategoryName'] as String).toList();
      });
    } catch (e) {
      print("Error getting categories: $e");
    }
  }

  Future getImage() async{
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    setState(() {
      // ignore: unnecessary_null_comparison
      selectedImage = image != null ? File(image.path) : null;
    });
  }

  uploadItem() async{
    if(_formKey.currentState!.validate() && selectedImage!=null){
      
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child("blogImages").child(addId);
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      
      var downloadUrl = await(await task).ref.getDownloadURL();

      Map<String, dynamic> addItem = {
        "Image": downloadUrl,
        "Name": nameController.text,
        "Price": priceController.text,
        "Details": detailsController.text,
        "isVisible": true,
      };

      String? categoryId = await DatabaseMethods().getCategoryIdByName(value!);

      await DatabaseMethods().addFoodItem(addItem, categoryId!).then((value){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Food Item has been added successfully!!",
              style: TextStyle(
                fontSize: 20,
                color: Colors.greenAccent,
              ),
            ),
          ),
        );
        nameController.clear();
        priceController.clear();
        detailsController.clear();
        selectedImage = null;
        setState(() {
          selectedImage = null;
          value = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Add Food Item",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin:const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upload the Item Picture",
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                selectedImage == null ?
                GestureDetector(
                  onTap: (){
                    getImage();
                  },
                  child: Center(
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ) :
                Center(
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  "Item Name",
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: nameController,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter item name' : null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Item Name",
                      hintStyle: AppWidget.lightTextFieldStyle(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  "Item Price",
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    validator: (value){
                       if (value == null || value.trim().isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Please enter a price greater than 0';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Item Price",
                      hintStyle: AppWidget.lightTextFieldStyle(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  "Item Details",
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    maxLines: 6,
                    controller: detailsController,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter item details' : null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Item Details",
                      hintStyle: AppWidget.lightTextFieldStyle(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Select Category",
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color:const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      items: foodItems
                      .map((item)=> DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value){
                        setState(() {
                          this.value = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a category' : null,
                      dropdownColor: Colors.white,
                      hint: const Text("Select Category"),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                      value: value,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0,),
                GestureDetector(
                  onTap: (){
                    uploadItem();
                  },
                  child: Center(
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}