// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/limit_characters.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/components/row_button.dart';
import 'package:miamiga_app/pages/map.dart';

class CasePage extends StatefulWidget {
  final String item;

  const CasePage({super.key, required this.item});

  @override
  State<CasePage> createState() => _CasePageState();
}

class _CasePageState extends State<CasePage> {
  final desController = TextEditingController();
  final dateController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();

  List<XFile> pickedImages = [];
  String? selectedAudioPath;
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  double sliderValue = 0.0;

  String audioTitle = '';

  List<File> pickedFiles = [];
  bool isDocumentReceived = false;

  bool isImageReceived = false;
  bool isMediaReceived = false;

  Future selectImageFile() async {
    final result = await ImagePicker().pickMultiImage(
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      imageQuality: 80,
    );
    if (result != null) {
      setState(() {
        for (var image in result) {
          pickedImages.add(image);
        }
        isImageReceived = true;
      });
    }
  }

  void cargarImagen() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 300, // Adjust the width as needed
            height: 300, // Adjust the height as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Seleccionar Imagen',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: pickedImages.length,
                    itemBuilder: (context, index) {
                      final image = pickedImages[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: SizedBox(
                                  child: Image.file(
                                    File(image.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Image.file(
                          File(image.path),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                if (pickedImages.isEmpty)
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ElevatedButton.icon(
                      onPressed: selectImageFile,
                      icon: const Icon(
                        Icons.add_a_photo,
                        size: 50,
                      ),
                      label: const SizedBox.shrink(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        backgroundColor: const Color.fromRGBO(248, 181, 149, 1),
                      ),
                    ),
                  ),
                if (pickedImages.isNotEmpty)
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(248, 181, 149, 1)),
                    ),
                    onPressed: () {
                      selectImageFile();
                    },
                    child: const Text('Agregar otra imagen'),
                  )
              ],
            ),
          ),
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
        pickedFiles.add(File(result.files.single.path!));
        isDocumentReceived = true;
      });
    }
  }

  void cargarDocumento() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              width: 300,
              height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Seleccionar Documento',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                        itemCount: pickedFiles.length,
                        itemBuilder: (context, index) {
                          final file = pickedFiles[index];
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: SizedBox(
                                      child: Text(
                                        'Documento: ${file.path}',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Documento: ${file.path}',
                            ),
                          );
                        }),
                  ),
                  if (pickedFiles.isEmpty)
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: ElevatedButton.icon(
                        onPressed: selectDocumentFile,
                        icon: const Icon(
                          Icons.file_copy,
                          size: 50,
                        ),
                        label: const SizedBox.shrink(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          backgroundColor:
                              const Color.fromRGBO(248, 181, 149, 1),
                        ),
                      ),
                    ),
                  if (pickedFiles.isNotEmpty)
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(248, 181, 149, 1))),
                      onPressed: selectDocumentFile,
                      child: const Text('Agregar otro documento'),
                    )
                ],
              ),
            ),
          );
        });
  }

  Future<void> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      selectedAudioPath = file.path;

      audioTitle = file.name;

      print('audioRuta______$selectedAudioPath');

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
        return AlertDialog(
          content: SizedBox(
            width: 300, // Adjust the width as needed
            height: 300, // Adjust the height as needed
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Seleccionar Audio',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (selectedAudioPath != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Titulo del Audio: $audioTitle',
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  if (selectedAudioPath != null)
                    Column(
                      children: [
                        Slider(
                          value: sliderValue,
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              sliderValue = value;
                              audioPlayer
                                  .seek(Duration(seconds: value.toInt()));
                            });
                          },
                        ),
                      ],
                    ),
                  if (selectedAudioPath != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon:
                              Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          iconSize: 50.0,
                          onPressed: () {
                            if (isPlaying) {
                              audioPlayer.pause();
                            } else {
                              audioPlayer.resume();
                            }
                            setState(() {
                              isPlaying = !isPlaying;
                            });
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            audioPlayer.stop();
                            setState(() {
                              isPlaying = false;
                              sliderValue = 0.0;
                            });
                          },
                          icon: const Icon(Icons.stop),
                        ),
                      ],
                    ),
                  SizedBox(
                      width: 100,
                      height: 100,
                      child: ElevatedButton.icon(
                        onPressed: pickAudio,
                        icon: const Icon(
                          Icons.music_note,
                          size: 50,
                        ),
                        label: const SizedBox.shrink(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          backgroundColor:
                              const Color.fromRGBO(248, 181, 149, 1),
                        ),
                      )),
                ],
              ),
            ),
          ),
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

  void createEvidence() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      if (areFieldsEmpty()) {
        Navigator.pop(context);
        showErrorMsg('Por favor llene todos los campos');
        return;
      }

      await createUserDocument(
        pickedImages[0].path,
        selectedAudioPath!,
        pickedFiles[0].path,
        desController.text.trim(),
        date,
        double.parse(latController.text.trim()),
        double.parse(longController.text.trim()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidencia enviada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error al enviar el evidencia: $e');
      Navigator.pop(context);
    }
  }

  Future<void> createUserDocument(
      String imageUrl,
      String audioUrl,
      String document,
      String descripcion,
      DateTime fecha,
      double lat,
      double long) async {
    try {
      await FirebaseFirestore.instance.collection('evidence').doc().set({
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'document': document,
        'descripcion': descripcion,
        'fecha': fecha,
        'lat': lat,
        'long': long,
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error al crear documento del usuario: $e');
      Navigator.pop(context);
    }
  }

  bool areFieldsEmpty() {
    return desController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        latController.text.trim().isEmpty ||
        longController.text.trim().isEmpty ||
        !isImageReceived ||
        !isMediaReceived ||
        !isDocumentReceived ||
        lat == 0.0 ||
        long == 0.0;
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

  @override
  void dispose() {
    audioPlayer.dispose();
    pickedImages.clear();
    pickedFiles.clear();
    desController.dispose();
    dateController.dispose();
    latController.dispose();
    longController.dispose();
    super.dispose();
  }

  DateTime date = DateTime.now();
  TimeOfDay timeOfDay = TimeOfDay.now();
  bool changesMade = false;

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
                    header: 'Datos de la Evidencia',
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
              LimitCharacter(
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
                      return const CircularProgressIndicator();
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
              const SizedBox(height: 30),
              MyImportantBtn(onTap: createEvidence, text: 'Finalizar'),
            ],
          ),
        ],
      )),
    ));
  }
}
