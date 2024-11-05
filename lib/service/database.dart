import 'package:cloud_firestore/cloud_firestore.dart';
class DatabaseMethods{
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .set(userInfoMap);
  }

  Future updateUserWallet(String id, String amount) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({"Wallet": amount});
  }

  Future updateUserProfile(String id, String url) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({"Profile": url});
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

  Future addFoodItem(Map<String, dynamic> userInfoMap, String name) async{
    return await FirebaseFirestore.instance
      .collection(name)
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

  Future getAllItemsInCart(String id)async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .collection('Cart')
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