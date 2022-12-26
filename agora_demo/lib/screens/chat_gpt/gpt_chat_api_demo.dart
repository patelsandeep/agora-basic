import 'package:agora_demo/screens/widget/chat_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt_api/flutter_chatgpt_api.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:translator/translator.dart';

import '../../api/api.dart';

class GptChatAPIDemo extends StatefulWidget {
  const GptChatAPIDemo({
    super.key,
  });

  @override
  State<GptChatAPIDemo> createState() => _GptChatAPIDemoState();
}

class _GptChatAPIDemoState extends State<GptChatAPIDemo> {
  final SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
  String _convertedWords = '';
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool isLoading = false;

  @override
  initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  @override
  void dispose() async {
    super.dispose();
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    setState(() => _convertedWords = '');
    await _speechToText.listen(
      onResult: _onSpeechResult,
      onDevice: true,
      listenFor: const Duration(seconds: 30),
    );
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on thef
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() => _lastWords = result.recognizedWords);
    if (result.finalResult) {
      translateText(_lastWords);
    }
  }

  Future<void> translateText(String recognizedWords) async {
    searchGPT(recognizedWords);
  }

  searchGPT(String text) async {
    setState(
      () {
        isLoading = true;
        _messages.add(
          ChatMessage(
            text: text,
            chatMessageType: ChatMessageType.user,
          ),
        );
      },
    );
    // Save the input and clearing the text field.
    var input = text;
    _textController.clear();

    var newMessage = await API.shared.getMessage(input);

    //To speak result

    // GoogleTranslator()
    //     .translate(newMessage['choices'][0]['text'], from: 'en', to: 'hi')
    //     .then((result) {
    //   setState(() => _convertedWords = result.toString());
    //   TextToSpeech tts = TextToSpeech();
    //   tts.setVolume(1);
    //   tts.setRate(1);
    //   tts.setPitch(1);
    //   tts.setLanguage('hi');
    //   tts.speak(_convertedWords);
    // });

    setState(() {
      isLoading = false;
      _messages.add(
        ChatMessage(
          text: newMessage['choices'][0]['text']
              .replaceFirst(RegExp('\r\n|\r|\n'), ''),
          chatMessageType: ChatMessageType.bot,
        ),
      );
    });
    _textController.clear();

    //  Needs a delay or the scroll won't always work.
    Future.delayed(const Duration(milliseconds: 50)).then((_) => _scrollDown());
  }

  IconButton _buildSubmit() {
    return IconButton(
      icon: const Icon(Icons.send),
      onPressed: () async {
        if (_textController.text.isNotEmpty) {
          searchGPT(_textController.text);
        }
      },
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        controller: _textController,
        decoration: const InputDecoration(
          hintText: 'Enter a message',
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat GPT'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: _buildList(),
              ),
              (isLoading) ? const CircularProgressIndicator() : Container(),
              Row(
                children: [
                  _buildInput(),
                  _buildSubmit(),
                  GestureDetector(
                      onLongPressDown: (details) {
                        _startListening();
                      },
                      onLongPressUp: () {
                        _stopListening();
                      },
                      onTap: _speechToText.isNotListening
                          ? _startListening
                          : _stopListening,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: kElevationToShadow[2],
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Icon(
                            _speechToText.isNotListening
                                ? Icons.mic
                                : Icons.mic_off,
                            color: Colors.white),
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
