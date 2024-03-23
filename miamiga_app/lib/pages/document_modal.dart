// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';

class DocumentModal extends StatefulWidget {
  final List<File> pickedDocuments;
  final Future<List<File>> Function() onDocumentsSelected;

  const DocumentModal(
      {super.key, required this.pickedDocuments, required this.onDocumentsSelected});

  @override
  _DocumentModalState createState() => _DocumentModalState();
}

class _DocumentModalState extends State<DocumentModal> {

  @override
  Widget build(BuildContext context) {
    String documentFileName = widget.pickedDocuments.isNotEmpty
      ? widget.pickedDocuments.first.path.split('/').last
      : '';
    return AlertDialog(
      content: SizedBox(
        width: 300,
        height: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // const Padding(
            //   padding: EdgeInsets.all(24.0),
            //   child: Text(
            //     'Seleccionar Documento',
            //     style: TextStyle(
            //       fontSize: 20.0,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            Expanded(
              child: PageView.builder(
                itemCount: widget.pickedDocuments.length,
                itemBuilder: (context, index) {
                  // final document = widget.pickedDocuments[index];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              child: Text(
                                'Nombre del Document: $documentFileName',
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      'Nombre del Documento: $documentFileName',
                    ),
                  );
                },
              ),
            ),
            if (widget.pickedDocuments.isEmpty)
              SizedBox(
                width: 100,
                height: 100,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget
                        .onDocumentsSelected()
                        .then((List<File> newDocuments) {
                      setState(() {
                        widget.pickedDocuments.clear();
                        widget.pickedDocuments.addAll(newDocuments);
                      });
                    });
                  },
                  icon: const Icon(
                    Icons.file_copy,
                    size: 50,
                  ),
                  label: const SizedBox.shrink(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    backgroundColor: const Color.fromRGBO(248, 181, 149, 1),
                  ),
                ),
              ),
            if (widget.pickedDocuments.isNotEmpty)
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromRGBO(248, 181, 149, 1)),
                ),
                onPressed: () {
                  widget.onDocumentsSelected().then((List<File> newDocuments) {
                    setState(() {
                      widget.pickedDocuments.clear();
                      widget.pickedDocuments.addAll(newDocuments);
                    });
                  });
                },
                child: const Text('Cambiar Documento'),
              )
          ],
        ),
      ),
    );
  }
}
