import 'package:flutter/material.dart';
import 'package:food_delivery/pages/details.dart';
import 'package:food_delivery/widget/widget_support.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 20, top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  "Hello, Min Naing",
                  style: AppWidget.boldTextFieldStyle(),
                ),
                Container(
                  margin: const EdgeInsets.only(right:20),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shopping_cart, color: Colors.white),
                ),
              ]),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (contex)=> const Details()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "images/salad.png",
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                                Text(
                                  "Veggle Taco Mash",
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                ),
                                Text(
                                  "Fresh and Healthy",
                                  style: AppWidget.lightTextFieldStyle(),
                                ),
                                Text(
                                  "\$25",
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(4),
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                "images/salad.png",
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                              Text(
                                "Mix Veg Salad",
                                style: AppWidget.semiBoldTextFieldStyle(),
                              ),
                              Text(
                                "Spicy and Good",
                                style: AppWidget.lightTextFieldStyle(),
                              ),
                              Text(
                                "\$28",
                                style: AppWidget.semiBoldTextFieldStyle(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              //To show Vertical
              Container(
                margin: const EdgeInsets.only(right: 20,),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'images/burger.png',
                          height: 120,
                          width: 120,
                          fit:BoxFit.cover,
                        ),
                        const SizedBox(width: 10,),
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width/2,
                              child: Text(
                                'Mediternamaadfd Burger',
                                style: AppWidget.semiBoldTextFieldStyle(),
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Container(
                              width: MediaQuery.of(context).size.width/2,
                              child: Text(
                                'Very Delicious for all.',
                                style: AppWidget.lightTextFieldStyle(),
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Container(
                              width: MediaQuery.of(context).size.width/2,
                              child: Text(
                                '\$27',
                                style: AppWidget.semiBoldTextFieldStyle(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        
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
          onTap: () {
            icecream = true;
            pizza = false;
            salad = false;
            burger = false;
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
          onTap: () {
            burger = true;
            pizza = false;
            salad = false;
            icecream = false;
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
          onTap: () {
            burger = false;
            pizza = true;
            salad = false;
            icecream = false;
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
          onTap: () {
            burger = false;
            pizza = false;
            salad = true;
            icecream = false;
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
