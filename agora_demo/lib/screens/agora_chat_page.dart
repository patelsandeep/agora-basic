import 'package:agora_demo/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

class AgoraChatConfig {
  static const String appKey = "61419896#1046071";
  // static const String userId = "1";
  static const String userId = "2";
  static const String agoraToken =
      "007eJxTYFjdu6dY5F7u9qWzLgd9lDh7x2/uq0PSmVeOPw6btudebMpZBQazVAvj5OQUE3PzJBMTw+RkyyRLIyNTM1Mzs6REy0SjJP2GpckNgYwMfDwuTIwMrAyMQAjiqzCYJKWkmiWmGuiap5mZ6xoapqboWiQZJOmaGxpbWCSZGJomppoCAMqjKdI=";
  // static const String agoraToken =
  //     "007eJxTYGhdWHqo671r9Pvzifrq1kdNn+ifNYpss7Epu6z4oolVbJsCg1mqhXFycoqJuXmSiYlhcrJlkqWRkamZqZlZUqJlolFSY/3S5IZARoa1yxazMjKwMjACIYivwmBikGhhZmJqoGueZmaua2iYmqJrkWSapmuQZGiRmGyWaGycbAYAbQwnSQ==";
}

class AgoraChatPage extends StatefulWidget {
  const AgoraChatPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<AgoraChatPage> createState() => _AgoraChatPageState();
}

class _AgoraChatPageState extends State<AgoraChatPage> {
  ScrollController scrollController = ScrollController();
  String? _messageContent, _chatId = "1";
  final List<String> _logText = [];

  @override
  void initState() {
    super.initState();
    _initSDK();
    _addChatListener();
  }

  @override
  void dispose() {
    ChatClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemBuilder: (_, index) {
                  return Text(_logText[index]);
                },
                itemCount: _logText.length,
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Enter message",
                  ),
                  onChanged: (msg) => _messageContent = msg,
                )),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _initSDK() async {
    ChatOptions options = ChatOptions(
      appKey: AgoraChatConfig.appKey,
      autoLogin: true,
    );
    await ChatClient.getInstance.init(options);
    _signIn();
  }

  void _addChatListener() {
    ChatClient.getInstance.chatManager.addEventHandler(
      "UNIQUE_HANDLER_ID",
      ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );
  }

  void _signIn() async {
    try {
      await ChatClient.getInstance.loginWithAgoraToken(
        AgoraChatConfig.userId,
        AgoraChatConfig.agoraToken,
      );
      _addLogToConsole("login succeed, userId: ${AgoraChatConfig.userId}");
    } on ChatError catch (e) {
      _addLogToConsole("login failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
      _addLogToConsole("sign out succeed");
    } on ChatError catch (e) {
      _addLogToConsole(
          "sign out failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _sendMessage() async {
    if (_chatId == null || _messageContent == null) {
      _addLogToConsole("single chat id or message content is null");
      return;
    }
    print(_messageContent);
    print(_chatId);
    var msg = ChatMessage.createTxtSendMessage(
      targetId: _chatId!,
      content: _messageContent!,
    );
    msg.setMessageStatusCallBack(MessageStatusCallBack(
      onSuccess: () {
        _addLogToConsole("send message: $_messageContent");
      },
      onError: (e) {
        _addLogToConsole(
          "send message failed, code: ${e.code}, desc: ${e.description}",
        );
      },
    ));
    ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    print("onMessagesReceived");
    for (var msg in messages) {
      switch (msg.body.type) {
        case MessageType.TXT:
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            _addLogToConsole(
              "receive text message: ${body.content}, from: ${msg.from}",
            );
          }
          break;
        case MessageType.IMAGE:
          {
            _addLogToConsole(
              "receive image message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.VIDEO:
          {
            _addLogToConsole(
              "receive video message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.LOCATION:
          {
            _addLogToConsole(
              "receive location message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.VOICE:
          {
            _addLogToConsole(
              "receive voice message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.FILE:
          {
            _addLogToConsole(
              "receive image message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.CUSTOM:
          {
            _addLogToConsole(
              "receive custom message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.CMD:
          {}
          break;
      }
    }
  }

  void _addLogToConsole(String log) {
    _logText.add(_timeString + ": " + log);
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }
}
