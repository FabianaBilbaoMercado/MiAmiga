// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, avoid_print, duplicate_ignore, unused_element, library_prefixes, unused_field

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/limit_characters_second.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/components/row_button.dart';
import 'package:miamiga_app/index/indexes.dart';
import 'package:miamiga_app/model/datos_evidencia.dart';
import 'package:miamiga_app/pages/audio_modal.dart';
import 'package:miamiga_app/pages/document_modal.dart';
import 'package:miamiga_app/pages/image_modal.dart';
import 'package:miamiga_app/pages/map.dart';
import 'package:path/path.dart' as Path;

class CasePage extends StatefulWidget {
  final User? user;
  final String item;

  const CasePage({
    super.key, 
    required this.item,
    required this.user,
  });

  @override
  State<CasePage> createState() => _CasePageState();
}

class _CasePageState extends State<CasePage> {
  final desController = TextEditingController();
  final dateController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();
  final conclusionController = TextEditingController();

  List<XFile> pickedImages = [];
  List<File> pickedDocument = [];
  List<File> pickedAudios = [];
  String? selectedAudioPath;
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  double sliderValue = 0.0;

  String audioTitle = '';

  bool isDocumentReceived = false;
  bool isImageReceived = false;
  bool isMediaReceived = false;

  Future<List<String>> uploadImageFile(String caseId, List<File> files) async {
    List<String> downloadUrls = [];
    for (File file in files) {
      String fileName = Path.basename(file.path);
      Reference ref =
          FirebaseStorage.instance.ref().child('Evidences/$caseId/Images/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<String> uploadAudioFile(String caseId, File file) async {
    String fileName = Path.basename(file.path);
    Reference ref =
        FirebaseStorage.instance.ref().child('Evidences/$caseId/Audios/$fileName');
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadDocumentFiles(String caseId, File file) async {
    String fileName = Path.basename(file.path);
    String extension = Path.extension(file.path).toLowerCase();

    if (extension == '.pdf' || extension == '.doc' || extension == '.docx') {
      Reference ref =
          FirebaseStorage.instance.ref().child('Evidences/$caseId/Documents/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } else {
      throw Exception(
          'Tipo archivo invalido. Por favor seleccione un archivo PDF, DOC o DOCX.');
    }
  }

  Future selectImageFile() async {
    final result = await ImagePicker().pickMultiImage(
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      imageQuality: 80,
    );
    if (result != null) {
      setState(() {
        for (var image in result) {
          print('Selected image: ${image.path}');
          pickedImages.add(image);
        }
        isImageReceived = true;
      });
    }
  }

  // void updateImages(List<XFile> newImages) {
  //   setState(() {
  //     pickedImages.addAll(newImages);
  //   });
  // }

  void cargarImagen() async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ImageModal(
        // updateImages: updateImages,
        pickedImages: pickedImages,
        onImagesSelected: (ImageSource source) async {
          if (source == ImageSource.camera) {
            final result = await ImagePicker().pickImage(
              source: ImageSource.camera,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              imageQuality: 80,
            );

            List<XFile> newImages = [];
            if (result != null) {
              newImages.add(XFile(result.path));
            }

            return newImages;
          } else {
            final result = await ImagePicker().pickMultiImage(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              imageQuality: 80,
            );

            List<XFile> newImages = [];
            if (result != null) {
              newImages.addAll(result);
            }

            return newImages;
          }
        },
      );
    },
  );
}

  Future<void> selectDocumentFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        print('Selected document: ${result.files.single.path}');
        pickedDocument.add(File(result.files.single.path!));
        isDocumentReceived = true;
      });
    }
  }

  void cargarDocumento() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DocumentModal(
          pickedDocuments: pickedDocument,
          onDocumentsSelected: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx'],
            );

            List<File> newDocuments = [];
            if (result != null) {
              newDocuments.add(File(result.files.single.path!));
            }

            return newDocuments;
          },
        );
      },
    );
  }

  Future<void> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      selectedAudioPath = file.path;

      print('Selected audio: $selectedAudioPath');

      audioTitle = file.name;

      // Intenta cargar y reproducir el audio
      try {
        await audioPlayer.setSourceUrl(selectedAudioPath!);
        await audioPlayer.getDuration().then((value) {
          if (value != null) {
            setState(() {
              duration = value;
              isMediaReceived = true;
            });
          }
        });
      } catch (e) {
        print('Error al cargar/reproducir el audio: $e');
        // Maneja el error aquí (por ejemplo, muestra un mensaje al usuario)
      }
    } else {
      // El usuario canceló la selección
      selectedAudioPath = null;
    }
  }

  void cargarAudio() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AudioModal(
          pickedAudios: pickedAudios,
          onAudiosSelected: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.audio,
            );

            List<File> newAudios = [];
            if (result != null) {
              newAudios.add(File(result.files.first.path!));
            }
            // pickAudio();
            return newAudios;
          },
        );
      },
    );
  }

  double lat = 0.0;
  double long = 0.0;

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

  String audioPath = "";
  void _printAudioPaths() {
    for (File audioFile in pickedAudios) {
      audioPath = audioFile.path;
      print('Audio Path_______: $audioPath');
    }
  }

