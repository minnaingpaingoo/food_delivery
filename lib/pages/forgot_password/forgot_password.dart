import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/pages/authentication_page/signup.dart';
    
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String email="";

  resetPassword() async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password Reset Email has been sent!!",
            style: TextStyle(
              fontSize: 18,
              color: Colors.greenAccent,
            ),
          ),
        ),
      );
    }on FirebaseException catch(e){
      print('Error code: ${e.code}'); // Debug line
      if(e.code == 'invalid-email'){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid Email Format!!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.redAccent,
              ),
            ),
          ),
        );
      }else if(e.code == 'user-not-found'){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No user found for that email!!",
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
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 70),
          Container(
            alignment: Alignment.topCenter,
            child: const Text(
              "Password Recovery",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter Your Mail",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(left:10),
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left:20, right: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white70,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return 'Please Enter an Email';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap:(){
                        if(_formKey.currentState!.validate()){
                          setState(() {
                            email = emailController.text.trim();
                          });
                          resetPassword();
                        }
                      },
                      child: Container(
                        margin:const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const  Center(
                          child: Text(
                            "Send Email",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5,),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
                          },
                          child: const Text(
                            "Create",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 184, 166, 6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}