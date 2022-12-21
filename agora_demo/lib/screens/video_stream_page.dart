import 'package:agora_demo/utils/constants.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({super.key});

  @override
  State<VideoStreamPage> createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  int uid = 1; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  bool _isHost =
      true; // Indicates whether the user has joined as a host or audience
  late RtcEngine agoraEngine; // Agora engine instance

  @override
  initState() {
    super.initState();
    setupVideoSDKEngine();
  }

  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    super.dispose();
  }

  showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void join() async {
    // Set channel options
    ChannelMediaOptions options = ChannelMediaOptions();

    // Set channel profile and client role
    if (_isHost) {
      agoraEngine.setClientRole(ClientRole.Broadcaster);
      await agoraEngine.startPreview();
    } else {
      agoraEngine.setClientRole(ClientRole.Audience);
    }

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

    // Set client role and channel profile
    agoraEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
  }

  Widget _videoPanel() {
    if (!_isJoined) {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    } else if (_isHost) {
      // Local user joined as a host
      return rtc_remote_view.TextureView(uid: uid, channelId: channelName);
    } else {
      // Local user joined as audience
      if (_remoteUid != null) {
        return rtc_remote_view.SurfaceView(
            uid: _remoteUid!, channelId: channelName);
      } else {
        return const Text(
          'Waiting for a host to join',
          textAlign: TextAlign.center,
        );
      }
    }
  }

  // Set the client role when a radio button is selected
  void _handleRadioValueChange(bool? value) async {
    setState(() {
      _isHost = (value == true);
    });
    if (_isJoined) leave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Container for the local video
            Container(
              height: 240,
              decoration: BoxDecoration(border: Border.all()),
              child: Center(child: _videoPanel()),
            ),
            // Radio Buttons
            Row(children: <Widget>[
              Radio<bool>(
                value: true,
                groupValue: _isHost,
                onChanged: (value) => _handleRadioValueChange(value),
              ),
              const Text('Host'),
              Radio<bool>(
                value: false,
                groupValue: _isHost,
                onChanged: (value) => _handleRadioValueChange(value),
              ),
              const Text('Audience'),
            ]),
            // Button Row
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    child: const Text("Join"),
                    onPressed: () => {join()},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    child: const Text("Leave"),
                    onPressed: () => {leave()},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
