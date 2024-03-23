// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  String? getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontro el correo electrónico. Verifique el correo electrónico';
      case 'invalid-email':
        return 'Correo electrónico invalido. Verifique el formato';
      default:
        return null;
    }
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailController.text.trim());
      showDialog(
        context: context, builder: (context) {
          return const AlertDialog(
            content: Text(
              'Enlace para restablecer contraseña a sido enviado! Revisa su correo',
              style: TextStyle(
                color: Color.fromRGBO(255, 87, 110, 1),
              ),
            ),
          );
        }
      );
    } on FirebaseAuthException catch (e) {
      final errorMessage = getErrorMessage(e);
      if (errorMessage != null) {
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              content: Text(errorMessage),
            );
          }
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Header(
                header: 'Restablecer Contraseña',
              ),
              /* const SizedBox(height: 50),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  'Ingrese su correo para restablecer contraseña',
                  textAlign: TextAlign.center,
                ),
              ), */
              const SizedBox(height: 25),
              MyTextField(
                controller: emailController,
                text: 'Correo Electrónico',
                hintText: 'Correo Electrónico',
                obscureText: false,
                isEnabled: true,
                isVisible: true,
              ),
              const SizedBox(height: 25),
              MyImportantBtn(
                text: 'Enviar',
                onTap: passwordReset,
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                }, 
                child: const Text(
                  'Volver al inicio de sesion',
                  style: TextStyle(
                    color: Color.fromRGBO(108, 91, 124, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
