import 'package:agora_demo/screens/agora_chat_page.dart';
import 'package:agora_demo/screens/audio_call_page.dart';
import 'package:agora_demo/screens/video_call_page.dart';
import 'package:agora_demo/screens/video_stream_page.dart';
import 'package:flutter/material.dart';

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Widget button(title, onPressItem) {
    return ElevatedButton(
      child: Text(
        title,
        style: const TextStyle(fontSize: 20.0),
      ),
      onPressed: () {
        onPressItem();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            button(
                'Live Stream',
                () => {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const VideoStreamPage()))
                    }),
            button(
                'Video Call',
                () => {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const VideoCallPage())),
                    }),
            button(
                'Audio Call',
                () => {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AudioCallPage())),
                    }),
            button(
                'Agora Chat',
                () => {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              const AgoraChatPage(title: 'Agora Chat'))),
                    }),
          ],
        ),
      ),
    );
  }
}
