import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future updateFoodItem(String categoryId, String foodItemId, String name, String price, String details) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('SubCategory')
      .doc(foodItemId)
      .update({
        'Name': name,
        'Price': price,
        'Details': details,
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

  Future<Stream<QuerySnapshot>> getFoodItem(String name) async{
    return FirebaseFirestore.instance.collection(name).snapshots();
  }

  Future addFoodToCart(Map<String, dynamic> userInfoMap, String id) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .collection("Cart")
      .add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getFoodCart(String id) async{
    return FirebaseFirestore.instance.collection("users").doc(id).collection("Cart").snapshots();
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

  Future getSubCategorySnapshot(String categoryId) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('SubCategory')
      .get();
  }

  Future saveConfirmOrder(Map<String, dynamic> orderData, String userId)async{
    return await FirebaseFirestore.instance
      .collection('ConfirmOrders')
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
          .collection('ConfirmOrders')
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

}