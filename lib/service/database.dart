import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .set(userInfoMap);
  }

  updateUserWallet(String id, String amount) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({"Wallet": amount});
  }

  updateUserProfile(String id, String url) async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .update({"Profile": url});
  }

  updateQtyAndTotalOfOrder(String id, String itemId, String newQty, String newTotal) async{
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

  deleteCartItem(String id, String itemId) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .collection('Cart')
      .doc(itemId)
      .delete();
  }

  getAllItemsInCart(String id)async{
    return await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .collection('Cart')
      .get();
  }

  saveConfirmOrder(Map<String, dynamic> orderData)async{
    return await FirebaseFirestore.instance.collection('ConfirmOrders').add(orderData);
  }

  clearCartAfterConfirm(String id, String docId) async{
    return await FirebaseFirestore.instance.
      collection('users')
      .doc(id)
      .collection('Cart')
      .doc(docId)
      .delete();
  }
}