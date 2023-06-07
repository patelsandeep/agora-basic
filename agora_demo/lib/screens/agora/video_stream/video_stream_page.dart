import 'package:agora_demo/utils/constants.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({super.key});

  @override
  State<VideoStreamPage> createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  var uuid = const Uuid();

  int generateUid() {
    final String temp = const Uuid().v1();
    final String uidString =
        temp.replaceAll(RegExp(r'[^0-9]'), ''); // Remove non-digit characters
    return int.tryParse(uidString) ??
        0; // Use tryParse to handle invalid UID strings
  } // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  bool _isHost =
      true; // Indicates whether the user has joined as a host or audience
  late RtcEngine agoraEngine; // Agora engine instance
  final bool _isRenderSurfaceView = true;
  late final MediaPlayerController _mediaPlayerController;
  String mediaLocation =
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

  bool _isUrlOpened = false; // Media file has been opened
  bool _isPlaying = false; // Media file is playing
  bool _isPaused = false; // Media player is paused

  int _duration = 0; // Total duration of the loaded media file
  int _seekPos = 0; // Current play position
  int volume = 50;
  bool _isMuted = false;
  bool _isScreenShared = false;

  @override
  initState() {
    super.initState();
    setupVideoSDKEngine();
  }

  @override
  void setState(VoidCallback fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() async {
    leave();
    // Dispose the media player
    await agoraEngine.release();
    _mediaPlayerController.dispose();

    setState(() {
      _isPlaying = false;
    });

    _isUrlOpened = false;
    _isPaused = false;

    super.dispose();
  }



  showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  onMuteChecked(bool value) {
    setState(() {
      _isMuted = value;
      agoraEngine.muteAllRemoteAudioStreams(_isMuted);
    });
  }

  onVolumeChanged(double newValue) {
    setState(() {
      volume = newValue.toInt();
      agoraEngine.adjustRecordingSignalVolume(volume);
    });
  }


  void join() async {
    // Set channel options
    ChannelMediaOptions options;

    // Set channel profile and client role
    if (_isHost) {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
      await agoraEngine.startPreview();
    } else {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
    }

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: generateUid(),
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

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: agoraAppId));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
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

  void playMedia() async {
    if (!_isUrlOpened) {
      await initializeMediaPlayer();
      // Open the media file
      _mediaPlayerController.open(url: mediaLocation, startPos: 0);
    } else if (_isPaused) {
      // Resume playing
      _mediaPlayerController.resume();
      setState(() {
        _isPaused = false;
      });
    } else if (_isPlaying) {
      // Pause media player
      _mediaPlayerController.pause();
      setState(() {
        _isPaused = true;
      });
    } else {
      // Play the loaded media file
      _mediaPlayerController.play();
      setState(() {
        _isPlaying = true;
        updateChannelPublishOptions(_isPlaying);
      });
    }
  }

  Future<void> initializeMediaPlayer() async {
    _mediaPlayerController= MediaPlayerController(
        rtcEngine: agoraEngine,
        useAndroidSurfaceView: true,
        canvas: VideoCanvas(uid: generateUid(),
            sourceType: VideoSourceType.videoSourceMediaPlayer
        )
    );

    await _mediaPlayerController.initialize();

    _mediaPlayerController.registerPlayerSourceObserver(
      MediaPlayerSourceObserver(
        onCompleted: () {},
        onPlayerSourceStateChanged:
            (MediaPlayerState state, MediaPlayerError ec) async {
          showMessage(state.name);

          if (state == MediaPlayerState.playerStateOpenCompleted) {
            // Media file opened successfully
            _duration = await _mediaPlayerController.getDuration();
            setState(() {
              _isUrlOpened = true;
            });
          } else if (state ==
              MediaPlayerState.playerStatePlaybackAllLoopsCompleted) {
            // Media file finished playing
            setState(() {
              _isPlaying = false;
              _seekPos = 0;
              // Restore camera and microphone streams
              updateChannelPublishOptions(_isPlaying);
            });
          }
        },
        onPositionChanged: (int position) {
          setState(() {
            _seekPos = position;
          });
        },
        onPlayerEvent:
            (MediaPlayerEvent eventCode, int elapsedTime, String message) {
          // Other events
        },
      ),
    );
  }

  // Widget _localPreview() {
  //   // Display local video or screen sharing preview
  //   if (_isJoined) {
  //     if (!_isScreenShared) {
  //       if(_isPlaying && _isHost){
  //         return AgoraVideoView(controller: _mediaPlayerController,);
  //       }else {
  //         return AgoraVideoView(
  //           controller: VideoViewController(
  //             rtcEngine: agoraEngine,
  //             canvas: const VideoCanvas(uid: 0),
  //           ),
  //         );
  //       }
  //     } else {
  //       return AgoraVideoView(
  //           controller: VideoViewController(
  //             rtcEngine: agoraEngine,
  //             canvas: const VideoCanvas(
  //               uid: 0,
  //               sourceType: VideoSourceType.videoSourceScreen,
  //             ),
  //           ));
  //     }
  //   } else {
  //     return const Text(
  //       'Join a channel',
  //       textAlign: TextAlign.center,
  //     );
  //   }
  // }

  Widget _localPreview() {
    if (_isJoined) {
      if (_isPlaying) {
        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: agoraEngine,
            canvas: const VideoCanvas(uid: 0),
          ),
        );
      } else {
        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: agoraEngine,
            canvas: VideoCanvas(uid: 0),
          ),
        );
      }
    } else {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    }
  }


  Widget _videoPanel() {
    if (!_isJoined) {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    } else if (_isHost) {
      // Show local video preview
      return AgoraVideoView(
        controller: (_isPlaying) ? _mediaPlayerController :
        VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: 0),
        ),
      );
    } else {
      // Show remote video
      if (_remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: agoraEngine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: channelName),
          ),
        );
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

  Widget _mediaPLayerButton() {
    String caption = "";

    if (!_isUrlOpened) {
      caption = "Open media file";
    } else if (_isPaused) {
      caption = "Resume playing media";
    } else if (_isPlaying) {
      caption = "Pause playing media";
    } else {
      caption = "Play media file";
    }

    return ElevatedButton(
      onPressed: _isJoined ? () => {playMedia()} : null,
      child: Text(caption),
    );
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
            Expanded(child: _videoPanel()),
            Expanded(child: _localPreview()),
            // Radio Buttons
            _mediaPLayerButton(),
            Slider(
                value: _seekPos.toDouble(),
                min: 0,
                max: _duration.toDouble(),
                divisions: 100,
                label: '${(_seekPos / 1000.round())} s',
                onChanged: (double value) {
                  _seekPos = value.toInt();
                  _mediaPlayerController.seek(_seekPos);
                  setState(() {});
                }),

            Row(
              children: <Widget>[
                Checkbox(
                    value: _isMuted,
                    onChanged: (_isMuted) => {onMuteChecked(_isMuted!)}),
                const Text("Mute"),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 100,
                    value: volume.toDouble(),
                    onChanged: (value) => {onVolumeChanged(value)},
                  ),
                ),
              ],
            ),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
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
              const SizedBox(
                width: 20,
              ),
            ]),

            GestureDetector(
                onTap: () {
                  (_isJoined) ? leave() : join();
                },
                child: Container(
                    margin: const EdgeInsets.only(bottom: 50),
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
      ),
    );
  }

  void updateChannelPublishOptions(bool publishMediaPlayer) {
    ChannelMediaOptions channelOptions = ChannelMediaOptions(
        publishMediaPlayerAudioTrack: publishMediaPlayer,
        publishMediaPlayerVideoTrack: publishMediaPlayer,
        publishMicrophoneTrack: !publishMediaPlayer,
        publishCameraTrack: !publishMediaPlayer,
        publishMediaPlayerId: _mediaPlayerController.getMediaPlayerId());

    agoraEngine.updateChannelMediaOptions(channelOptions);
  }
}
