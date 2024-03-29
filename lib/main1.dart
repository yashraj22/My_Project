import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';

List<SpeechNote> dummyData = [];

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remember AI',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  int _selectedIndex = 0;
  String lastStatus = '';
  final _textEditingController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(onStatus: statusListener);
    setState(() {});
  }

  void _startListening() async {
    _speechToText.listen(onResult: _onSpeechResult);
    _lastWords = "";
    _textEditingController.text = "";
    setState(() {});
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
    });
  }

  void _stopListening() async {
    _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _textEditingController.text = _lastWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        centerTitle: true,
      ),
      body: _selectedIndex == 0
          ? HomeScreen(
              speechToText: _speechToText,
              lastWords: _lastWords,
              speechEnabled: _speechEnabled,
              textEditingController: _textEditingController,
            )
          : const HistoryScreen(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _speechToText.isNotListening
                  ? _startListening
                  : _stopListening,
              tooltip: 'Listen',
              child:
                  Icon(_speechToText.isNotListening ? Icons.mic : Icons.stop),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
            ),
            label: "History",
          ),
        ],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}

class ImageUtils {
  File? _pickedImage;

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      _pickedImage = File(pickedImage.path);
    }
    return _pickedImage;
  }
}

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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Recognized words:',
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
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget._speechToText.isListening
                  ? widget._lastWords
                  : widget._speechEnabled
                      ? 'Last Phrase: ${widget._lastWords}\n\nthe microphone to start listening...'
                      : 'Speech not available',
            ),
          ),
          SizedBox(
            height: 200,
            width: 200,
            child: imageFile != null
                ? Image.file(imageFile!)
                : const Center(
                    child: Text("No Image Provided",
                        style: TextStyle(color: Colors.grey)),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // print("called");
                  final img = await widget.imageUtils.pickImage();
                  setState(() {
                    imageFile = img;
                  });
                },
                child: const Text('Pick Image'),
              ),
              const SizedBox(
                height: 0,
                width: 20,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  imageFile = null;
                }),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              dummyData.add(SpeechNote(
                  text: widget.textEditingController.text, image: imageFile!));
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}

class SpeechNote {
  final String text;
  final File image;

  SpeechNote({
    required this.text,
    required this.image,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: dummyData.length,
          itemBuilder: (_, index) {
            return ListTile(
              enableFeedback: true,
              title: Text(dummyData[index].text),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // delete logic here
                  setState(() {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Delete Item"),
                            content: const Text(
                                "Are you sure you want to delete this item?"),
                            actions: [
                              TextButton(
                                child: const Text("CANCEL"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text("DELETE"),
                                onPressed: () {
                                  // Delete item
                                  setState(() {
                                    dummyData.removeWhere((element) =>
                                        element == dummyData[index]);
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  });
                },
              ),
            );
          }),
    );
  }
}
