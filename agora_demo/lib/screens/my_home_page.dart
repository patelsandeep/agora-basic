import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:text_to_speech/text_to_speech.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  late Timer _timer;
  String _lastWords = '';
  String _convertedWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    // _timer = new Timer(const Duration(milliseconds: 2000), () {
    translateText(_lastWords);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Demo'),
      ),
      body: Center(
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  // If listening is active show the recognized words
                  _speechToText.isListening
                      ? _lastWords
                      // If listening isn't active but could be tell the user
                      // how to start it, otherwise indicate that speech
                      // recognition is not yet ready or not supported on
                      // the target device
                      : _speechEnabled
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                    // If listening is active show the recognized words
                    _convertedWords),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            // If not yet listening for speech start, otherwise stop
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }

  Future<void> translateText(String recognizedWords) async {
    final translator = GoogleTranslator();
    final input = recognizedWords;

    translator.translate(input, from: 'en', to: 'hi').then((result) {
      print("RESULT :: ");
      print(result);
      setState(() {
        _convertedWords = result.toString();
      });
      print("CONVERTED WORDS :: ");
      print(_convertedWords);
      TextToSpeech tts = TextToSpeech();
      tts.speak(_convertedWords);
      tts.setVolume(1);
      tts.setRate(1);
      tts.setPitch(1);
      tts.setLanguage('hi');
    });

    // // Passing the translation to a variable
    // var translation = await translator
    //     .translate("I would buy a car, if I had money.", from: 'en', to: 'it');

    // // You can also call the extension method directly on the input
    // print('Translated: ${await input.translate(to: 'en')}');

    // // For countries that default base URL doesn't work
    // translator.baseUrl = "translate.google.cn";
    // translator.translateAndPrint("This means 'testing' in chinese",
    //     to: 'zh-cn');
    // //prints 这意味着用中文'测试'

    // print("translation: $translation");
  }
}
