import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_delivery/service/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:food_delivery/widget/widget_support.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {

  final _formKey = GlobalKey<FormState>();
  String? name;
  File? _imageFile;
  TextEditingController nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Method to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  // Method to upload image and get the download URL
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;
    try {
      String fileName = 'Categories/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child(fileName)
        .putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
      return null;
    }
  }

  Future<void> addCategory() async {
    String? imageUrl = await _uploadImage();
    try {
      await DatabaseMethods().addCategory(name!, imageUrl!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Category added successfully!',
            style: TextStyle(
              color: Colors.greenAccent,
            ),
          ),
        ),
      );

      nameController.clear();
      setState(() {
        _imageFile = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error adding category: $e',
            style: const TextStyle(
              color: Colors.redAccent,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Color(0xFF373866),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Add Category",
          style: AppWidget.headerTextFieldStyle(),
        ),
      ),
      body:SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Form(
              key: _formKey,
              child: Container(
                margin:const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Category Name",
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
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Category Name",
                          hintStyle: AppWidget.lightTextFieldStyle(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: _pickImage,
                      child: _imageFile != null
                          ? Image.file(_imageFile!, height: 150, width: 150, fit: BoxFit.cover)
                          : Container(
                              height: 150,
                              width: 150,
                              color: Colors.grey[200],
                              child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
                            ),
                    ),
                    const SizedBox(height: 30.0,),
                    Center(
                      child: GestureDetector(
                        onTap:() async{
                          if(_formKey.currentState!.validate()){
                            name = nameController.text.trim();
                            await addCategory();
                          }
                        },
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
          ],
        ),
      ),
    );
  }
}