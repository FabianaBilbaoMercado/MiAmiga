// ignore_for_file: avoid_print, unused_element, depend_on_referenced_packages

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:just_audio/just_audio.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/index/indexes.dart';
import 'package:miamiga_app/model/datos_usuarios.dart';
import 'package:path/path.dart' as path;

class DetalleDenuncia extends StatefulWidget {
  final Future future;
  final String userIdDenuncia;
  final String documentIdDenuncia;
  final User? user;
  final IncidentData incidentData;
  final DenuncianteData denuncianteData;

  const DetalleDenuncia({
    super.key,
    required this.userIdDenuncia,
    required this.documentIdDenuncia,
    required this.user,
    required this.incidentData,
    required this.denuncianteData,
    required this.future,
  });

  @override
  State<DetalleDenuncia> createState() => _DetalleDenunciaState();
}

class _DetalleDenunciaState extends State<DetalleDenuncia> {
  List<String> imageUrls = [];
  String audioUrl = '';
  AudioPlayer audioPlayer = AudioPlayer();

  final descripcionController = TextEditingController();
  final fechaController = TextEditingController();
  final locationController = TextEditingController();

  String userIdPrueba = '';
  DocumentSnapshot? selectedCase;

  final CollectionReference _details =
      FirebaseFirestore.instance.collection('cases');

  Future<void> _fetchCasesAssignedToSupervisor() async {
    final QuerySnapshot querySnapshot = await _details
        .where(FieldPath.documentId, isEqualTo: widget.documentIdDenuncia)
        .where('estado', isEqualTo: "pendiente")
        .where('supervisor', isEqualTo: widget.user!.uid)
        .where('user', isEqualTo: userIdPrueba)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      print('Cases assigned to supervisor found');

      for (final doc in querySnapshot.docs) {
        if (doc.id == widget.documentIdDenuncia) {
          // Asigna el documento actual
          setState(() {
            selectedCase = doc;
          });
        }
        print('documentoId__________${selectedCase?.id}');
        await _fetchUserDataAndAddToFirestore(doc); // Use await here
      }
    } else {
      print('No cases assigned to supervisor found');
    }
  }

  Future<void> _fetchUserDataAndAddToFirestore(DocumentSnapshot doc) async {
    final userId = doc['user']; // Get the user ID from the 'user' field

    if (userId != null) {
      print('User ID found: $userId');

      // Fetch user data
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        print('Fetched user data: ${userSnapshot.data()}');
        // Fetch user data including fullname
        final fullname = userSnapshot['fullname'];
        print('User fullname: $fullname');

        final descripcionIncidente = doc['incidente']['descripcionIncidente'];
        final fechaIncidente = doc['incidente']['fechaIncidente'].toDate();
        final latitude = doc['incidente']['lat'];
        final longitude = doc['incidente']['long'];
        final List<dynamic> imageUrls = doc['incidente']['imageUrl'];
        final String audioUrl = doc['incidente']['audioUrl'];

        lat = latitude;
        long = longitude;

        final location = await getUserLocation();
        locationController.text = location;

        final userData = UserData(
            descripcionIncidente: descripcionIncidente,
            fechaIncidente: fechaIncidente,
            latitude: latitude,
            longitude: longitude,
            imageUrls: List<String>.from(imageUrls),
            audioUrl: audioUrl);

        setState(() {
          descripcionController.text = userData.descripcionIncidente;
          fechaController.text = userData.fechaIncidente.toString();
          this.imageUrls = userData.imageUrls;
          this.audioUrl = userData.audioUrl;
        });

        // ... rest of your code
      } else {
        print('No user document found');
      }
    } else {
      print('No user ID found');
    }
  }

  Future<void> _fetchData() async {
    try {
      if (widget.user != null) {
        _fetchCasesAssignedToSupervisor();
      } else {
        print('User is null');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    userIdPrueba = widget.userIdDenuncia;
    _fetchData();
  }

  double lat = 0.0;
  double long = 0.0;

  Future<String> getUserLocation() async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        long,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        final String street = placemark.thoroughfare ?? '';
        final String locality = placemark.locality ?? '';
        final String country = placemark.country ?? '';

        final formattedAddress = '$street, $locality, $country';
        return formattedAddress;
      } else {
        return 'No se pudo obtener la ubicación';
      }
    } catch (e) {
      print('Error en obteniendo ubicacion del usuario: $e');
      return 'No se pudo obtener la ubicación';
    }
  }

  Future<void> updateLocation() async {
    try {
      final String location = await getUserLocation();
      locationController.text = location;
    } catch (e) {
      print('Error actualizando ubicacion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String fileName = path.basenameWithoutExtension(audioUrl);
    List<String> parts = fileName.split('-');
    parts.removeAt(0); // Remove the first part (the UID)
    String finalFileName =
        parts.join('-'); // Join the remaining parts back together
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      const Header(
                        header: 'Detalle del Denuncia',
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
                  const SizedBox(height: 15),
                  CarouselSlider(
                    options: CarouselOptions(height: 400.0),
                    items: imageUrls.map((imageUrl) {
                      return Builder(builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: const BoxDecoration(color: Colors.amber),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Image.network(imageUrl, fit: BoxFit.cover),
                                  );
                                },
                              );
                            },
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Audio URL: $finalFileName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () async {
                          await audioPlayer.setUrl(audioUrl);
                          await audioPlayer.play();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: () async {
                          await audioPlayer.pause();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: () async {
                          await audioPlayer.stop();
                        },
                      ),
                    ],
                  ),
                  MyTextField(
                      controller: descripcionController,
                      hintText: 'Descripción del incidente',
                      text: 'Descripción del incidente',
                      obscureText: false,
                      isEnabled: false,
                      isVisible: true),
                  const SizedBox(height: 10),
                  MyTextField(
                      controller: fechaController,
                      hintText: 'Fecha del incidente',
                      text: 'Fecha del incidente',
                      obscureText: false,
                      isEnabled: false,
                      isVisible: true),
                  const SizedBox(height: 10),
                  MyTextField(
                      controller: locationController,
                      hintText: 'Ubicación del incidente',
                      text: 'Ubicación del incidente',
                      obscureText: false,
                      isEnabled: false,
                      isVisible: true),
                  // const SizedBox(height: 15),
                  // MyImportantBtn(
                  //   onTap: () {
                  //     print('Passing user: ${widget.user}');
                  //     Navigator.of(context).pushNamed(
                  //       '/evidence',
                  //       arguments: {
                  //         'user': widget.user
                  //       }
                  //     );
                  //   },
                  //   text: 'Realizar denuncia'
                  // ),
                  const SizedBox(height: 25),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
