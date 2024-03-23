import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io' show File;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';

void main() => runApp(const AddMultimediaProductsMovil());

class AddMultimediaProductsMovil extends StatefulWidget {
  const AddMultimediaProductsMovil({Key? key});

  @override
  State<AddMultimediaProductsMovil> createState() =>
      _AddMultimediaProductsMovilState();
}

class _AddMultimediaProductsMovilState
    extends State<AddMultimediaProductsMovil> {
  List<Uint8List> selectedImages = [];
  // String idProducto = "";
  dynamic image1;
  dynamic image2;
  dynamic video;
  dynamic videoController;
  VideoPlayerController? _controller;
  final picker = ImagePicker();
  bool isVideoPlaying = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dynamic argument = ModalRoute.of(context)!.settings.arguments;
    //  idProducto = argument as String;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Fotos"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Selecciona fotos:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => selectImage(),
                    child: Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[200],
                      child: selectedImages.isNotEmpty
                          ? _buildPageView()
                          : const Icon(Icons.add_a_photo, size: 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectImage,
                      child: const Text('Seleccionar fotos'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool checkFilesAdded() {
    return image1 != null || image2 != null || video != null;
  }

  Widget _buildPageView() {
    return PageView.builder(
      itemCount: selectedImages.length,
      itemBuilder: (context, index) {
        return _buildImageWidget(selectedImages[index]);
      },
    );
  }
  // void _startUploading() async {
  //   if (!checkFilesAdded()) {
  //     GlobalMethods.showToast("Debe agregar al menos una foto o video");
  //     return;
  //   }
  //   ProgressDialog pd = ProgressDialog(context: context);
  //   pd.show(
  //     max: 100,
  //     msg: 'Subiendo archivos...',
  //     progressType: ProgressType.valuable,
  //   );

  //   int totalUploads = 0;

  //   if (image1 != null) {
  //     totalUploads++;
  //   }

  //   if (image2 != null) {
  //     totalUploads++;
  //   }

  //   if (video != null) {
  //     totalUploads++;
  //   }

  //   int uploadsCompleted = 0;

  //   if (image1 != null) {
  //     String imageUrl1 =
  //         await _uploadImage(image1, "$idProducto/imagen1", (progress) {
  //       double overallProgress =
  //           (uploadsCompleted + progress) / totalUploads * 100;
  //       pd.update(value: overallProgress.toInt());
  //     });
  //     if (imageUrl1.isNotEmpty) {
  //       GlobalMethods.showToast("Imagen 1: Subido correctamente!");
  //     } else {
  //       GlobalMethods.showToast("Imagen 1: Error al subir!");
  //     }
  //     uploadsCompleted++;
  //   }

  //   if (image2 != null) {
  //     String imageUrl2 =
  //         await _uploadImage(image2, "$idProducto/imagen2", (progress) {
  //       double overallProgress =
  //           (uploadsCompleted + progress) / totalUploads * 100;
  //       pd.update(value: overallProgress.toInt());
  //     });
  //     if (imageUrl2.isNotEmpty) {
  //       GlobalMethods.showToast("Imagen 2: Subido correctamente!");
  //     } else {
  //       GlobalMethods.showToast("Imagen 2: Error al subir!");
  //     }
  //     uploadsCompleted++;
  //   }

  //   if (video != null) {
  //     String videoUrl =
  //         await _uploadVideo(video, "$idProducto/video", (progress) {
  //       double overallProgress =
  //           (uploadsCompleted + progress) / totalUploads * 100;
  //       pd.update(value: overallProgress.toInt());
  //     });
  //     if (videoUrl.isNotEmpty) {
  //       GlobalMethods.showToast("Video: Subido correctamente!");
  //     } else {
  //       GlobalMethods.showToast("Video: Error al subir!");
  //     }
  //     uploadsCompleted++;
  //   }

  //   pd.update(value: 100); // Actualizar la barra de progreso al 100%.
  //   pd.close(); // Ocultar el diálogo de progreso después de completar todas las subidas.

  //   Navigator.pop(context);
  // }

  Widget _buildImageWidget(dynamic image) {
    if (image is Uint8List) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(image, fit: BoxFit.cover),
      );
    } else if (image is File) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(image, fit: BoxFit.cover),
      );
    } else {
      return Container(); // O un widget por defecto, si image es de otro tipo
    }
  }

  Future<void> selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // Permitir seleccionar múltiples imágenes
    );

    if (result != null) {
      List<Uint8List> imageBytes = [];
      for (final file in result.files) {
        Uint8List bytes = await File(file.path!).readAsBytes();
        imageBytes.add(bytes);
      }

      setState(() {
        selectedImages = imageBytes;
      });
    }
  }

  Future<String> _uploadImage(
      Uint8List image, String fileName, Function(double) updateProgress) async {
    firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.ref().child(fileName);

    firebase_storage.UploadTask uploadTask = reference.putData(
      image,
      firebase_storage.SettableMetadata(contentType: 'image/png'),
    );

    uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      updateProgress(
          progress); // Llama a la función de devolución de llamada para actualizar el progreso.
    });

    firebase_storage.TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => true);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }
}
