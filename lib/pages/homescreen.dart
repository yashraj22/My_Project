import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:app/database.dart';
import '../main.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final SpeechToText _speechToText;
  final String _lastWords;
  final bool _speechEnabled;
  final TextEditingController textEditingController;
  final ImageUtils imageUtils = ImageUtils();

  HomeScreen({
    super.key,
    required SpeechToText speechToText,
    required String lastWords,
    required bool speechEnabled,
    required this.textEditingController,
  })  : _speechToText = speechToText,
        _lastWords = lastWords,
        _speechEnabled = speechEnabled;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: prefer_final_fields
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(color: Color.fromRGBO(77, 76, 125, 1)),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Recognized Note:',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                child: TextFormField(
                  minLines: 6,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: widget.textEditingController,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    labelText: 'Enter text',
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromRGBO(54, 48, 98, 1)),
                    ),
                    onPressed: () {
                      if (widget.textEditingController.text.isNotEmpty) {
                        Data.add(
                          widget.textEditingController.text,
                        );
                        notesDataBox.put(
                            Data.indexOf(widget.textEditingController.text),
                            widget.textEditingController.text);
                      }
                    },
                    child: const Text("Save"),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.textEditingController.clear();
                    },
                    icon: const Icon(Icons.clear),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
