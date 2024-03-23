// ignore_for_file: avoid_print


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/model/datos_denunciante.dart';
import 'package:miamiga_app/model/datos_incidente.dart';
import 'package:miamiga_app/pages/alerta.dart';

class DatosDenunciante extends StatefulWidget {
  final User? user;
  final IncidentData incidentData;
  final DenuncianteData denuncianteData;

  const DatosDenunciante({
    super.key,
    required this.user,
    required this.incidentData,
    required this.denuncianteData,
    });

  @override
  State<DatosDenunciante> createState() => _DatosDenuncianteState();
}

class _DatosDenuncianteState extends State<DatosDenunciante> {

  final fullnameController = TextEditingController();
  final ciController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();

  void denunciar() async{
    saveDenuncianteData();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AlertaScreen(
          user: widget.user, 
          denuncianteData: widget.denuncianteData, 
          incidentData: widget.incidentData
          
        ), 
      ),
    );
  }

  void saveDenuncianteData() {
    widget.denuncianteData.fullName = fullnameController.text;
    widget.denuncianteData.ci = int.parse(ciController.text);
    widget.denuncianteData.phone = int.parse(phoneController.text);
    widget.denuncianteData.lat = double.parse(lat.toString());
    widget.denuncianteData.long = double.parse(long.toString());
  }

  final CollectionReference _registration = 
        FirebaseFirestore.instance.collection('users');

  double lat = 0.0;
  double long = 0.0;

  Future<void> _fetchData() async {
    try {
      // Check if widget.user is not null before proceeding
      if (widget.user != null) {
        final DocumentSnapshot documentSnapshot =
            await _registration.doc(widget.user!.uid).get();

        // Check if the document exists
        if (documentSnapshot.exists) {
          fullnameController.text = documentSnapshot['fullname'];
          phoneController.text = documentSnapshot['phone'].toString();
          ciController.text = documentSnapshot['ci'].toString();
          double latitude = documentSnapshot['lat'] as double;
          double longitude = documentSnapshot['long'] as double;
          
          lat = latitude;
          long = longitude;

          final List<Placemark> placemarks = await placemarkFromCoordinates(
            latitude, 
            longitude
          );

          if (placemarks.isNotEmpty) {
            final Placemark placemark = placemarks[0];
            final String street = placemark.thoroughfare ?? '';
            final String locality = placemark.locality ?? '';
            final String country = placemark.country ?? '';

            final locationString = '$street, $locality, $country';
            locationController.text = locationString;
          } else {
            locationController.text = 'No se pudo obtener la ubicacion';
          }
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

  @override
  void dispose() {
    fullnameController.dispose();
    ciController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack( // Wrap the content with a Stack
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const SizedBox(height: 15),
                  

                  Row(
                    children: [
                      const Header(
                        header: 'Datos del Denunciante',
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
                          child: CircularProgressIndicator(
                            color: Color.fromRGBO(255, 87, 110, 1),
                          )
                        );
                      } else if (snapshot.hasError) {
                        return Text ('Error: ${snapshot.error}');
                      } else {
                        return Column(
                          children: [
                            const SizedBox(height: 25),
                            MyTextField(
                              controller: fullnameController,
                              text: 'Nombre Completo',
                              hintText: 'Nombre Completo',
                              obscureText: false,
                              isEnabled: false,
                              isVisible: true,
                            ),
                            const SizedBox(height: 15),
                            MyTextField(
                              controller: ciController,
                              text: 'Carnet de Identidad',
                              hintText: 'Carnet de Identidad',
                              obscureText: false,
                              isEnabled: false,
                              isVisible: true,
                            ),
                            const SizedBox(height: 15),
                            MyTextField(
                              controller: phoneController,
                              text: 'Telefono',
                              hintText: 'Telefono',
                              obscureText: false,
                              isEnabled: false,
                              isVisible: true,
                            ),
                            const SizedBox(height: 15),
                            MyTextField(
                              controller: locationController,
                              text: 'Ubicacion',
                              hintText: 'Ubicacion',
                              obscureText: false,
                              isEnabled: false,
                              isVisible: true,
                            ),
                            const SizedBox(height: 25),

                            MyImportantBtn(
                              onTap: denunciar, 
                              text: 'Siguiente',
                            ),
                          ],
                        );
                      }
                    }
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}