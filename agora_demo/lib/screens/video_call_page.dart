import 'package:agora_demo/utils/constants.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
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
    super.dispose();
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    if (!kIsWeb) await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = await RtcEngine.createWithContext(RtcEngineContext(appId));

    await agoraEngine.enableVideo();

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

    await agoraEngine.enableVideo();
    await agoraEngine.startPreview();

    // Set client role and channel profile
    await agoraEngine.setChannelProfile(ChannelProfile.Communication);
    await agoraEngine.setClientRole(ClientRole.Broadcaster);
  }

  // Display local video preview
  Widget _localPreview() {
    if (_isJoined) {
      return rtc_remote_view.TextureView(
        uid: uid,
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
    await agoraEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = ChannelMediaOptions();

    try {
      await agoraEngine.joinChannel(
          token, channelName, '', uid, options = options);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

// Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return rtc_remote_view.SurfaceView(
        uid: _remoteUid!,
        channelId: channelName,
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Video Calling'),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        ));
  }
}
