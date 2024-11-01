import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
    
class ConfirmOrder extends StatefulWidget {

  final Map<String, dynamic> orderData;

  const ConfirmOrder({super.key, required this.orderData});

  @override
  State<ConfirmOrder> createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {

  bool showDetails = false;

  void toggleDetails() {
    setState(() {
      showDetails = !showDetails;
    });
  }

  Future<void> generateVoucherPDF() async {
    final pdf = pw.Document();

    // Create PDF content
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Order Voucher', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Name: ${widget.orderData['Name']}'),
            pw.Text('Email: ${widget.orderData['Email']}'),
            pw.Text('Total Price: \$${widget.orderData['TotalPrice']}'),
            pw.SizedBox(height: 20),
            pw.Text('Order Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ...widget.orderData['Items'].map<pw.Widget>((item) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Food: ${item['FoodName']}'),
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

    // Print or Save the PDF
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'OrderVoucher.pdf');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Confirmed Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: toggleDetails,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${widget.orderData['OrderID']}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Price: \$${widget.orderData['TotalPrice']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: generateVoucherPDF,
                        child: const Text('Print Voucher'),
                      ),
                      if (showDetails) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Order Details:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        for (var item in widget.orderData['Items'])
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Food: ${item['FoodName']}'),
                                Text('Quantity: ${item['Quantity']}'),
                                Text('Total: \$${item['TotalPrice']}'),
                              ],
                            ),
                          ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}