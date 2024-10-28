import 'package:flutter/material.dart';
import 'package:food_delivery/widget/widget_support.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int count = 1;
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
              Image.asset(
                "images/burger.png",
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/2.5,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 10,),
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mediiaslda Burger",
                        style: AppWidget.semiBoldTextFieldStyle(),
                      ),
                      Text(
                        "Big Burger",
                        style: AppWidget.headerTextFieldStyle(),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: (){
                      if(count > 1){
                        --count;
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
                  const SizedBox(width: 15),
                  Text(
                    count.toString(),
                    style: AppWidget.semiBoldTextFieldStyle(),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: (){
                      ++count;
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
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
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
                          "\$28",
                          style: AppWidget.boldTextFieldStyle(),
                        ),
                      ],
                    ),
                    Container(
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