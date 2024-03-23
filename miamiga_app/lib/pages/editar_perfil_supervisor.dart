// ignore_for_file: avoid_print, use_build_context_synchronously, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/components/phoneKeyboard.dart';

class EditPerfilSupervisor extends StatefulWidget {
  final User? user;

  const EditPerfilSupervisor({
    super.key,
    required this.user,
  });

  @override
  State<EditPerfilSupervisor> createState() => _EditPerfilSupervisorState();
}

class _EditPerfilSupervisorState extends State<EditPerfilSupervisor> {

  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();

  bool controlVentanaRefresh = false;

  final CollectionReference _registration =
      FirebaseFirestore.instance.collection('users');

  //update operation
  Future<bool> _updateData(String userId, String fullName, int phone) async {
    try {
      // Get a reference to the Firestore collection
      final DocumentReference userDocument = _registration.doc(userId);

      //ver si los datos han sido modificados
      final DocumentSnapshot currentData = await userDocument.get();
      print('current_______$currentData');
      print('userId_________$userId');
      print('fullName_________$fullName');
      print('phone_________$phone');
      final Map<String, dynamic> currentValues =
          currentData.data() as Map<String, dynamic>;
      print('currentValues_________________$currentValues');

      if (currentValues['fullname'] == fullName &&
          currentValues['phone'] == phone) {
        //no se han realizado cambios
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se han realizado cambios.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      } else {
        // changesMade = true;
        // Update the document with the specified userId
        await userDocument.update({
          'fullname': fullName,
          'phone': phone,
        });
        controlVentanaRefresh = false;
        _fetchData();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guardado exitosamente!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      print('Actualizado exitoso de datos!');
      return true;
    } catch (e) {
      print('Error actualizando datos: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error actualizando datos: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }
  }

  Future<void> _fetchData() async {
    try {
      // Check if widget.user is not null before proceeding
      if (widget.user != null && controlVentanaRefresh != true) {
        final DocumentSnapshot documentSnapshot =
            await _registration.doc(widget.user!.uid).get();

        // Check if the document exists
        if (documentSnapshot.exists) {
          fullnameController.text = documentSnapshot['fullname'];
          phoneController.text = documentSnapshot['phone'].toString();
          
        } else {
          // Handle the case where the document doesn't exist
          print("No existe el documento.");
        }
      } else {
        // Handle the case where widget.user is null
        print("El usuario es nulo.");
      }
    } catch (e) {
      // Handle any other errors that may occur during data retrieval
      print("Error en obtener datos: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  bool changesMade = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //safearea avoids the notch area
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Row(
                children: [
                  const Header(
                    header: 'Editar Perfil',
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              FutureBuilder(
                  future: _fetchData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 25),
                          MyTextField(
                            controller: fullnameController,
                            text: 'Nombre Completo',
                            hintText: 'Nombre Completo',
                            obscureText: false,
                            isEnabled: true,
                            isVisible: true,
                          ),
                          const SizedBox(height: 15),
                          MyPhoneKeyboard(
                            controller: phoneController,
                            text: 'Telefono',
                            hintText: 'Telefono',
                            obscureText: false,
                            isEnabled: true,
                            isVisible: true,
                          ),

                          const SizedBox(height: 25),

                          MyImportantBtn(
                              onTap: () async {
                                try {
                                  // if (changesMade) {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Color.fromRGBO(255, 87, 110, 1),
                                          ),
                                        );
                                      });
                                  // }

                                  bool changesMade = await _updateData(
                                    widget.user!.uid, 
                                    fullnameController.text, 
                                    int.parse(phoneController.text),
                                  );
                                  
                                  if (changesMade) {
                                    Navigator.pushReplacementNamed(context, '/screens_supervisor');
                                  } else {
                                    Navigator.pop(context);
                                  }
                                  // }
                                } catch (e) {
                                  print('Error parsing double: $e');
                                  // Handle the error, e.g. by showing an error message to the user
                                }
                              },
                              text: 'Guardar'
                            ),
                        ],
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}