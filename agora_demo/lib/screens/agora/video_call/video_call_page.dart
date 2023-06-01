import 'package:agora_demo/utils/constants.dart';
import 'package:agora_demo/utils/logger.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  int uid = 1; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance
  final bool _isRenderSurfaceView = true;
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
    setupVideoSDKEngine();
  }

  @override
  void dispose() async {
    leave();
    agoraEngine.destroy();
    super.dispose();
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    if (!kIsWeb) await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine =
        await RtcEngine.createWithContext(RtcEngineContext(agoraAppId));

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

    // Set Client Role & Channel Profile
    await agoraEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await agoraEngine.setClientRole(ClientRole.Broadcaster);
  }

  // Display local video preview
  Widget _localPreview() {
    if (_isJoined) {
      return _isRenderSurfaceView
          ? const rtc_local_view.SurfaceView(
              channelId: channelName,
            )
          : const rtc_local_view.TextureView(
              channelId: channelName,
            );
    } else {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    }
  }

  void join() async {
    await agoraEngine.enableVideo();
    await agoraEngine.startPreview();

    // Set channel options
    ChannelMediaOptions options = ChannelMediaOptions();

    try {
      await agoraEngine.joinChannel(
          token, channelName, '', uid, options = options);
    } catch (e) {
      Logger.log(e);
    }
  }

  Future<void> leave() async {
    await agoraEngine.disableVideo();
    await agoraEngine.stopPreview();
    await agoraEngine.leaveChannel();
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
  }

// Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      // print('_remoteUid = $_remoteUid');
      return _isRenderSurfaceView
          ? rtc_remote_view.SurfaceView(
              uid: _remoteUid!,
              channelId: channelName,
            )
          : rtc_remote_view.TextureView(
              uid: _remoteUid!, channelId: channelName);
    } else {
      return Container();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Calling'),
      ),
      body: Stack(
        children: [
          kIsWeb
              ? ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    // Container for the local video
                    Container(
                      height: 240,
                      decoration: BoxDecoration(border: Border.all()),
                      child: Center(child: _localPreview()),
                    ),
                    const SizedBox(height: 10),
                    //Container for the Remote video
                    Container(
                      height: 240,
                      decoration: BoxDecoration(border: Border.all()),
                      child: Center(child: _remoteVideo()),
                    ),
                    // Button Row
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isJoined ? null : () => {join()},
                            child: const Text("Join"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isJoined ? () => {leave()} : null,
                            child: const Text("Leave"),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    //Container for the Remote video
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _remoteVideo(),
                          //Container for the local video
                          if (_isJoined)
                            Positioned(
                              top: 20,
                              right: 20,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 150,
                                  width: 100,
                                  child: _localPreview(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
          // Button Row
          Expanded(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Row(
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
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
                                    agoraEngine
                                        .setEnableSpeakerphone(!isSpeakerOn);
                                    setState(() {
                                      isSpeakerOn = !isSpeakerOn;
                                    });
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
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
                                      color: (_isJoined)
                                          ? Colors.red
                                          : Colors.green,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Image.asset(
                                    (!_isJoined)
                                        ? 'images/phone_call.png'
                                        : 'images/call-end.png',
                                    height: 20,
                                    width: 20,
                                    color: Colors.white,
                                  ))),
                        ],
                      )))),
        ],
      ),
    );
  }
}
