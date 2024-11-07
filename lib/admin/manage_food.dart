import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/service/database.dart';

class ManageFood extends StatefulWidget {
  const ManageFood({super.key});

  @override
  State<ManageFood> createState() => _ManageFoodState();
}

class _ManageFoodState extends State<ManageFood> {
 
  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    fetchAllFoodItems();
  }

  Future<void> fetchAllFoodItems() async {

    QuerySnapshot categoriesSnapshot = await DatabaseMethods().getCategorySnapshot();

    List<Map<String, dynamic>> items = [];

    for (var category in categoriesSnapshot.docs) {

      String categoryId = category.id;

      QuerySnapshot subCategorySnapshot = await DatabaseMethods().getSubCategorySnapshot(categoryId);

      for (var foodItem in subCategorySnapshot.docs) {
        var itemData = foodItem.data() as Map<String, dynamic>;
        itemData['subCategoryId'] = foodItem.id;
        itemData['categoryId'] = categoryId;
        items.add(itemData);
      }
    }

    setState(() {
      foodItems = items;
    });
  }

  Future<void> toggleVisibility(String categoryId, String subCategoryId, bool currentVisibility) async {
    await DatabaseMethods().updateFoodItemVisibility(categoryId, subCategoryId, !currentVisibility);
    fetchAllFoodItems(); // Refresh after update
  }

  // Function to delete a food item
  Future<void> deleteFoodItem(String categoryId, String foodId) async {
    await DatabaseMethods().deleteFoodItem(categoryId, foodId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Food item deleted successfully!",
          style: TextStyle(color: Colors.greenAccent),
        ),
      ),
    );
    fetchAllFoodItems(); // Refresh after deletion
  }

  // Function to edit a food item (name and price here for simplicity)
  void editFoodItem(Map<String, dynamic> foodItem) {
    final formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController(text: foodItem['Name']);
    TextEditingController priceController = TextEditingController(text: foodItem['Price'].toString());
    TextEditingController detailController = TextEditingController(text: foodItem['Details'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Food Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Please enter a price greater than 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: detailController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Details'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter details';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await DatabaseMethods().updateFoodItem(
                    foodItem['categoryId'],
                    foodItem['subCategoryId'],
                    nameController.text.trim(),
                    priceController.text.trim(),
                    detailController.text.trim(),
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Food item updated successfully!",
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  );
                  fetchAllFoodItems(); // Refresh after update
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Food'),
        centerTitle: true,
      ),
      body: 
      foodItems.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              var foodItem = foodItems[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Material(
                  color: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.grey.withOpacity(0.2),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    leading: foodItem['Image'] != null
                      ? Image.network(
                          foodItem['Image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported, size: 60),
                    title: Text(
                      foodItem['Name'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("\$${foodItem['Price']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: foodItem['isVisible'] ?? true,
                          onChanged: (value) {
                            toggleVisibility(foodItem['categoryId'], foodItem['subCategoryId'], foodItem['isVisible'] ?? true);
                          },
                          activeColor: Colors.green,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editFoodItem(foodItem),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool confirmDeleteFoodItem = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm Delete Item"),
                                  content: const Text("Are you sure you want to delete this food item?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("No"),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Yes"),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDeleteFoodItem) {
                              deleteFoodItem(foodItem['categoryId'], foodItem['subCategoryId']);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
