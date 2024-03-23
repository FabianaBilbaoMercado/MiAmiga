// ignore_for_file: avoid_print, use_build_context_synchronously, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/components/phoneKeyboard.dart';
import 'package:miamiga_app/pages/map.dart';

class EditPerfil extends StatefulWidget {
  final User? user;

  const EditPerfil({
    super.key,
    required this.user,
  });

  @override
  State<EditPerfil> createState() => _EditPerfilState();
}

class _EditPerfilState extends State<EditPerfil> {
  late LocationData modifiedLocation;

  // final ciController = TextEditingController();
  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();

  bool controlVentanaRefresh = false;

  final CollectionReference _registration =
      FirebaseFirestore.instance.collection('users');

  //update operation
  Future<bool> _updateData(String userId, String fullName, int phone,
      double lat, double long) async {
    try {
      // Get a reference to the Firestore collection
      final DocumentReference userDocument = _registration.doc(userId);

      // Check if the data has been modified
      final DocumentSnapshot currentData = await userDocument.get();
      print('current_______$currentData');
      print('userId_________$userId');
      print('fullName_________$fullName');
      print('phone_________$phone');
      print('lat_________$lat');
      print('long_________________$long');
      final Map<String, dynamic> currentValues =
          currentData.data() as Map<String, dynamic>;
      print('currentValues_________________$currentValues');

      // if (currentValues['fullname'] == null ||
      //     currentValues['phone'] == null ||
      //     currentValues['lat'] == null ||
      //     currentValues['long'] == null) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Complete tu perfil antes de actualizar'),
      //         backgroundColor: Colors.red,
      //         duration: Duration(seconds: 3),
      //       ),
      //     );
      //     return false;
      //   }

      if (fullName.isEmpty || phone.toString().isEmpty || lat.toString().isEmpty || long.toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete su perfil antes de actualizar'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }

      if (currentValues['fullname'] == fullName &&
          currentValues['phone'] == phone &&
          currentValues['lat'] == lat &&
          currentValues['long'] == long) {
        // No changes were made
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se han realizado cambios.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return false; // No changes were made
      } else {
        // Changes were made, update the data
        await userDocument.update({
          'fullname': fullName,
          'phone': phone,
          'lat': lat,
          'long': long,
        });
        controlVentanaRefresh = false;
        _fetchData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guardado exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        print('Actualizado exitoso de datos!');
        return true; // Changes were made
      }
    } catch (e) {
      print('Error actualizando datos: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error actualizando datos: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return false; // An error occurred
    }
  }


  double lat = 0.0;
  double long = 0.0;
  //i want to fetch data from firebase and show it in the textfields

  Future<void> _fetchData() async {
    try {
      // Check if widget.user is not null before proceeding
      if (widget.user != null && controlVentanaRefresh != true) {
        final DocumentSnapshot documentSnapshot =
            await _registration.doc(widget.user!.uid).get();

        // Check if the document exists
        if (documentSnapshot.exists) {
          // ciController.text = documentSnapshot['ci'].toString();
          fullnameController.text = documentSnapshot['fullname'];
          phoneController.text = documentSnapshot['phone'].toString();
          double latitude = documentSnapshot['lat'] as double;
          double longitude = documentSnapshot['long'] as double;

          lat = latitude;
          long = longitude;

          // final List<Placemark> placemarks = await placemarkFromCoordinates(
          //   latitude,
          //   longitude
          // );

          // if (placemarks.isNotEmpty) {
          //   final Placemark placemark = placemarks[0];
          //   final String street = placemark.thoroughfare ?? '';
          //   final String locality = placemark.locality ?? '';
          //   final String country = placemark.country ?? '';

          //   final locationString = '$street, $locality, $country';
          //   locationController.text = locationString;
          // } else {
          //   locationController.text = 'No se pudo obtener la ubicación.';
          // }
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

  Future<Map<String, String>> getUserModifiedLocation() async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        long,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        final String calle = placemark.thoroughfare ?? '';
        final String avenida = placemark.subLocality ?? '';
        final String localidad = placemark.locality ?? '';
        final String pais = placemark.country ?? '';

        final String fullStreet =
            avenida.isNotEmpty ? '$calle, $avenida' : calle;

        return {
          'street': fullStreet,
          'locality': localidad,
          'country': pais,
        };
      } else {
        return {
          'street': 'No se pudo obtener la ubicacion',
          'locality': 'No se pudo obtener la ubicacion',
          'country': 'No se pudo obtener la ubicacion',
        };
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener la ubicacion modificada: $e');
      return {
        'street': 'No se pudo obtener la ubicacion',
        'locality': 'No se pudo obtener la ubicacion',
        'country': 'No se pudo obtener la ubicacion',
      };
    }
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
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(255, 87, 110, 1),
                        ),
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
                          FutureBuilder<Map<String, String>>(
                              future: getUserModifiedLocation(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(
                                    color: Color.fromRGBO(255, 87, 110, 1),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final locationData = snapshot.data!;
                                  final calle = locationData['street'];
                                  final localidad = locationData['locality'];
                                  final pais = locationData['country'];
                                  return Column(
                                    children: [
                                      /*hidden lat and long*/
                                      const SizedBox(height: 10),
                                      MyTextField(
                                        controller: latController,
                                        text: 'Latitud',
                                        hintText: 'Latitud',
                                        obscureText: false,
                                        isEnabled: false,
                                        isVisible: false,
                                      ),
                                      const SizedBox(height: 10),
                                      MyTextField(
                                        controller: longController,
                                        text: 'Longitud',
                                        hintText: 'Longitud',
                                        obscureText: false,
                                        isEnabled: false,
                                        isVisible: false,
                                      ),
                                      /*hidden lat and long*/
                                      const SizedBox(height: 10),
                                      Text('Calle: $calle'),
                                      Text('Localidad: $localidad'),
                                      Text('Pais: $pais'),
                                    ],
                                  );
                                }
                              }),
                          const SizedBox(height: 10),
                          //seleccionar ubicacion

                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(248, 181, 149, 1)),
                            ),
                            onPressed: () async {
                              controlVentanaRefresh = true;
                              final selectedLocation =
                                  await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const CurrentLocationScreen();
                                  },
                                ),
                              );
                              if (selectedLocation != null &&
                                  selectedLocation is Map<String, double>) {
                                setState(() {
                                  lat = selectedLocation['latitude']!;
                                  long = selectedLocation['longitude']!;
                                });
                                final locationData =
                                    await getUserModifiedLocation();
                                final calle = locationData['street'];
                                final localidad = locationData['locality'];
                                final pais = locationData['country'];
                                latController.text = lat.toString();
                                longController.text = long.toString();
                                print(
                                    'latController.text_________${latController.text}');
                                print(
                                    'longController.text_________________${longController.text}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Column(children: [
                                      Text('Calle: $calle'),
                                      Text('Localidad: $localidad'),
                                      Text('Pais: $pais'),
                                    ]),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                // changesMade = true;
                              }
                            },
                            child: const Text('Seleccionar Ubicación'),
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
                                
                                bool changesMade = await _updateData(
                                  widget.user!.uid,
                                  fullnameController.text,
                                  int.parse(phoneController.text),
                                  double.parse(lat.toString()),
                                  double.parse(long.toString()),
                                );

                                if (changesMade) {
                                  Navigator.pushReplacementNamed(context, '/screens_usuario');
                                } else {
                                  Navigator.pop(context); // Close the progress dialog
                                }

                                // bool profileComplete = await _isProfileComplete(widget.user!.uid);

                                // if (profileComplete) {
                                //   Navigator.pushReplacementNamed(context, '/screens_usuario');
                                // } else {
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     const SnackBar(
                                //       content: Text('Complete su perfil antes de actualizar'),
                                //       backgroundColor: Colors.red,
                                //       duration: Duration(seconds: 3),
                                //     ),
                                //   );
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
                  }
                ),
            ],
          ),
        ),
      ),
    );
  }
}