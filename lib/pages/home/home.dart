import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/pages/home/details.dart';
import 'package:food_delivery/service/database.dart';
import 'package:food_delivery/service/shared_pref.dart';
import 'package:food_delivery/widget/widget_support.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery/provider/cart_provider.dart';
//import 'package:food_delivery/pages/bottom_nav/bottomnav.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();

}
class _HomeState extends State<Home> {

  //For Select Item to change the color
  bool icecream = false;
  bool pizza = false;
  bool burger = false;
  bool salad = false;

  Stream? foodItemStream;
  String? name;

  getthesharepref()async{
    name = await SharedPreferenceHelper().getUserName();
    if (mounted) {
      setState(() {});
    }
  }

  ontheload() async {
    await getthesharepref();
    foodItemStream = await DatabaseMethods().getFoodItem("Ice-cream");
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState(){
    ontheload();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  Widget allItems () {
    return StreamBuilder(
      stream: foodItemStream,
      builder: (context, AsyncSnapshot snapshot){
        return snapshot.hasData?
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index){
              DocumentSnapshot ds=snapshot.data.docs[index];
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (contex)=> Details(details: ds['Details'], name: ds['Name'], price: ds['Price'], image: ds['Image'],)));
                },
                child: Container(
                  width: 210,
                  padding: const EdgeInsets.all(4),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                ds['Image'],
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Text(
                            ds['Name'],
                            style: AppWidget.semiBoldTextFieldStyle(),
                          ),
                          Text(
                            ds['Details'],
                            style: AppWidget.lightTextFieldStyle(),
                            maxLines: 1,
                          ),
                          Text(
                            "\$"+ ds['Price'],
                            style: AppWidget.semiBoldTextFieldStyle(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ) :
          const Center(child: CircularProgressIndicator());
      }
    );
  }

  Widget allItemsVertically () {
    return StreamBuilder(
      stream: foodItemStream,
      builder: (context, AsyncSnapshot snapshot){
        return snapshot.hasData ?
          SizedBox(
            height: 400,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index){
                DocumentSnapshot ds=snapshot.data.docs[index];
                return GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (contex)=> Details(details: ds['Details'], name: ds['Name'], price: ds['Price'], image: ds['Image'],)));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              ds['Image'],
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5,),
                                Text(
                                  ds['Name'],
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                ),
                                const SizedBox(height: 5,),
                                Text(
                                  ds['Details'],
                                  style: AppWidget.lightTextFieldStyle(),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 5,),
                                Text(
                                  "\$"+ ds['Price'],
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ) :
          const Center(child: CircularProgressIndicator());
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: BottomNav.bottomNavKey,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 20, top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hello, ${name ?? "User"}",
                    style: AppWidget.boldTextFieldStyle(),
                  ),
                  Consumer<CartProvider>(
                    builder: (context, cart, child){
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right:15),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: (){
                                //BottomNav.bottomNavKey.currentState?.switchTab(1);
                              },
                              icon: const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if(cart.cartCount > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  cart.cartCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "Delicious Food",
                style: AppWidget.headerTextFieldStyle(),
              ),
              Text(
                "Discover and Get Great Food",
                style: AppWidget.lightTextFieldStyle(),
              ),
              const SizedBox(
                height: 20,
              ),
              //To Show 4 Items
              Container(
                margin: const EdgeInsets.only(right:20),
                child: showItem(),
              ),
              const SizedBox(
                height: 30,
              ),
              //To Show Horizontal
              SizedBox(
                height: 300,
                child: allItems(),
              ),
              const SizedBox(height: 30),
              //To show Vertical
              allItemsVertically(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () async{
            icecream = true;
            pizza = false;
            salad = false;
            burger = false;
            foodItemStream = await DatabaseMethods().getFoodItem('Ice-cream');
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: icecream ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'images/ice_cream.png',
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async{
            burger = true;
            pizza = false;
            salad = false;
            icecream = false;
            foodItemStream = await DatabaseMethods().getFoodItem('Burger');
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: burger ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'images/burger.png',
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async{
            burger = false;
            pizza = true;
            salad = false;
            icecream = false;
            foodItemStream = await DatabaseMethods().getFoodItem('Pizza');
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: pizza ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'images/pizza.png',
                height: 40,
                width: 40,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async{
            burger = false;
            pizza = false;
            salad = true;
            icecream = false;
            foodItemStream = await DatabaseMethods().getFoodItem('Salad');
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: salad ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'images/salad.png',
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
