import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:food_delivery/service/database.dart';
import 'package:food_delivery/service/shared_pref.dart';
import 'package:food_delivery/widget/app_constant.dart';
import 'package:food_delivery/widget/widget_support.dart';
import 'package:http/http.dart' as http;

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {

  Map<String, dynamic>? paymentIntent;

  String? id;
  String? wallet;
  int? totalAmt;
  TextEditingController amountcontroller = TextEditingController();

  bool isLoading = true;

  getthesharedpref() async{
    wallet = await SharedPreferenceHelper().getUserWallet();
    id = await SharedPreferenceHelper().getUserId();
    setState(() {
      isLoading = false;
    });
  }

  ontheload() async{
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState(){
    ontheload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : wallet == null ?
      const Center(child: Text("No wallet data found.")) :
      Container(
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 2.0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Center(
                  child: Text(
                    "Wallet",
                    style: AppWidget.headerTextFieldStyle(),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
              child: Row(
                children: [
                  Image.asset(
                    "images/wallet.png",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    width: 40.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Wallet",
                        style: AppWidget.lightTextFieldStyle(),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "\$${wallet!}",
                        style: AppWidget.boldTextFieldStyle(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "Add money",
                style: AppWidget.semiBoldTextFieldStyle(),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap:(){
                    makePayment('100');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE9E2E2)),
                      borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "\$" + "100",
                      style: AppWidget.semiBoldTextFieldStyle(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap:(){
                    makePayment('500');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE9E2E2)),
                      borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "\$" + "500",
                      style: AppWidget.semiBoldTextFieldStyle(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap:(){
                    makePayment('1000');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE9E2E2)),
                      borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "\$" + "1000",
                      style: AppWidget.semiBoldTextFieldStyle(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap:(){
                    makePayment('2000');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE9E2E2)),
                      borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "\$" + "2000",
                      style: AppWidget.semiBoldTextFieldStyle(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50.0,
            ),
            GestureDetector(
              onTap: (){
                openEdit();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0xFF008080),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "Add Money",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment(String amount) async{
    try{
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance
        .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
            // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
            style: ThemeMode.dark,
            merchantDisplayName: 'MinNaing')
        ).then((value){}
      );

      //Display payment sheet
      
      displayPaymentSheet(amount);

    }catch(e,s){
      print('exception: $e$s');
    }
  }

  displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        totalAmt = int.parse(wallet!) + int.parse(amount);
        await SharedPreferenceHelper().saveUserWallet(totalAmt.toString());
        await DatabaseMethods().UpdateUserWallet(id!, totalAmt.toString());
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Text("Payment Successfull"),
                  ],
                ),
              ],
            ),
          ),
        );
        await getthesharedpref();
        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Cancelled "),
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  Future openEdit() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.cancel),
                  ),
                  const SizedBox(
                    width: 60.0,
                  ),
                  const Center(
                    child: Text(
                      "Add Money",
                      style: TextStyle(
                        color: Color(0xFF008080),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text("Amount"),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38, width: 2.0),
                  borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: amountcontroller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Amount',
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Center(
                child: GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                    makePayment(amountcontroller.text);
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF008080),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Pay",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}