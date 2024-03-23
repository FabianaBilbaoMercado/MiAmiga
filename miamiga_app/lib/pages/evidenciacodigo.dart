// // ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, avoid_print, duplicate_ignore

// import 'dart:io';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:miamiga_app/components/headers.dart';
// import 'package:miamiga_app/components/limit_characters.dart';
// import 'package:miamiga_app/components/my_important_btn.dart';
// import 'package:miamiga_app/components/my_textfield.dart';
// import 'package:miamiga_app/components/row_button.dart';
// import 'package:miamiga_app/model/datos_evidencia.dart';
// import 'package:miamiga_app/pages/document_modal.dart';
// import 'package:miamiga_app/pages/image_modal.dart';
// import 'package:miamiga_app/pages/map.dart';
// import 'package:path/path.dart' as Path;

// class CasePage extends StatefulWidget {
//   final String item;

//   const CasePage({super.key, required this.item});

//   @override
//   State<CasePage> createState() => _CasePageState();
// }

// class _CasePageState extends State<CasePage> {
//   final desController = TextEditingController();
//   final dateController = TextEditingController();
//   final latController = TextEditingController();
//   final longController = TextEditingController();

//   List<XFile> pickedImages = [];
//   List<File> pickedDocument = [];
//   List<File> pickedAudios = [];
//   String? selectedAudioPath;
//   final audioPlayer = AudioPlayer();
//   bool isPlaying = false;
//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;
//   double sliderValue = 0.0;

//   String audioTitle = '';

//   bool isDocumentReceived = false;
//   bool isImageReceived = false;
//   bool isMediaReceived = false;

//   Future<List<String>> uploadImageFile(List<File> files) async {
//     List<String> downloadUrls = [];
//     for (File file in files) {
//       String fileName = Path.basename(file.path);
//       Reference ref =
//           FirebaseStorage.instance.ref().child('EvidenceImages/$fileName');
//       UploadTask uploadTask = ref.putFile(file);
//       TaskSnapshot taskSnapshot = await uploadTask;
//       final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//       downloadUrls.add(downloadUrl);
//     }
//     return downloadUrls;
//   }

//   Future<String> uploadAudioFile(File file) async {
//     String fileName = Path.basename(file.path);
//     Reference ref =
//         FirebaseStorage.instance.ref().child('EvidenceAudios/$fileName');
//     UploadTask uploadTask = ref.putFile(file);
//     TaskSnapshot taskSnapshot = await uploadTask;
//     final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//     return downloadUrl;
//   }

//   Future<String> uploadDocumentFiles(File file) async {
//     String fileName = Path.basename(file.path);
//     String extension = Path.extension(file.path).toLowerCase();

//     if (extension == '.pdf' || extension == '.doc' || extension == '.docx') {
//       Reference ref =
//           FirebaseStorage.instance.ref().child('EvidenceDocuments/$fileName');
//       UploadTask uploadTask = ref.putFile(file);
//       TaskSnapshot taskSnapshot = await uploadTask;
//       final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } else {
//       throw Exception(
//           'Tipo archivo invalido. Por favor seleccione un archivo PDF, DOC o DOCX.');
//     }
//   }

//   Future selectImageFile() async {
//     final result = await ImagePicker().pickMultiImage(
//       maxWidth: double.infinity,
//       maxHeight: double.infinity,
//       imageQuality: 80,
//     );
//     if (result != null) {
//       setState(() {
//         for (var image in result) {
//           pickedImages.add(image);
//         }
//         isImageReceived = true;
//       });
//     }
//   }

//   void cargarImagen() async {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return ImageModal(
//         pickedImages: pickedImages,
//         onImagesSelected: (ImageSource source) async {
//           if (source == ImageSource.camera) {
//             final result = await ImagePicker().pickImage(
//               source: ImageSource.camera,
//               maxWidth: double.infinity,
//               maxHeight: double.infinity,
//               imageQuality: 80,
//             );

//             List<XFile> newImages = [];
//             if (result != null) {
//               newImages.add(XFile(result.path));
//             }

//             return newImages;
//           } else {
//             final result = await ImagePicker().pickMultiImage(
//               maxWidth: double.infinity,
//               maxHeight: double.infinity,
//               imageQuality: 80,
//             );

//             List<XFile> newImages = [];
//             if (result != null) {
//               newImages.addAll(result);
//             }

//             return newImages;
//           }
//         },
//       );
//     },
//   );
// }

