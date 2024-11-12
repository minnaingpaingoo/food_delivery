import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
class DatabaseMethods{
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .set(userInfoMap);
  }

  Future addCategory(String name, String imageUrl) async{
    return await FirebaseFirestore.instance.collection('Categories')
      .add({
        'CategoryName': name,
        'ImageUrl': imageUrl, 
        'Created_At': FieldValue.serverTimestamp(),
      });
  }

  Future updateUserWallet(String id, String amount) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({"Wallet": amount});
  }

  Future updateCategoryImage(String categoryId, String categoryName, String imageUrl) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .update({
        'CategoryName': categoryName,
        'ImageUrl': imageUrl,
    });
  }

  Future updateUserProfile(String id, String url) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({"Profile": url});
  }

  Future updateUserName(String id, String name) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({"Name": name});
  }

  Future updateUserEmail(String id, String email) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({"Email": email});
  }

  Future updateFoodItem(String categoryId, String foodItemId, String name, String price, String details, String imageUrl) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('SubCategory')
      .doc(foodItemId)
      .update({
        'Name': name,
        'Price': price,
        'Details': details,
        'ImageUrl': imageUrl,
      });
  }

  Future<void> updateFoodItemVisibility(String categoryId, String subCategoryId, bool isVisible) async {
    await FirebaseFirestore.instance
        .collection('Categories')
        .doc(categoryId)
        .collection('SubCategory')
        .doc(subCategoryId)
        .update({'isVisible': isVisible});
  }

  Future updateQtyAndTotalOfOrder(String id, String itemId, String newQty, String newTotal) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .collection('Cart')
      .doc(itemId)
      .update({
        'Quantity': newQty,
        'Total': newTotal,
      });
  }

  Future<void> updateDeliveryStatus(String userId, String orderId, String status) async {
    await FirebaseFirestore.instance
        .collection('OrderConfirmed')
        .doc(userId)
        .collection('Orders')
        .doc(orderId)
        .update({'DeliveryStatus': status});
  }
  
  Future<String?> getCategoryIdByName(String categoryName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Categories')
        .where('CategoryName', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // categoryId
    }
    return null; // If no category found
  }

  Future addFoodItem(Map<String, dynamic> userInfoMap, String categoryId) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('SubCategory')
      .add(userInfoMap);
  }

  Future addFoodToCart(Map<String, dynamic> userInfoMap, String id) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .collection("Cart")
      .add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getFoodCart(String id) async{
    return FirebaseFirestore.instance
      .collection("users")
      .doc(id)
      .collection("Cart")
      .snapshots();
  }

  Future deleteCartItem(String id, String itemId) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .collection('Cart')
      .doc(itemId)
      .delete();
  }

  Future deleteCategory(String categoryId) async {
    return await FirebaseFirestore.instance
        .collection('Categories')
        .doc(categoryId)
        .delete();
  }

  Future<void> deleteFoodItem(String categoryId, String foodId) async {
    await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('SubCategory')
      .doc(foodId)
      .delete();
  }

  Future getAllItemsInCart(String id)async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .collection('Cart')
      .get();
  }

  Future getCategorySnapshot()async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .get();
  }

  Stream<List<String>> getCategoryNamesStream() {
    return FirebaseFirestore.instance
        .collection('Categories')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc['CategoryName'] as String; // Assuming 'name' is the field for category name
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getCategoriesStream() {
    return FirebaseFirestore.instance.collection('Categories').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'Id': doc.id,
            'Name': doc['CategoryName'],
            'Image': doc['ImageUrl'],
          };
        }).toList();
      },
    );
  }

  Stream<List<Map<String, dynamic>>> getFoodItemsByCategory(String categoryId) {
    return FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('SubCategory')
      .snapshots()
      .map((snapshot){
        return snapshot.docs.map((doc) {
          return {
            'Id': doc.id,
            'Name': doc['Name'],
            'Image': doc['Image'],
            'Price': doc['Price'],
            'Details': doc['Details'],
            'isVisible': doc['isVisible']
          };
        }).toList();
      });
  }

  Future getSubCategorySnapshot(String categoryId) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('SubCategory')
      .get();
  }

  Future saveConfirmOrder(Map<String, dynamic> orderData, String userId)async{
    return await FirebaseFirestore.instance
      .collection('OrderConfirmed')
      .doc(userId)
      .collection("Orders")
      .add(orderData);
  }

  Future clearCartAfterConfirm(String id, String docId) async{
    return await FirebaseFirestore.instance.
      collection('users')
      .doc(id)
      .collection('Cart')
      .doc(docId)
      .delete();
  }
  
  Future<List<Map<String, dynamic>>> getAllOrderConfirm(String userId) async {
    List<Map<String, dynamic>> allOrders = [];

    try {
      // Get the reference for the user's Order_confirm collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('OrderConfirmed')
          .doc(userId)
          .collection('Orders')
          .get();

      // Loop through each document and add it to the list
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
        orderData['OrderID'] = doc.id; // Optionally, store document ID
        allOrders.add(orderData);
      }
    } catch (e) {
      print("Error fetching order data: $e");
    }
    print(allOrders);
    return allOrders;
  }

  Future<List<Map<String, dynamic>>> getAllConfirmedOrders(String userId) async {

    List<Map<String, dynamic>> allOrders = [];

    try {
      
      // Get all user documents in 'ConfirmOrders'
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('OrderConfirmed')
        .get();
      print("Number of users found: ${usersSnapshot.docs.length}");
      
      for (var doc in usersSnapshot.docs) {
        print(doc.data());  // Log each document's data
      }

      if (usersSnapshot.docs.isEmpty) {
        print("No users found in 'ConfirmOrders'");
        return allOrders;
      }

      //for (var userDoc in usersSnapshot.docs) {
        //String userId = userDoc.id;
        print("Fetching orders for userId: $userId");

        QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('OrderConfirmed')
          .doc(userId)
          .collection('Orders')
          .get();
        print("Number of orders found for user $userId: ${ordersSnapshot.docs.length}");

        if (ordersSnapshot.docs.isEmpty) {
          print("No orders found for user $userId");
        }

        for (var orderDoc in ordersSnapshot.docs) {
          Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
          orderData['UserId'] = userId;
          orderData['OrderId'] = orderDoc.id;
          allOrders.add(orderData);
        }
      //}
    } catch (e) {
      print("Error fetching orders: $e");
    }


     return allOrders;
    
  }


  Future initializeCount(String userId) async {
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart')
        .get();

    return cartSnapshot.docs.length;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('Categories').get();
    return snapshot.docs.map((doc) => {'CategoryId': doc.id, 'Name': doc['CategoryName']}).toList();
  }

  Future<String> uploadImage(File imageFile) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('blogImages/${DateTime.now().toIso8601String()}');
  await ref.putFile(imageFile);
  return await ref.getDownloadURL();
}


  Future<List<Map<String, dynamic>>> getAllConfirmedOrdersForAdmin() async {
    List<Map<String, dynamic>> allOrders = [];

    try {
      // Get all documents in the users collection
      final userDocs = await FirebaseFirestore.instance.collection('users').get();
      print("Number of users found: ${userDocs.docs.length}");

      for (var userDoc in userDocs.docs) {
        try {
          // Navigate to the 'OrderConfirmed' collection and then the 'Orders' subcollection
          final ordersSnapshot = await FirebaseFirestore.instance
              .collection('OrderConfirmed')
              .doc(userDoc.id)
              .collection('Orders')
              .get();

          print("User: ${userDoc.id}, Number of Orders: ${ordersSnapshot.docs.length}");

          for (var orderDoc in ordersSnapshot.docs) {
            // Add each order to the list, including the user ID for tracking
            allOrders.add({
              'userId': userDoc.id,
              'orderId': orderDoc.id,
              ...orderDoc.data(),
            });
          }
        } catch (e) {
          print("Error fetching orders for user ${userDoc.id}: $e");
        }
      }
    } catch (e) {
      print("Error fetching users: $e");
    }

    return allOrders;
  }


}