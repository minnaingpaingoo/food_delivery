import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/widget/widget_support.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {

  final _formKey = GlobalKey<FormState>();
  String? name;
  TextEditingController nameController = TextEditingController();


  Future<void> addCategory() async {
    try {
      await FirebaseFirestore.instance.collection('categories').add({
        'name': name,
        'created_at': FieldValue.serverTimestamp(),
      });

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

  Future<void> editCategory(DocumentSnapshot category) async {
    nameController.text = category['name'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await FirebaseFirestore.instance
                      .collection('categories')
                      .doc(category.id)
                      .update({
                      'name': nameController.text.trim(),
                      });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Category updated successfully!',
                          style: TextStyle(
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                    );
                    nameController.clear();
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error updating category: $e',
                          style: const TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Category deleted successfully!',
            style: TextStyle(
              color: Colors.greenAccent,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting category: $e',
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
      body:Column(
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
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Category List",
              style: AppWidget.boldTextFieldStyle(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection('categories')
                .orderBy('name')
                .snapshots(),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }
                if(snapshot.hasError){
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final List<DocumentSnapshot> categories = snapshot.data!.docs;

                if(categories.isEmpty){
                  return const Center(child: Text("No categories found"));
                }

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index){
                    final Map<String, dynamic> category = categories[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                        category['name'] ?? 'Unnamed Category',
                        style: AppWidget.semiBoldTextFieldStyle(),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: ()=> editCategory(categories[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: ()=> deleteCategory(categories[index].id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ],
      ),
    );
  }
}