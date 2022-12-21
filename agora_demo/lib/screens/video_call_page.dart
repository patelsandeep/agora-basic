// import 'package:agora_demo/utils/constants.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:math';
//
// class VideoCallPage extends StatefulWidget {
//   const VideoCallPage({super.key});
//
//   @override
//   State<VideoCallPage> createState() => _VideoCallPageState();
// }
//
// class _VideoCallPageState extends State<VideoCallPage> {
//   int uid = 0; // uid of the local user
//
//   int? _remoteUid; // uid of the remote user
//   bool _isJoined = false; // Indicates if the local user has joined the channel
//   late RtcEngine agoraEngine; // Agora engine instance
//
//   showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(message),
//     ));
//   }
//
//   @override
//   initState() {
//     super.initState();
//     // Set up an instance of Agora engine
//     setupVideoSDKEngine();
//   }
//
//   @override
//   void dispose() async {
//     await agoraEngine.leaveChannel();
//     super.dispose();
//   }
//
//   Future<void> setupVideoSDKEngine() async {
//     // retrieve or request camera and microphone permissions
//     await [Permission.microphone, Permission.camera].request();
//
//     //create an instance of the Agora engine
//     agoraEngine = createAgoraRtcEngine();
//     await agoraEngine.initialize(const RtcEngineContext(appId: appId));
//
//     await agoraEngine.enableVideo();
//
//     // Register the event handler
//     agoraEngine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           showMessage(
//               "Local user uid:${connection.localUid} joined the channel");
//           setState(() {
//             _isJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           showMessage("Remote user uid:$remoteUid joined the channel");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           showMessage("Remote user uid:$remoteUid left the channel");
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//       ),
//     );
//   }
//
//   // Display local video preview
//   Widget _localPreview() {
//     if (_isJoined) {
//       return AgoraVideoView(
//         controller: VideoViewController(
//           rtcEngine: agoraEngine,
//           canvas: VideoCanvas(uid: uid),
//         ),
//       );
//     } else {
//       return const Text(
//         'Join a channel',
//         textAlign: TextAlign.center,
//       );
//     }
//   }
//
//   void join() async {
//     await agoraEngine.startPreview();
//
//     // Set channel options including the client role and channel profile
//     ChannelMediaOptions options = const ChannelMediaOptions(
//       clientRoleType: ClientRoleType.clientRoleBroadcaster,
//       channelProfile: ChannelProfileType.channelProfileCommunication,
//     );
//
//     try {
//       await agoraEngine.joinChannel(
//         token: token,
//         channelId: channelName,
//         options: options,
//         uid: 0,
//       );
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   void leave() {
//     setState(() {
//       _isJoined = false;
//       _remoteUid = null;
//     });
//     agoraEngine.leaveChannel();
//   }
//
// // Display remote user's video
//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: agoraEngine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: const RtcConnection(channelId: channelName),
//         ),
//       );
//     } else {
//       String msg = '';
//       if (_isJoined) msg = 'Waiting for a remote user to join';
//       return Text(
//         msg,
//         textAlign: TextAlign.center,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Video Calling'),
//         ),
//         body: ListView(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           children: [
//             // Container for the local video
//             Container(
//               height: 240,
//               decoration: BoxDecoration(border: Border.all()),
//               child: Center(child: _localPreview()),
//             ),
//             const SizedBox(height: 10),
//             //Container for the Remote video
//             Container(
//               height: 240,
//               decoration: BoxDecoration(border: Border.all()),
//               child: Center(child: _remoteVideo()),
//             ),
//             // Button Row
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _isJoined ? null : () => {join()},
//                     child: const Text("Join"),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _isJoined ? () => {leave()} : null,
//                     child: const Text("Leave"),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ));
//   }
// }
