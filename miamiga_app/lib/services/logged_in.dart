import 'package:firebase_auth/firebase_auth.dart';

Future<bool> checkUserLoggedIn() async {
  final user = FirebaseAuth.instance.currentUser;
  return user != null;
}
