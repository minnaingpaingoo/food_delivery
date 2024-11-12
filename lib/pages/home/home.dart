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

  String? selectedCategory;

  String? name;

  Stream<List<Map<String, dynamic>>>? foodItemStream;


  getthesharepref()async{
    name = await SharedPreferenceHelper().getUserName();
    if (mounted) {
      setState(() {});
    }
  }

  ontheload() async {
    await getthesharepref();

    var firstCategorySnapshot = await FirebaseFirestore.instance
      .collection('Categories')
      .limit(1)
      .get();

    if (firstCategorySnapshot.docs.isNotEmpty) {
      // Set selectedCategory and load the food items for this category
      var firstCategory = firstCategorySnapshot.docs.first.data();
      selectedCategory = firstCategory['Name'];
      foodItemStream = DatabaseMethods().getFoodItemsByCategory(firstCategorySnapshot.docs.first.id);
    }

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


  Widget allItems() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: foodItemStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
           return const Center(child: Text("No food items available"));
        }
        
        // Filter items where isVisible is true
        var items = snapshot.data!.where((item) => item['isVisible'] == true).toList();
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: items.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var item = items[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Details(
                      details: item['Details'],
                      name: item['Name'],
                      price: item['Price'],
                      image: item['Image'],
                    ),
                  ),
                );
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
                              item['Image'],
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['Name'],
                          style: AppWidget.semiBoldTextFieldStyle(),
                        ),
                        Text(
                          item['Details'],
                          style: AppWidget.lightTextFieldStyle(),
                          maxLines: 1,
                        ),
                        Text(
                          "\$" + item['Price'],
                          style: AppWidget.semiBoldTextFieldStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget allItemsVertically() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: foodItemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No food items available"));
        }

        // Filter items where isVisible is true
        var items = snapshot.data!.where((item) => item['isVisible'] == true).toList();
        if(items.length < 0){
          return const Center(child: Text("No food items available"));
        }else{
          return SizedBox(
            height: 400,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                var item = items[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Details(
                          details: item['Details'],
                          name: item['Name'],
                          price: item['Price'],
                          image: item['Image'],
                        ),
                      ),
                    );
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
                              item['Image'],
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
                                const SizedBox(height: 5),
                                Text(
                                  item['Name'],
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item['Details'],
                                  style: AppWidget.lightTextFieldStyle(),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "\$" + item['Price'],
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
              },
            ),
          );
        }  
      },
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseMethods().getCategoriesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No Categories Found");
        }

        var categories = snapshot.data!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: categories.map((category) {
            bool isSelected = category['Name'] == selectedCategory; // Track selected category

            return GestureDetector(
              onTap: () async {
                setState(() {
                  selectedCategory = category['Name'];
                });
                foodItemStream = DatabaseMethods().getFoodItemsByCategory(category['Id']);
              },
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    category['Image'],
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

}
