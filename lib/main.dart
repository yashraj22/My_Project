import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'pages/history.dart';
import 'pages/homescreen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'database.dart';

List<String> Data = [];

const notesData = 'notesData';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox<String>(notesData);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      title: 'Voice Notes',
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
    notesDataBox = Hive.box(notesData);
    if (notesDataBox.isNotEmpty) {
      for (int i = 0; i < notesDataBox.length; i++) {
        Data.add(notesDataBox.getAt(i)!);
      }
    }
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(onStatus: statusListener);
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    _speechToText.listen(onResult: _onSpeechResult);
    _lastWords = "";
    _textEditingController.text = "";
    setState(() {});
  }

  void statusListener(String status) {
    // print(
    //     'Received listener status: $status, listening: ${_speechToText.isListening}');
    setState(() {
      lastStatus = status;
      // status == "done" && _lastWords.isNotEmpty
      //     ? {dummyData.add(_lastWords)}
      //     : null;
    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
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
        title: const Text('Voice Notes'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(54, 48, 98, 1),
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
              backgroundColor: Color.fromRGBO(54, 48, 98, 1),
              onPressed:
                  // If not yet listening for speech start, otherwise stop
                  _speechToText.isNotListening
                      ? _startListening
                      : _stopListening,
              tooltip: 'Listen',
              child:
                  Icon(_speechToText.isNotListening ? Icons.mic : Icons.stop),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromRGBO(54, 48, 98, 1),
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

// class SpeechRecognition {
//   final SpeechToText _speechToText = SpeechToText();
//   bool _speechEnabled = false;
//   String _lastWords = '';
//   int _selectedIndex = 0;
//   String lastStatus = '';

//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//   }

//   /// This has to happen only once per app
//   void _initSpeech() async {
//     _speechEnabled = await _speechToText.initialize(onStatus: statusListener);
//     setState(() {});
//   }

//   /// Each time to start a speech recognition session
//   void _startListening() async {
//     _speechToText.listen(onResult: _onSpeechResult);
//     _lastWords = "";
//     _textEditingController.text = "";
//     setState(() {});
//   }

//   void statusListener(String status) {
//     // print(
//     //     'Received listener status: $status, listening: ${_speechToText.isListening}');
//     setState(() {
//       lastStatus = status;
//       status == "done" && _lastWords.isNotEmpty
//           ? {dummyData.add(_lastWords)}
//           : null;
//     });
//   }

//   /// Manually stop the active speech recognition session
//   /// Note that there are also timeouts that each platform enforces
//   /// and the SpeechToText plugin supports setting timeouts on the
//   /// listen method.
//   void _stopListening() async {
//     _speechToText.stop();
//     setState(() {});
//   }

//   /// This is the callback that the SpeechToText plugin calls when
//   /// the platform returns recognized words.
//   void _onSpeechResult(SpeechRecognitionResult result) {
//     setState(() {
//       _lastWords = result.recognizedWords;
//       _textEditingController.text = _lastWords;
//     });
//   }
// }

// Extract speech to text logic from _HomePageState class to a seperate SpeechToTextRecognition Class.
class SpeechToTextRecognition {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  int _selectedIndex = 0;
  String lastStatus = '';
  final _textEditingController = TextEditingController();

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    _textEditingController.text = _lastWords;
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  void _startListening() async {
    _speechToText.listen(onResult: _onSpeechResult);
    _lastWords = "";
    _textEditingController.text = "";
  }

  void statusListener(String status) {
    // print(
    //     'Received listener status: $status, listening: ${_speechToText.isListening}');
    lastStatus = status;
    // status == "done" && _lastWords.isNotEmpty
    //     ? {dummyData.add(_lastWords)}
    //     : null;
  }

  void _stopListening() async {
    _speechToText.stop();
  }
}
