// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageModal extends StatefulWidget {
  final List<XFile> pickedImages;
  final Future<List<XFile>> Function(ImageSource source) onImagesSelected;
  // final Function(List<XFile>) updateImages;

  const ImageModal({
    super.key, 
    required this.pickedImages, 
    required this.onImagesSelected,
    // required this.updateImages,
  });

  @override
  _ImageModalState createState() => _ImageModalState();
}

class _ImageModalState extends State<ImageModal> {

  // void updateImages(List<XFile> newImages) {
  //   setState(() {
  //     widget.pickedImages.addAll(newImages);
  //   });
  // }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                itemCount: widget.pickedImages.length,
                itemBuilder: (context, index) {
                  final image = widget.pickedImages[index];
                  return Stack(
                    children: <Widget>[
                      GestureDetector(
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
                        child: Center(
                          child: Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              widget.pickedImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onImagesSelected(ImageSource.gallery).then((List<XFile> newImages) {
                        setState(() {
                          widget.pickedImages.addAll(newImages);
                        });
                      });
                    },
                    icon: const Icon(
                      Icons.photo,
                      size: 50,
                    ),
                    label: const SizedBox.shrink(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      backgroundColor: const Color.fromRGBO(248, 181, 149, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onImagesSelected(ImageSource.camera).then((List<XFile> newImages) {
                        setState(() {
                          widget.pickedImages.addAll(newImages);
                        });
                      });
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 50,
                    ),
                    label: const SizedBox.shrink(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      backgroundColor: const Color.fromRGBO(248, 181, 149, 1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
