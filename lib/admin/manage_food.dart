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
    TextEditingController nameController = TextEditingController(text: foodItem['Name']);
    TextEditingController priceController = TextEditingController(text: foodItem['Price'].toString());
    TextEditingController detailController = TextEditingController(text: foodItem['Details'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Food Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
               TextField(
                controller: detailController,
                decoration: const InputDecoration(labelText: 'Details'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty && detailController.text.isNotEmpty) {
                  
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
                }
                fetchAllFoodItems(); //Refresh after update
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
      body: foodItems.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              var foodItem = foodItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: foodItem['Image'] != null
                    ? Image.network(
                        foodItem['Image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported, size: 60),
                  title: Text(foodItem['Name'] ?? 'No Name'),
                  subtitle: Text("\$${foodItem['Price']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editFoodItem(foodItem),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteFoodItem(foodItem['categoryId'], foodItem['subCategoryId']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
