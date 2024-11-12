import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery/admin/home_admin.dart';
import 'package:food_delivery/pages/bottom_nav/bottomnav.dart';
import 'package:food_delivery/pages/forgot_password/forgot_password.dart';
import 'package:food_delivery/provider/cart_provider.dart';
import 'package:food_delivery/service/database.dart';
import 'package:food_delivery/service/shared_pref.dart';
import 'package:food_delivery/widget/widget_support.dart';
import 'package:food_delivery/pages/authentication_page/signup.dart';
import 'package:provider/provider.dart';
    
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LogInState();
}

class _LogInState extends State<Login> {

  String email = "";
  String password ="";

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future <void> userLogin() async {
    try{

      //Authenticate User
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      // Get user UID
      String uid = userCredential.user!.uid;
      // Check user role in Firestore
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
        .collection('Roles').doc(uid).get();

      if (adminDoc.exists) {
        String role = adminDoc.get('Role');
        if (role == "admin") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Login Successfully!",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.greenAccent,
                ),
              ),
            ),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
          return;
        }
        else{
          throw Exception("User role not found"); 
        }
      }
  
      // If not an admin, check in the Users collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .get();

      // Save data into SharedPreferences if the user document exists
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        SharedPreferenceHelper helper = SharedPreferenceHelper();

        await helper.saveUserId(userData['Id']);
        await helper.saveUserName(userData['Name']);
        await helper.saveUserEmail(userData['Email']);
        await helper.saveUserWallet(userData['Wallet']);
        await helper.saveUserProfile(userData['Profile']);
        
        int count = await DatabaseMethods().initializeCount(userData['Id']);
        Provider.of<CartProvider>(context, listen: false).setCount(count);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Login Successfully!!",
              style: TextStyle(
                fontSize: 20,
                color: Colors.greenAccent,
              ),
            ),
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const BottomNav()));
        return;
      } 
    
      //If no match found, show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Admin Email is not correct!!",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.redAccent,
            ),
          ),
        ),
      );
    }on FirebaseException catch(e){
      print('Error code: ${e.code}');//Debug code
      if(e.code == 'invalid-credential'){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Incorrect Email or Password!!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.redAccent,
              ),
            ),
          ),
        );
      }else if(e.code == 'wrong-password'){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Passowrd is wrong!!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.redAccent,
              ),
            ),
          ),
        );
      }else if(e.code == 'wrong-password'){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Passowrd is wrong!!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.redAccent,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFff5c30),
                    Color(0xFFe74b1a),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      "images/logo.png",
                      width: MediaQuery.of(context).size.width / 1.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 1.7,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              "Login",
                              style: AppWidget.headerTextFieldStyle(),
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              controller: emailController,
                              validator: (value){
                                if(value== null || value.isEmpty){
                                  return 'Please Enter Email';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: AppWidget.semiBoldTextFieldStyle(),
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            TextFormField(
                              controller: passwordController,
                              validator: (value){
                                if(value== null || value.isEmpty){
                                  return 'Please Enter Password';
                                }
                                return null;
                              },
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: AppWidget.semiBoldTextFieldStyle(),
                                prefixIcon: const Icon(Icons.password_outlined),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> const ForgotPassword()));
                              },
                              child: Container(
                                alignment: Alignment.topRight,
                                child: Text(
                                  "Forgot Password?",
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 70.0,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if(_formKey.currentState!.validate()){
                                  email = emailController.text;
                                  password = passwordController.text;
                                }
                                await userLogin();
                              },
                              child: Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color:const  Color(0Xffff5722),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "LOGIN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontFamily: 'Poppin',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 70.0,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const SignUp()));
                    },
                    child: Text("Don't have an account? Sign up", style: AppWidget.semiBoldTextFieldStyle(),))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}