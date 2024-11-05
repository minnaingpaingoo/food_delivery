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

  setCount(int count){
    _cartCount = count;
  }
  
}