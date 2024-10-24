import 'package:flutter/material.dart';
class AppWidget{

  static TextStyle boldTextFieldStyle(){
    return const TextStyle(
              color: Colors.black,
              fontSize:20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppin',
            );
  }

  static TextStyle HeaderTextFieldStyle(){
    return const TextStyle(
              color: Colors.black,
              fontSize:24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppin',
            );
  }

  static TextStyle LightTextFieldStyle(){
    return const TextStyle(
              color: Colors.black38,
              fontSize:15,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppin',
            );
  }

  static TextStyle semiBoldTextFieldStyle(){
    return const TextStyle(
              color: Colors.black,
              fontSize:18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppin',
            );
  }

}