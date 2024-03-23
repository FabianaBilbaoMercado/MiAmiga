// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

class AudioModal extends StatefulWidget {
  final List<File> pickedAudios;
  final Future<List<File>> Function() onAudiosSelected;

  const AudioModal({super.key, required this.pickedAudios, required this.onAudiosSelected});

  @override
  _AudioModalState createState() => _AudioModalState();
}

class _AudioModalState extends State<AudioModal> {
  just_audio.AudioPlayer audioPlayer = just_audio.AudioPlayer();
  String audioUrl = '';
  bool isPlaying = false;
  // double sliderValue = 0.0;
  Duration duration = const Duration();

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String audioFileName = widget.pickedAudios.isNotEmpty
        ? widget.pickedAudios.first.path.split('/').last
        : '';

    return AlertDialog(
      content: SingleChildScrollView(
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // const Padding(
              //   padding: EdgeInsets.all(24.0),
              //   child: Text(
              //     'Seleccionar Audio',
              //     style: TextStyle(
              //       fontSize: 20.0,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              if (widget.pickedAudios.isNotEmpty) ...[
                Column(
                  children: [
                    Text(
                      'Nombre del Audio: $audioFileName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () async {
                            audioUrl = widget.pickedAudios.first.path;
                            await audioPlayer.setUrl('file://$audioUrl');
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
                  ],
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromRGBO(248, 181, 149, 1)),
                  ),
                  onPressed: () {
                    widget.onAudiosSelected().then((List<File> newAudios) {
                      setState(() {
                        widget.pickedAudios.clear();
                        widget.pickedAudios.addAll(newAudios);
                        isPlaying = false;
                        audioPlayer.stop();
                      });
                    });
                  },
                  child: const Text('Cambiar audio'),
                ),
              ],
              if (widget.pickedAudios.isEmpty) ... [
                  SizedBox(
                  width: 100,
                  height: 100,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onAudiosSelected().then((List<File> newAudios) {
                        if (mounted) {
                          setState(() {
                            widget.pickedAudios.addAll(newAudios);
                            isPlaying = false;
                            audioPlayer.stop();
                          });
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.music_note,
                      size: 50,
                    ),
                    label: const SizedBox.shrink(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      backgroundColor: const Color.fromRGBO(248, 181, 149, 1),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
