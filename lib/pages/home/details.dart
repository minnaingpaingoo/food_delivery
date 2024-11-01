import 'package:flutter/material.dart';
import 'package:food_delivery/pages/bottom_nav/bottomnav.dart';
import 'package:food_delivery/service/database.dart';
import 'package:food_delivery/service/shared_pref.dart';
import 'package:food_delivery/widget/widget_support.dart';

class Details extends StatefulWidget {

  final String image, name, details, price;
  
  const Details({super.key, required this.image, required this.name, required this.details, required this.price});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int count = 1;
  int totalAmt=0;

  String? id;

  getthesharedpref() async{
    id= await SharedPreferenceHelper().getUserId();
    setState(() {
      
    });
  }

  ontheload() async{
    getthesharedpref();
    setState(() {
      
    });
  }
  @override
  void initState(){
    super.initState();
    ontheload();
    totalAmt = int.parse(widget.price);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: Container(
          margin: const EdgeInsets.only(top: 35, left: 20, right:20,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.black,
                ),
              ),
              Image.network(
                widget.image,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/2.5,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width/1.65,
                    child: Text(
                      widget.name,
                      style: AppWidget.headerTextFieldStyle(),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: (){
                      if(count > 1){
                        --count;
                        totalAmt = totalAmt - int.parse(widget.price);
                      }
                      setState(() {
                        
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ) ,
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                      )
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    count.toString(),
                    style: AppWidget.semiBoldTextFieldStyle(),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: (){
                      ++count;
                      totalAmt = totalAmt + int.parse(widget.price);
                      setState(() {
                        
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ) ,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      )
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Text(
                widget.details,
                maxLines: 3,
                style: AppWidget.lightTextFieldStyle(),
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  Text(
                    "Delivery Time",
                    style: AppWidget.lightTextFieldStyle(),
                  ),
                  const SizedBox(width: 5,),
                  const Icon(
                    Icons.alarm,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 5,),
                  Text(
                    "30 min",
                    style: AppWidget.lightTextFieldStyle(),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Total Price: ",
                          style: AppWidget.semiBoldTextFieldStyle(),
                        ),
                        Text(
                          "\$$totalAmt",
                          style: AppWidget.boldTextFieldStyle(),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap:() async{
                        Map<String, dynamic> addFoodToCart = {
                          "Name": widget.name,
                          "Price": widget.price,
                          "Quantity": count.toString(),
                          "Total": totalAmt.toString(),
                          "Image": widget.image,
                        };
                        await DatabaseMethods().addFoodToCart(addFoodToCart, id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Item is added to the Cart Successfully!!",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                        );
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const BottomNav()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width/2,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              "Add to Card",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppin',
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
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
}