//   String? _selectedName;
//   final List<String> _names = [];

List<DenuncianteData> _mapSnapshotToUserCase(QuerySnapshot snapshot) {
  return snapshot.docs
    .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final denuncianteData = data['denunciante'] as Map<String, dynamic>?;

      if (denuncianteData != null) {
        return DenuncianteData(
          userId: denuncianteData['userId'] ?? '',
          fullName: denuncianteData['fullname'] ?? '',
          ci: denuncianteData['ci'] ?? 0,
          phone: denuncianteData['phone'] ?? 0,
          lat: denuncianteData['lat'] ?? 0.0,
          long: denuncianteData['long'] ?? 0.0,
          documentId: doc.id, 
          estado: data['estado'] ?? '',
        );
      } else {
        return DenuncianteData(
          userId: '',
          fullName: '', 
          ci: 0, 
          phone: 0, 
          lat: 0.0, 
          long: 0.0, 
          documentId: doc.id,
          estado: data['estado'] ?? '',
        );
      }
    }).toList();
  }

  Future<List<DenuncianteData>> _fetchData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
    .collection('cases')
    .where('estado', isEqualTo: 'pendiente')
    .where('supervisor', isEqualTo: widget.user!.uid)
    .get();

    return _mapSnapshotToUserCase(snapshot);
  }

  void createEvidence() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(255, 87, 110, 1),
            )
          );
        });
    _printAudioPaths();
    try {
      if (pickedImages.isEmpty ||
          pickedDocument.isEmpty ||
          audioPath.isEmpty ||
          // selectedAudioPath == null ||
          desController.text.trim().isEmpty ||
          date == null ||
          lat == 0.0 ||
          long == 0.0 ||
          _selectedName == null ||
          conclusionController.text.trim().isEmpty) {
        Navigator.pop(context);
        showErrorMsg('Por favor llene todos los campos');
        return;
      }

      await createUserDocument(
        EvidenceData(
          description: desController.text.trim(),
          date: date,
          lat: lat,
          long: long,
          imageUrls: pickedImages.map((e) => e.path).toList(),
          // audioUrl: selectedAudioPath!,
          audioUrl: audioPath,
          documentUrl: pickedDocument.first.path,
          selectedUser: _selectedName!.documentId,
          conclusion: conclusionController.text.trim(),
        ),
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidencia enviada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushNamed(context, '/screens_supervisor');

      setState(() {
        pickedImages.clear();
        pickedDocument.clear();
        pickedAudios.clear();
        desController.clear();
        conclusionController.clear();
        dateController.clear();
        latController.clear();
        longController.clear();
        isImageReceived = false;
        isDocumentReceived = false;
        isMediaReceived = false;
        _selectedName = null;
        changesMade = false;
      });

    } catch (e) {
      Navigator.pop(context);
      print('Error al enviar el evidencia: $e');
    } 
  }

  Future<void> createUserDocument(EvidenceData evidenceData) async {
    List<File> imageFiles = evidenceData.imageUrls.map((e) => File(e)).toList();
    List<String> imageUrls = await uploadImageFile(evidenceData.selectedUser, imageFiles);
    String audioUrl = await uploadAudioFile(File(evidenceData.selectedUser).path, File(evidenceData.audioUrl));
    String documentUrl =
        await uploadDocumentFiles(File(evidenceData.selectedUser).path, File(evidenceData.documentUrl));

    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('evidence').doc();
      await docRef.set({
        'imageUrl': imageUrls,
        'audioUrl': audioUrl,
        'document': documentUrl,
        'descripcion': evidenceData.description,
        'conclusion': evidenceData.conclusion,
        'fecha': evidenceData.date,
        'lat': evidenceData.lat,
        'long': evidenceData.long,
        'case': _selectedName!.documentId,
      });

      await FirebaseFirestore.instance
          .collection('cases')
          .doc(_selectedName!.documentId)
          .update({
            'estado': 'finalizado',
          });

      Navigator.pop(context);
      print('Evidencia creada exitosamente! con el ID: ${docRef.id}');
    } catch (e) {
      // ignore: avoid_print
      print('Error al crear documento del usuario: $e');
    }
  }

  void showErrorMsg(String errorMsg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg,
            style: const TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.red,
      ),
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchCaseUsers().then((value) {
  //     setState(() {
  //       denunciantesList = value;
  //     });
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
  }

  DateTime date = DateTime.now();
  TimeOfDay timeOfDay = TimeOfDay.now();
  bool changesMade = false;

  DenuncianteData? _selectedName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
          child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              const Row(
                children: [
                  Header(
                    header: 'Datos del Evidencia',
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: RowButton(
                      onTap: cargarImagen,
                      text: 'Imagen',
                      icon: Icons.image,
                    ),
                  ),
                  Expanded(
                    child: RowButton(
                      onTap: cargarDocumento,
                      text: 'Documento',
                      icon: Icons.file_copy,
                    ),
                  ),
                  Expanded(
                    child: RowButton(
                      onTap: cargarAudio,
                      text: 'Audio',
                      icon: Icons.audiotrack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              LimitCharacterTwo(
                controller: desController,
                text: 'Descripción del Evidencia', // 'Descripción del Incidente
                hintText: 'Descripción del Evidencia',
                obscureText: false,
                isEnabled: true,
                isVisible: true,
              ),
              const SizedBox(height: 15),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Seleccionar Fecha del Evidencia',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${date.year}/${date.month}/${date.day}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(248, 181, 149, 1)),
                      ),
                      child: const Text('Seleccionar Fecha'),
                      onPressed: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color.fromRGBO(248, 181, 149, 1),
                                  onPrimary: Colors.black,
                                  surface: Color.fromRGBO(248, 181, 149, 1),
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: Colors.black,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (selectedDate == null) return;

                        // Create a new DateTime object with the selected date and the fixed time
                        DateTime selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          timeOfDay.hour,
                          timeOfDay.minute,
                        );

                        setState(() {
                          date = selectedDateTime;
                        });
                      },
                    ),
                  ],
                ),
              ),
              FutureBuilder<Map<String, String>>(
                  future: getUserModifiedLocation(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(255, 87, 110, 1),
                        )
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
                  }
                ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromRGBO(248, 181, 149, 1)),
                ),
                onPressed: () async {
                  final selectedLocation = await Navigator.of(context).push(
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
                    final locationData = await getUserModifiedLocation();
                    final calle = locationData['street'];
                    final localidad = locationData['locality'];
                    final pais = locationData['country'];
                    latController.text = lat.toString();
                    longController.text = long.toString();
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
                    changesMade = true;
                  }
                },
                child: const Text('Seleccionar Ubicacion'),
              ),
              const SizedBox(height: 15),
              LimitCharacterTwo(
                controller: conclusionController,
                text: 'Conclusion Final', // 'Conclusiones del Incidente
                hintText: 'Conclusiones Final',
                obscureText: false,
                isEnabled: true,
                isVisible: true,
              ),

              const SizedBox(height: 25),
              FutureBuilder<List<DenuncianteData>>(
                future: _fetchData(), 
                builder: (BuildContext context, AsyncSnapshot<List<DenuncianteData>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      color: Color.fromRGBO(255, 87, 110, 1),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return DropdownButton<String>(
                      value: _selectedName?.userId,
                      hint: const Text('Seleccionar Denunciante'),
                      items: snapshot.data!.map((DenuncianteData user) {
                        return DropdownMenuItem<String>(
                          value: user.userId,
                          child: Text(user.fullName),
                        );
                      }).toList(), 
                      onChanged: (String? userId) {
                        setState(() {
                          _selectedName = snapshot.data!.firstWhere((user) => user.userId == userId);
                          print('Selected User: ${_selectedName!.fullName}');
                        });
                      },
                    );
                  }
                }
              ),
              const SizedBox(height: 30),
              MyImportantBtn(onTap: createEvidence, text: 'Finalizar'),
              const SizedBox(height: 30),
            ],
          ),
        ],
      )),
    ));
  }
}
