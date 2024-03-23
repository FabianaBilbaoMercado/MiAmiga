// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final BuildContext context;

  AuthService({required this.context});

  //iniciar con google
  Future<void> signInWithGoogle() async {

      try {
        //comenzar con el proceso de iniciar
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      //obtener detalles de auth de requests
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      //crear un nueva credential para usuario
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = userCredential.user!;

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userData['fullname'] != null && userData['email'] != null && userData['ci'] != null && userData['phone'] != null && userData['lat'] != null && userData['long'] != null) {
          Navigator.of(context).pushReplacementNamed('/screens_usuario');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, completa tu perfil'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/completar_perfil');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, completa tu perfil'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/completar_perfil');
      
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error de iniciar con google: $e");
    }
  }     
}