import 'package:agora_demo/utils/constants.dart';
import 'package:agora_demo/utils/logger.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  int uid = 0; // uid of the local user

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
    await agoraEngine.release();
    super.dispose();
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
        appId: agoraAppId
    ));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage("Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }


  // Display local video preview
  Widget _localPreview() {
    if (_isJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: 0),
        ),
      );
    } else {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    }
  }

  void  join() async {
    await agoraEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
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
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      String msg = '';
      if (_isJoined) msg = 'Waiting for a remote user to join';
      return Text(
        msg,
        textAlign: TextAlign.center,
      );
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
              : Stack(
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
          Align(
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
                  ))),
        ],
      ),
    );
  }
}
