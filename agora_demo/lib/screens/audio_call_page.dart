import 'package:agora_demo/utils/constants.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioCallPage extends StatefulWidget {
  const AudioCallPage({super.key});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  int uid = 0; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance
  bool isMute = false, isSpeakerOn = false;

  showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  initState() {
    super.initState();
    // Set up an instance of Agora engine
    setupVoiceSDKEngine();
  }

  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    super.dispose();
  }

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    if (!kIsWeb) await [Permission.microphone].request();

    //create an instance of the Agora engine
    agoraEngine = await RtcEngine.createWithContext(RtcEngineContext(appId));

    // Register the event handler
    agoraEngine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (channel, uid, elapsed) {
          showMessage("Local user uid:$uid joined the channel");
          setState(() => _isJoined = true);
        },
        userJoined: (int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() => _remoteUid = remoteUid);
        },
        userOffline: (uid, reason) {
          showMessage("Remote user uid:$uid left the channel");
          setState(() => _remoteUid = null);
        },
      ),
    );

    // Set client role and channel profile
    // agoraEngine.setClientRole(ClientRole.Broadcaster);
    // agoraEngine.setChannelProfile(ChannelProfile.Communication);
  }

  void join() async {
    // Set channel options
    ChannelMediaOptions options = ChannelMediaOptions(
      publishLocalVideo: false,
      autoSubscribeVideo: false,
    );

    await agoraEngine.joinChannel(
        token, channelName, '', uid, options = options);
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  muteUnmute() {
    if (isMute) {
      agoraEngine.enableAudio();
    } else {
      agoraEngine.disableAudio();
    }

    setState(() {
      isMute = !isMute;
    });
  }

  Widget _status() {
    String statusText;

    if (!_isJoined) {
      statusText = '';
    } else if (_remoteUid == null) {
      statusText = 'Waiting for a remote user to join...';
    } else {
      statusText = 'Connected to remote user, uid:$_remoteUid';
    }

    return Text(
      statusText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Voice Calling'),
        ),
        body: Column(
          children: [
            // Status text
            Expanded(
                child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Image.asset(
                  'images/user.png',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(
                  height: 10,
                ),
                // const Text("Calling...")
                SizedBox(height: 40, child: Center(child: _status())),
              ],
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (!_isJoined)
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          //MUTE UNMUTE
                          muteUnmute();
                        },
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Image.asset(
                              (!isMute)
                                  ? 'images/unmute.png'
                                  : 'images/mute.png',
                              height: 20,
                              width: 20,
                              color: Colors.white,
                            ))),
                (!_isJoined)
                    ? Container()
                    : const SizedBox(
                        width: 20,
                      ),
                (!_isJoined)
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          //SPEAKER
                          agoraEngine.setEnableSpeakerphone(!isSpeakerOn);
                          setState(() {
                            isSpeakerOn = !isSpeakerOn;
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Image.asset(
                              (isSpeakerOn)
                                  ? 'images/loud-speaker.png'
                                  : 'images/speaker_off.png',
                              height: 20,
                              width: 20,
                              color: Colors.white,
                            ))),
                const SizedBox(
                  width: 20,
                ),
                GestureDetector(
                    //CONNECT DISCONNECT CALL
                    onTap: () {
                      (_isJoined) ? leave() : join();
                    },
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: (_isJoined) ? Colors.red : Colors.green,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: Image.asset(
                          (!_isJoined)
                              ? 'images/phone_call.png'
                              : 'images/call-end.png',
                          height: 20,
                          width: 20,
                          color: Colors.white,
                        ))),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ));
  }
}
