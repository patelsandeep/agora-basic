import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_demo/screens/widget/chat_message_widget.dart';
import 'package:agora_demo/utils/agora_chat_config.dart';
import 'package:agora_demo/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt_api/flutter_chatgpt_api.dart' as chatgpt;

class AgoraChatPage extends StatefulWidget {
  const AgoraChatPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<AgoraChatPage> createState() => _AgoraChatPageState();
}

class _AgoraChatPageState extends State<AgoraChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  String? _messageContent;
  final String _chatId = "2";
  final List<chatgpt.ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initSDK();
    _addChatListener();
  }

  @override
  void dispose() {
    ChatClient.getInstance.chatManager
        .removeEventHandler(AgoraChatConfig.listenerId);
    super.dispose();
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  var message = _messages[index];
                  return ChatMessageWidget(
                    text: message.text,
                    chatMessageType: message.chatMessageType,
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _textController,
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
      AgoraChatConfig.listenerId,
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

  // void _signOut() async {
  //   try {
  //     await ChatClient.getInstance.logout(true);
  //     _addLogToConsole("sign out succeed");
  //   } on ChatError catch (e) {
  //     _addLogToConsole(
  //         "sign out failed, code: ${e.code}, desc: ${e.description}");
  //   }
  // }

  void _sendMessage() async {
    if (_chatId.isEmpty || _messageContent == null) {
      _addLogToConsole("single chat id or message content is null");
      return;
    }

    var msg = ChatMessage.createTxtSendMessage(
      targetId: _chatId,
      content: _messageContent!,
    );
    msg.setMessageStatusCallBack(MessageStatusCallBack(
      onSuccess: () {
        _addLogToConsole("send message: $_messageContent");
        _textController.clear();
        setState(
          () {
            _messages.add(
              chatgpt.ChatMessage(
                text: _messageContent ?? "",
                chatMessageType: chatgpt.ChatMessageType.user,
              ),
            );
          },
        );
        Future.delayed(const Duration(milliseconds: 50))
            .then((_) => _scrollDown());
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
    for (var msg in messages) {
      switch (msg.body.type) {
        case MessageType.TXT:
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            setState(
              () {
                _messages.add(
                  chatgpt.ChatMessage(
                    text: body.content,
                    chatMessageType: chatgpt.ChatMessageType.bot,
                  ),
                );
              },
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
    Logger.log((DateTime.now().toString().split(".").first) + (": ") + log);
  }
}
