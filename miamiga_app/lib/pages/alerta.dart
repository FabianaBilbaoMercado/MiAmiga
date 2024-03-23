// ignore_for_file: library_prefixes, depend_on_referenced_packages, use_build_context_synchronously, must_be_immutable, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:miamiga_app/components/important_button.dart';
import 'package:miamiga_app/components/my_button.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/model/datos_denunciante.dart';
import 'package:miamiga_app/model/datos_incidente.dart';
import 'package:path/path.dart' as Path;

class AlertaScreen extends StatefulWidget {
  final User? user;
  final DenuncianteData denuncianteData;
  IncidentData incidentData;
  AlertaScreen({
    super.key,
    required this.user,
    required this.denuncianteData,
    required this.incidentData,
  });

  @override
  State<AlertaScreen> createState() => _AlertaScreenState();
}

class _AlertaScreenState extends State<AlertaScreen> {

  Future<List<String>> uploadImageFile(String userId, List<File> files) async {
    List<String> downloadUrls = [];
    for (File file in files) {
      String fileName = Path.basename(file.path);
      Reference ref = FirebaseStorage.instance.ref().child('Cases/$userId/Images/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<String> uploadAudioFile(String userId, File file) async {
    String fileName = Path.basename(file.path);
    Reference ref = FirebaseStorage.instance.ref().child('Cases/$userId/Audios/$fileName');
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void _saveAndGoBack() {
    Navigator.of(context).pop(widget.incidentData);
  }

  void alert() async {
    Future<void>? createCaseFuture;

    await showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Estás seguro?'),
          content: const Text('¿Deseas denunciar este incidente?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                createCaseFuture = createCase(widget.user, widget.denuncianteData, widget.incidentData);
                Navigator.pop(context);
              }, 
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  color: Color.fromRGBO(255, 87, 110, 1),
                ),
              ),
            ),
          ],
        );
      }
    );

    if (createCaseFuture != null) {
      await showDialog(
        context: context, 
        builder: (context) {
          return FutureBuilder(
            future: createCaseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromRGBO(255, 87, 110, 1),
                  )
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                Future.microtask(() {
                  Navigator.popUntil(context, ModalRoute.withName('/screens_usuario'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Caso creado con éxito'),
                      backgroundColor: Colors.green,
                    ),
                  );
                });
                return Container();
              }
            
            },
          );
        }
      );
    }
  }

  Future<String> fetchCaseData(String? userId) async {
      if (userId == null) {
        throw Exception('User ID is null');
      }

      final querySnapshot = await FirebaseFirestore.instance
      .collection('alert')
      .where('user', isEqualTo: userId)
      .get();

      if (querySnapshot.docs.isEmpty) {
        return 'No hay alertas';
      }

      return querySnapshot.docs.first.id;
    }
  
  Future<void> createCase(User? user, DenuncianteData denuncianteData, IncidentData incidentData) async {

    try {
      List<File> imageFiles = incidentData.imageUrls.map((e) => File(e)).toList();
      List<String> imageUrls = await uploadImageFile(user!.uid, imageFiles);
      String audioUrl = await uploadAudioFile(user.uid, File(incidentData.audioUrl));

      String alert = await fetchCaseData(user.uid);

      //i want to create the document of my case

      final CollectionReference _case = 
      FirebaseFirestore.instance.collection('cases');

      await _case.add({

        'denunciante': {
          'userId': user.uid,
          'fullname': denuncianteData.fullName,
          'ci': denuncianteData.ci,
          'phone': denuncianteData.phone,
          'lat': denuncianteData.lat,
          'long': denuncianteData.long,
        },

        'incidente': {
          'userId': user.uid,
          'descripcionIncidente': incidentData.description,
          'fechaIncidente': incidentData.date,
          'lat': incidentData.lat,
          'long': incidentData.long,
          'imageUrl': imageUrls,
          'audioUrl': audioUrl,
        },
        'alert': alert,
        'estado': 'pendiente',
        'fecha': DateTime.now(),
        'user': user.uid,
      });

      print('Caso creada con éxito');
    } catch (e) {
      print('Error al crear el caso: $e');
    }
    
  }

  void homeScreen() async {
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/screens_usuario', // Replace with the actual name of your home screen route
    (route) => false, // This predicate removes all the previous routes
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
                Center(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          '¿Estás seguro de proceder hacer un alerta?',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.start,
                        ),
                      ),    
                      const SizedBox(height: 50),
                      MyImportantBtn(
                        text: 'Editar',
                        onTap: _saveAndGoBack,
                      ),

                      const SizedBox(height: 50),
                      ImportantButton(
                        text: 'DENUNCIAR',
                        onTap: alert,
                        icon: Icons.warning_rounded,
                    ),

                    const SizedBox(height: 50),
                      MyButton(
                        text: 'Ir al Inicio',
                        onTap: homeScreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}