//   Future<void> selectDocumentFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'doc', 'docx'],
//     );

//     if (result != null) {
//       setState(() {
//         pickedDocument.add(File(result.files.single.path!));
//         isDocumentReceived = true;
//       });
//     }
//   }

//   void cargarDocumento() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return DocumentModal(
//           pickedDocuments: pickedDocument,
//           onDocumentsSelected: () async {
//             final result = await FilePicker.platform.pickFiles(
//               type: FileType.custom,
//               allowedExtensions: ['pdf', 'doc', 'docx'],
//             );

//             List<File> newDocuments = [];
//             if (result != null) {
//               newDocuments.add(File(result.files.single.path!));
//             }

//             return newDocuments;
//           },
//         );
//       },
//     );
//   }

//   Future<void> pickAudio() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.audio,
//     );

//     if (result != null) {
//       PlatformFile file = result.files.first;
//       selectedAudioPath = file.path;

//       audioTitle = file.name;
//       print('audiopickaudio________$selectedAudioPath');

//       // Intenta cargar y reproducir el audio
//       try {
//         await audioPlayer.setSourceUrl(selectedAudioPath!);
//         await audioPlayer.getDuration().then((value) {
//           if (value != null) {
//             setState(() {
//               duration = value;
//               isMediaReceived = true;
//             });
//           }
//         });
//       } catch (e) {
//         print('Error al cargar/reproducir el audio: $e');
//         // Maneja el error aquí (por ejemplo, muestra un mensaje al usuario)
//       }
//     } else {
//       // El usuario canceló la selección
//       selectedAudioPath = null;
//     }
//   }

