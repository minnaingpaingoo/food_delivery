import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier{
  int _cartCount = 0;

  int get cartCount => _cartCount;

  void addToCart(int itemCount){
    _cartCount += itemCount;
    notifyListeners();
  }

  void removeToCart(int itemCount){
    _cartCount -= itemCount;
    notifyListeners();
  }

  void resetCart(){
    _cartCount = 0;
    notifyListeners();
  }

  Future<void> initializeCount(String userId) async {
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart')
        .get();

    _cartCount= cartSnapshot.docs.length;
  }
}