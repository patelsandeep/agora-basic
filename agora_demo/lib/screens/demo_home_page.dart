import 'package:agora_demo/screens/agora_chat_page.dart';
import 'package:agora_demo/screens/gpt_chat_api_demo.dart';
import 'package:agora_demo/screens/video_call_page.dart';
import 'package:agora_demo/screens/video_stream_page.dart';
import 'package:flutter/material.dart';
import 'audio_call_page.dart';

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

  Widget item(String title, img, onPressItem, iconColor) {
    return Expanded(
        child: GestureDetector(
            onTap: () {
              onPressItem();
            },
            child: Container(
                height: 100,
                padding: const EdgeInsets.all(10),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      img,
                      color: iconColor,
                      size: 30,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      title,
                      style: const TextStyle(color: Colors.black),
                    )
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                item(
                    'Live Stream',
                    Icons.live_tv_sharp,
                    () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const VideoStreamPage()))
                        },
                    Colors.red),
                item(
                    'Video Call',
                    Icons.video_call,
                    () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const VideoCallPage()))
                        },
                    Colors.blue),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                item(
                    'Audio Call',
                    Icons.call,
                    () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const AudioCallPage()))
                        },
                    Colors.green),
                item(
                    'Agora Chat',
                    Icons.chat,
                    () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  const AgoraChatPage(title: 'Agora Chat')))
                        },
                    Colors.green),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                item(
                    'Chat GPT',
                    Icons.chat,
                    () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const GptChatAPIDemo()))
                        },
                    Colors.green),
                // item(
                //     'Agora + Chat GPT',
                //     Icons.chat,
                //     () => {
                //           // Navigator.of(context).push(MaterialPageRoute(
                //           //     builder: (_) => const GptChatAPIDemo()))
                //         },
                //     Colors.green),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
