import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery/service/database.dart';
import 'package:intl/intl.dart';

class OrderConfirm extends StatefulWidget {
  const OrderConfirm({super.key});

  @override
  State<OrderConfirm> createState() => _OrderConfirmState();
}

class _OrderConfirmState extends State<OrderConfirm> {
  List<Map<String, dynamic>> confirmedOrders = [];
  List<bool> showDetails = [];

  @override
  void initState() {
    super.initState();
    fetchConfirmedOrders();
  }

  Future<void> fetchConfirmedOrders() async {
    try {
      List<Map<String, dynamic>> orders = await DatabaseMethods().getAllConfirmedOrdersForAdmin();
      setState(() {
        confirmedOrders = orders;
        showDetails = List<bool>.filled(orders.length, false);
        print(confirmedOrders);
      });
    } catch (e) {
      print("Error fetching confirmed orders: $e");
    }
  }

  void toggleDetails(int index) {
    setState(() {
      showDetails[index] = !showDetails[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Orders Confirmed List",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: confirmedOrders.isEmpty
          ? const Center(child: Text("No Orders Found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ExpansionPanelList(
                expandedHeaderPadding: const EdgeInsets.all(0),
                expansionCallback: (int index, bool isExpanded) {
                  toggleDetails(index);
                },
                children: confirmedOrders.asMap().entries.map<ExpansionPanel>((entry) {
                  int index = entry.key;
                  Map<String, dynamic> orderData = entry.value;

                  // Format the OrderDate
                  String formattedDate = '';
                  if (orderData['OrderDate'] != null) {
                    DateTime orderDate = (orderData['OrderDate'] as Timestamp).toDate();
                    formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(orderDate);
                  }

                  return ExpansionPanel(
                    isExpanded: showDetails[index],
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            'Order ID: ${orderData['orderId']?.substring(0, 10)}...',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${orderData['Name'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Date & Time: $formattedDate',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Total Price: \$${orderData['TotalPrice'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Delivery Status: ${orderData['DeliveryStatus'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Details:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(orderData['Items']?.length ?? 0, (itemIndex) {
                            Map<String, dynamic> item = orderData['Items'][itemIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Item Name: ${item['FoodName'] ?? 'N/A'}'),
                                  Text('Price: \$${item['Price'] ?? 'N/A'}'),
                                  Text('Quantity: ${item['Quantity'] ?? 'N/A'}'),
                                  Text('Total: \$${item['TotalPrice'] ?? 'N/A'}'),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: orderData['DeliveryStatus'] == 'Done'
                              ? [
                                  const Text(
                                    "Delivery Completed",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ]
                              : [
                                  ElevatedButton(
                                    onPressed: () async {
                                      bool confirmDone = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Confirm Done"),
                                            content: const Text("Are you sure you want to confirm delivery done?"),
                                            actions: [
                                              TextButton(
                                                child: const Text("No"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(false); // Return false if canceled
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("Yes"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(true); // Return true if confirmed
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmDone) {
                                        await DatabaseMethods().updateDeliveryStatus(orderData['userId'], orderData['orderId'], 'Done');

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Delivery is Done!!",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.greenAccent,
                                              ),
                                            ),
                                          ),
                                        );

                                        // Refresh the state after updating the delivery status
                                        setState(() {
                                          orderData['DeliveryStatus'] = 'Done';
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text('Delivery Done'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      bool confirmCancel = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Confirm Cancel"),
                                            content: const Text("Are you sure you want to cancel delivery?"),
                                            actions: [
                                              TextButton(
                                                child: const Text("No"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(false); // Return false if canceled
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("Yes"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(true); // Return true if confirmed
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmCancel) {
                                        await DatabaseMethods().updateDeliveryStatus(orderData['userId'], orderData['orderId'], 'Canceled');

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Delivery is Cancel!!",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ),
                                        );

                                        // Refresh the state after updating the delivery status
                                        setState(() {
                                          orderData['DeliveryStatus'] = 'Canceled';
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
