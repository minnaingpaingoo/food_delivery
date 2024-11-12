import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/provider/cart_provider.dart';
import 'package:food_delivery/service/database.dart';
import 'package:food_delivery/service/shared_pref.dart';
import 'package:food_delivery/widget/widget_support.dart';
import 'package:provider/provider.dart';


class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {

  Stream? foodStream;
  String? id, wallet, name, email;
  int total = 0, amount = 0 ;
  Timer? timer;

  void startTimer() {
    timer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          amount = total;
        });
      }
    });
  }

  getthesharedpref() async{
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    if (mounted) {
      setState(() {});
    }
  }

  ontheload() async{
    await getthesharedpref();
    foodStream = await DatabaseMethods().getFoodCart(id!);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    ontheload();
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
  
  Future<void> confirmOrder() async {
    List<Map<String, dynamic>> orderItems = [];

    // Get all items in the cart and save them in orderItems list
    QuerySnapshot cartSnapshot = await DatabaseMethods().getAllItemsInCart(id!);
    for (var doc in cartSnapshot.docs) {
      orderItems.add({
        'FoodName': doc['Name'],
        'Price': doc['Price'],
        'Quantity': doc['Quantity'],
        'TotalPrice': doc['Total']
      });
    }

    // Create the order data
    Map<String, dynamic> orderData = {
      'OrderID':"",
      'Name': name,
      'Email': email,
      'TotalPrice': total.toString(),
      'OrderDate': DateTime.now().toLocal(),
      'DeliveryStatus': "Pending",
      'Items': orderItems
    };

    // Save order to 'ConfirmOrders' collection in Firestore
    await DatabaseMethods().saveConfirmOrder(orderData, id!);
    // Clear cart after order is confirmed
    for (var doc in cartSnapshot.docs) {
      await DatabaseMethods().clearCartAfterConfirm(id!, doc.id);
      Provider.of<CartProvider>(context, listen: false).resetCart();
    }

    setState(() {
      total = 0;
    });
    // Change the total to 0
  }

  void showEditQuantityDialog(DocumentSnapshot item) {

    final TextEditingController quantityController = TextEditingController(text: item['Quantity']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text("Edit Quantity"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    hintText: "Enter new quantity",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Update"),
                onPressed: () async {
                  int newQuantity = int.parse(quantityController.text);
                  if(newQuantity > 0){
                     int newTotal = newQuantity * int.parse(item['Price']);
          
                    // Update the quantity and total in Firestore
                    await DatabaseMethods().updateQtyAndTotalOfOrder(id!, item.id, newQuantity.toString(), newTotal.toString());
            
                    // Rebuild the widget tree to reflect the updated total
                    setState(() {});
            
                    Navigator.of(context).pop();
                  }else{
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Invalid Quantity"),
                          content: const Text("Please enter a quantity of at least 1."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteCartItem(String itemId) async {
    
    await DatabaseMethods().deleteCartItem(id!, itemId);
    Provider.of<CartProvider>(context, listen: false).removeToCart(1);

    setState(() {});
  }

  Widget foodCart () {
    return StreamBuilder(
      stream: foodStream,
      builder: (context, AsyncSnapshot snapshot){
        total = 0; //Reset total before adding each item
        return snapshot.hasData ?
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index){
              DocumentSnapshot ds=snapshot.data.docs[index];
              total = total + int.parse(ds['Total']);
              return Container(
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            // Edit icon
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  showEditQuantityDialog(ds);
                                },
                              ),
                              // Delete icon
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteCartItem(ds.id);
                                },
                              ),
                          ],
                        ),
                        const SizedBox(width: 20,),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            ds['Image'],
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                ds['Name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ds['Quantity']+" * \$"+ds['Price']+" = \$"+ds['Total'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
        )
        : const Center(child: CircularProgressIndicator());
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        padding: const EdgeInsets.only(top: 40,),
        child: Column(
          children: [
            Material(
              elevation: 2.0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Center(
                  child: Text(
                    "Food Cart",
                    style: AppWidget.headerTextFieldStyle(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            //Added Food Cart Widget
            Expanded(
              flex: 10,
              child: SizedBox(
                height: MediaQuery.of(context).size.height/2,
                child: foodCart(),
              ),
            ),
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Price",
                    style: AppWidget. boldTextFieldStyle(),
                  ),
                  Text(
                    "\$"+ total.toString(),
                    style: AppWidget.semiBoldTextFieldStyle(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            GestureDetector(
              onTap:() async{
                if(amount > int.parse(wallet!)){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Your wallet is not enough to checkout.!!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  );
                }else if(total == 0){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Add Your Favourite Food to the card to checkout.!!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  );
                }else{
                  int remainingAmt = int.parse(wallet!) - amount;
                  await DatabaseMethods().updateUserWallet(id!, remainingAmt.toString());
                  await SharedPreferenceHelper().saveUserWallet(remainingAmt.toString());
                  await confirmOrder();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Your order is confirmed and payment is successully!!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: const Center(
                  child: Text(
                    "CheckOut",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}