import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod{
  final FirebaseAuth auth= FirebaseAuth.instance;

  getCurrentUser() async{
    return auth.currentUser;
  }

  Future signOut() async{
    await FirebaseAuth.instance.signOut();
  }

  Future deleteUser() async{
    User? user = FirebaseAuth.instance.currentUser;
    user?.delete();
  }
}