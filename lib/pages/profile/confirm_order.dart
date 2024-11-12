import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/service/database.dart';
import 'package:food_delivery/service/shared_pref.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ConfirmOrder extends StatefulWidget {
  const ConfirmOrder({super.key});

  @override
  State<ConfirmOrder> createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  List<Map<String, dynamic>> ordersData = [];
  List<bool> showDetails = [];
  String? id;

  Future<void> getSharedPref() async {
    id = await SharedPreferenceHelper().getUserId();
  }

  Future<void> loadOrders() async {
    await getSharedPref();
    await showOrderDetails();
  }

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> showOrderDetails() async {
    if (id == null) {
      print("User ID is null. Cannot retrieve order data.");
      return;
    }

    try {
      ordersData = await DatabaseMethods().getAllOrderConfirm(id!);
      // Initialize the list with `false` values for all entries in `ordersData`
      showDetails = List.generate(ordersData.length, (index) => false);
      setState(() {}); // Update UI after fetching data
    } catch (e) {
      print("Error fetching order data: $e");
    }
  }

  // Toggle function for individual order detail visibility
  void toggleDetails(int index) {
    setState(() {
      showDetails[index] = !showDetails[index];
    });
  }

  Future<void> generateVoucherPDF(Map<String, dynamic> orderData) async {
    final pdf = pw.Document();

    // Format the OrderDate
    String formattedDate = '';
    if (orderData['OrderDate'] != null) {
      DateTime orderDate = (orderData['OrderDate'] as Timestamp).toDate();
      formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(orderDate);
    }

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Order Voucher', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Order ID: ${orderData['OrderID']}'),
            pw.Text('Date & Time: $formattedDate'),
            pw.Text('Name: ${orderData['Name']}'),
            pw.Text('Email: ${orderData['Email']}'),
            pw.Text('Total Price: \$${orderData['TotalPrice']}'),
            pw.SizedBox(height: 20),
            pw.Text('Order Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ...orderData['Items'].map<pw.Widget>((item) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Item Name: ${item['FoodName']}'),
                pw.Text('Price: \$${item['Price']}'),
                pw.Text('Quantity: ${item['Quantity']}'),
                pw.Text('Total: \$${item['TotalPrice']}'),
                pw.SizedBox(height: 10),
              ],
            )),
          ],
        ),
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'OrderVoucher.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Confirmed Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ordersData.isEmpty
          ? const Center(child: Text("No Orders Found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ExpansionPanelList(
                expandedHeaderPadding: const EdgeInsets.all(0),
                expansionCallback: (int index, bool isExpanded) {
                  toggleDetails(index);
                },
                children: ordersData.asMap().entries.map<ExpansionPanel>((entry) {
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
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            'Order ID: ${orderData['OrderID']?.substring(0,10)}...',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Date & Time: $formattedDate',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total Price: \$${orderData['TotalPrice']}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Delivery Status: ${orderData['DeliveryStatus']}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () => generateVoucherPDF(orderData),
                            child: const Text('Print Voucher'),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Order Details:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: orderData['Items'].map<Widget>((item) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Item Name: ${item['FoodName']}'),
                                    Text('Price: \$${item['Price']}'),
                                    Text('Quantity: ${item['Quantity']}'),
                                    Text('Total: \$${item['TotalPrice']}'),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
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