//   // void cargarAudio() async {
//   //   showDialog(
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       return AudioModal(
//   //         pickedAudios: pickedAudios,
//   //         onAudiosSelected: () async {
//   //           FilePickerResult? result = await FilePicker.platform.pickFiles(
//   //             type: FileType.audio,
//   //           );

//   //           List<File> newAudios = [];
//   //           if (result != null) {
//   //             newAudios.add(File(result.files.first.path!));
//   //           }
//   //           pickAudio();
//   //           return newAudios;
//   //         },
//   //       );
//   //     },
//   //   );
//   // }
//   void cargarAudio() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: SizedBox(
//             width: 300, // Adjust the width as needed
//             height: 300, // Adjust the height as needed
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   const Padding(
//                     padding: EdgeInsets.all(24.0),
//                     child: Text(
//                       'Seleccionar Audio',
//                       style: TextStyle(
//                         fontSize: 20.0,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   if (selectedAudioPath != null)
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'Titulo del Audio: $audioTitle',
//                         style: const TextStyle(
//                           fontSize: 18.0,
//                         ),
//                       ),
//                     ),
//                   if (selectedAudioPath != null)
//                     Column(
//                       children: [
//                         Slider(
//                           value: sliderValue,
//                           min: 0.0,
//                           max: duration.inSeconds.toDouble(),
//                           onChanged: (value) {
//                             setState(() {
//                               sliderValue = value;
//                               audioPlayer
//                                   .seek(Duration(seconds: value.toInt()));
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   if (selectedAudioPath != null)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         IconButton(
//                           icon:
//                               Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//                           iconSize: 50.0,
//                           onPressed: () {
//                             if (isPlaying) {
//                               audioPlayer.pause();
//                             } else {
//                               audioPlayer.resume();
//                             }
//                             setState(() {
//                               isPlaying = !isPlaying;
//                             });
//                           },
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             audioPlayer.stop();
//                             setState(() {
//                               isPlaying = false;
//                               sliderValue = 0.0;
//                             });
//                           },
//                           icon: const Icon(Icons.stop),
//                         ),
//                       ],
//                     ),
//                   SizedBox(
//                       width: 100,
//                       height: 100,
//                       child: ElevatedButton.icon(
//                         onPressed: pickAudio,
//                         icon: const Icon(
//                           Icons.music_note,
//                           size: 50,
//                         ),
//                         label: const SizedBox.shrink(),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.all(0),
//                           backgroundColor:
//                               const Color.fromRGBO(248, 181, 149, 1),
//                         ),
//                       )),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   double lat = 0.0;
//   double long = 0.0;

//   Future<Map<String, String>> getUserModifiedLocation() async {
//     try {
//       final List<Placemark> placemarks = await placemarkFromCoordinates(
//         lat,
//         long,
//       );

//       if (placemarks.isNotEmpty) {
//         final Placemark placemark = placemarks[0];
//         final String calle = placemark.thoroughfare ?? '';
//         final String avenida = placemark.subLocality ?? '';
//         final String localidad = placemark.locality ?? '';
//         final String pais = placemark.country ?? '';

//         final String fullStreet =
//             avenida.isNotEmpty ? '$calle, $avenida' : calle;

//         return {
//           'street': fullStreet,
//           'locality': localidad,
//           'country': pais,
//         };
//       } else {
//         return {
//           'street': 'No se pudo obtener la ubicacion',
//           'locality': 'No se pudo obtener la ubicacion',
//           'country': 'No se pudo obtener la ubicacion',
//         };
//       }
//     } catch (e) {
//       // ignore: avoid_print
//       print('Error al obtener la ubicacion modificada: $e');
//       return {
//         'street': 'No se pudo obtener la ubicacion',
//         'locality': 'No se pudo obtener la ubicacion',
//         'country': 'No se pudo obtener la ubicacion',
//       };
//     }
//   }

//   void createEvidence() async {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         });

//     try {
//       print('iamgen_____________$pickedImages');
//       print('documento_____________$pickedDocument');
//       print('audio_____________$pickedAudios');
//       print('audioseelct_____________$selectedAudioPath');
//       print('description_____________$desController');
//       print('date_____________$date');
//       print('late_____________$lat');
//       print('long_____________$long');
//       if (pickedImages.isEmpty ||
//           pickedDocument.isEmpty ||
//           // pickedAudios == null ||
//           selectedAudioPath == null ||
//           desController.text.trim().isEmpty ||
//           date == null ||
//           lat == 0.0 ||
//           long == 0.0) {
//         showErrorMsg('Por favor llene todos los campos');
//         return;
//       }

//       await createUserDocument(
//         EvidenceData(
//           description: desController.text.trim(),
//           date: date,
//           lat: lat,
//           long: long,
//           imageUrls: pickedImages.map((e) => e.path).toList(),
//           audioUrl: selectedAudioPath!,
//           // audioUrl: pickedAudios.map((audio) => audio.path).toList().toString(),
//           documentUrl: pickedDocument.first.path, 
//           selectedUser: '',
//         ),
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Evidencia enviada exitosamente!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       // ignore: avoid_print
//       print('Error al enviar el evidencia: $e');
//       // Navigator.pop(context);
//     } finally {
//       Navigator.pop(context); // Cierra el diálogo de carga
//     }
//   }

//   Future<void> createUserDocument(EvidenceData evidenceData) async {
//     List<File> imageFiles = evidenceData.imageUrls.map((e) => File(e)).toList();
//     List<String> imageUrls = await uploadImageFile(imageFiles);
//     String audioUrl = await uploadAudioFile(File(evidenceData.audioUrl));
//     String documentUrl =
//         await uploadDocumentFiles(File(evidenceData.documentUrl));

//     try {
//       DocumentReference docRef =
//           FirebaseFirestore.instance.collection('evidence').doc();
//       await docRef.set({
//         'imageUrl': imageUrls,
//         'audioUrl': audioUrl,
//         'document': documentUrl,
//         'descripcion': evidenceData.description,
//         'fecha': evidenceData.date,
//         'lat': evidenceData.lat,
//         'long': evidenceData.long,
//       });
//       Navigator.pop(context);
//       print('Evidencia creada exitosamente! con el ID: ${docRef.id}');
//     } catch (e) {
//       // ignore: avoid_print
//       print('Error al crear documento del usuario: $e');
//     }
//   }

//   void showErrorMsg(String errorMsg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(errorMsg,
//             style: const TextStyle(
//               color: Colors.white,
//             )),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   DateTime date = DateTime.now();
//   TimeOfDay timeOfDay = TimeOfDay.now();
//   bool changesMade = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SafeArea(
//       child: SingleChildScrollView(
//           child: Stack(
//         children: [
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 15),
//               const Row(
//                 children: [
//                   Header(
//                     header: 'Datos de la Evidencia',
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 15),
//               Row(
//                 children: [
//                   Expanded(
//                     child: RowButton(
//                       onTap: cargarImagen,
//                       text: 'Imagen',
//                       icon: Icons.image,
//                     ),
//                   ),
//                   Expanded(
//                     child: RowButton(
//                       onTap: cargarDocumento,
//                       text: 'Documento',
//                       icon: Icons.file_copy,
//                     ),
//                   ),
//                   Expanded(
//                     child: RowButton(
//                       onTap: cargarAudio,
//                       text: 'Audio',
//                       icon: Icons.audiotrack,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               LimitCharacter(
//                 controller: desController,
//                 text: 'Descripción del Evidencia', // 'Descripción del Incidente
//                 hintText: 'Descripción del Evidencia',
//                 obscureText: false,
//                 isEnabled: true,
//                 isVisible: true,
//               ),
//               const SizedBox(height: 15),
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Seleccionar Fecha del Evidencia',
//                       style:
//                           TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       '${date.year}/${date.month}/${date.day}',
//                       style: const TextStyle(
//                           fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       style: ButtonStyle(
//                         backgroundColor: MaterialStateProperty.all(
//                             const Color.fromRGBO(248, 181, 149, 1)),
//                       ),
//                       child: const Text('Seleccionar Fecha'),
//                       onPressed: () async {
//                         DateTime? selectedDate = await showDatePicker(
//                           context: context,
//                           initialDate: date,
//                           firstDate: DateTime(1900),
//                           lastDate: DateTime(2100),
//                           builder: (BuildContext context, Widget? child) {
//                             return Theme(
//                               data: ThemeData.dark().copyWith(
//                                 colorScheme: const ColorScheme.dark(
//                                   primary: Color.fromRGBO(248, 181, 149, 1),
//                                   onPrimary: Colors.black,
//                                   surface: Color.fromRGBO(248, 181, 149, 1),
//                                   onSurface: Colors.white,
//                                 ),
//                                 dialogBackgroundColor: Colors.black,
//                               ),
//                               child: child!,
//                             );
//                           },
//                         );
//                         if (selectedDate == null) return;

//                         // Create a new DateTime object with the selected date and the fixed time
//                         DateTime selectedDateTime = DateTime(
//                           selectedDate.year,
//                           selectedDate.month,
//                           selectedDate.day,
//                           timeOfDay.hour,
//                           timeOfDay.minute,
//                         );

//                         setState(() {
//                           date = selectedDateTime;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               FutureBuilder<Map<String, String>>(
//                   future: getUserModifiedLocation(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else {
//                       final locationData = snapshot.data!;
//                       final calle = locationData['street'];
//                       final localidad = locationData['locality'];
//                       final pais = locationData['country'];
//                       return Column(
//                         children: [
//                           /*hidden lat and long*/
//                           const SizedBox(height: 10),
//                           MyTextField(
//                             controller: latController,
//                             text: 'Latitud',
//                             hintText: 'Latitud',
//                             obscureText: false,
//                             isEnabled: false,
//                             isVisible: false,
//                           ),
//                           const SizedBox(height: 10),
//                           MyTextField(
//                             controller: longController,
//                             text: 'Longitud',
//                             hintText: 'Longitud',
//                             obscureText: false,
//                             isEnabled: false,
//                             isVisible: false,
//                           ),
//                           /*hidden lat and long*/
//                           const SizedBox(height: 10),
//                           Text('Calle: $calle'),
//                           Text('Localidad: $localidad'),
//                           Text('Pais: $pais'),
//                         ],
//                       );
//                     }
//                   }),
//               const SizedBox(height: 15),
//               ElevatedButton(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(
//                       const Color.fromRGBO(248, 181, 149, 1)),
//                 ),
//                 onPressed: () async {
//                   final selectedLocation = await Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return const CurrentLocationScreen();
//                       },
//                     ),
//                   );
//                   if (selectedLocation != null &&
//                       selectedLocation is Map<String, double>) {
//                     setState(() {
//                       lat = selectedLocation['latitude']!;
//                       long = selectedLocation['longitude']!;
//                     });
//                     final locationData = await getUserModifiedLocation();
//                     final calle = locationData['street'];
//                     final localidad = locationData['locality'];
//                     final pais = locationData['country'];
//                     latController.text = lat.toString();
//                     longController.text = long.toString();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Column(children: [
//                           Text('Calle: $calle'),
//                           Text('Localidad: $localidad'),
//                           Text('Pais: $pais'),
//                         ]),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                     changesMade = true;
//                   }
//                 },
//                 child: const Text('Seleccionar Ubicacion'),
//               ),
//               const SizedBox(height: 30),
//               MyImportantBtn(onTap: createEvidence, text: 'Finalizar'),
//             ],
//           ),
//         ],
//       )),
//     ));
//   }
// }
