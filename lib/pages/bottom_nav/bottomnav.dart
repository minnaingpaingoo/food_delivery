import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/pages/home/home.dart';
import 'package:food_delivery/pages/home/order.dart';
import 'package:food_delivery/pages/profile/profile.dart';
import 'package:food_delivery/pages/home/wallet.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  //static final GlobalKey<BottomNavState> bottomNavKey = GlobalKey<BottomNavState>();

  @override
  State<BottomNav> createState() => BottomNavState();
}

class BottomNavState extends State<BottomNav> {

  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  late Home homepage;
  late Profile profile;
  late Orders orders;
  late Wallet wallet;

  @override
  void initState(){
    homepage = const Home();
    orders = const Orders();
    profile = const Profile();
    wallet = const Wallet();
    pages = [homepage, orders, wallet, profile];
    super.initState();
  }

  // void switchTab(int index) {
  //   setState(() {
  //     currentTabIndex = index;
  //   });
  // }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.black,
        height: 65,
        backgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index){
          setState(() {
            currentTabIndex = index;
          });
        },
        items:const [
          Icon(
            Icons.home_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.wallet_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.person_outline,
            color: Colors.white,
          ),
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}