import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'dart:async';

class GroupChannelView extends StatefulWidget {
  final GroupChannel groupChannel;
  const GroupChannelView({Key? key, required this.groupChannel}) : super(key: key);

  @override
  _GroupChannelViewState createState() => _GroupChannelViewState();
}

class _GroupChannelViewState extends State<GroupChannelView>
    with ChannelEventHandler {
  List<BaseMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    getMessages(widget.groupChannel);
    SendbirdSdk().addChannelEventHandler(widget.groupChannel.channelUrl, this);
  }

  @override
  void dispose() {
    SendbirdSdk().removeChannelEventHandler(widget.groupChannel.channelUrl);
    super.dispose();
  }

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    if (channel.channelUrl == widget.groupChannel.channelUrl) {
      setState(() {
        _messages.insert(0, message);
      });
    }
  }

  Future<void> getMessages(GroupChannel channel) async {
    try {
      List<BaseMessage> messages = await channel.getMessagesByTimestamp(
        DateTime.now().millisecondsSinceEpoch * 1000,
        MessageListParams(),
      );
      setState(() {
        _messages = messages.reversed.toList(); // Reverse for chronological order
      });
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> _sendMessage(ChatMessage message) async {
    try {
      final params = UserMessageParams(message: message.text)
        ..targetLanguages = ['en']; // Request translation to Spanish and Korean

      // Await the sent message, so that we can handle the result
      var sentMessage = widget.groupChannel.sendUserMessage(params);

      // Log the full sent message response
      print('Sent Message: ${sentMessage.toJson()}');

      // Handle translation (Sendbird SDK automatically handles the translation if enabled)
      final esTranslatedMessage = sentMessage.translations['es']; // Spanish translation
      final koTranslatedMessage = sentMessage.translations['ko']; // Korean translation

      // Append translations if available
      if (esTranslatedMessage != null) {
      }
      if (koTranslatedMessage != null) {
      }

      setState(() {
        _messages.insert(0, sentMessage);
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navigationBar(widget.groupChannel),
      body: body(context),
    );
  }

  PreferredSizeWidget navigationBar(GroupChannel channel) {
    return AppBar(
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF212123),
      centerTitle: false,
      leading: const BackButton(color: Colors.white),
      title: SizedBox(
        width: 250,
        child: Text(
          [for (final member in channel.members) member.userId][0],
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    ChatUser user = asDashChatUser(SendbirdSdk().currentUser!);
    return Container(
      color: const Color(0xFF161617), // Set the background color to #161617
      child: DashChat(
        currentUser: user,
        key: Key(widget.groupChannel.channelUrl),
        onSend: _sendMessage, // Use the separated method here
        messages: asDashChatMessages(_messages),
        messageOptions: const MessageOptions(
          currentUserContainerColor: Color(0xFF0A3331),
          currentUserTextColor: Colors.white,
          containerColor: Color(0xff2D2D2F),
          textColor: Colors.white,
        ),
        inputOptions: InputOptions(
          alwaysShowSend: true,
          inputTextStyle: const TextStyle(color: Colors.white),
          sendOnEnter: true,
          autocorrect: false,
          cursorStyle: const CursorStyle(color: Color(0xff50ded5)),
          inputDecoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff212123),
            hintText: 'Type Here',
            hintStyle: const TextStyle(color: Colors.white24),
            border: InputBorder.none,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF50DED5), width: 1),
            ),
            prefixIcon: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: () {
                // Add camera functionality here
              },
            ),
          ),
          sendButtonBuilder: (sendPressed) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF50DED5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: sendPressed,
                    icon: const Icon(Icons.send, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            );
          },
        ),
      ),
    );
  }

  List<ChatMessage> asDashChatMessages(List<BaseMessage> messages) {
    return messages.map((message) {
      if (message is UserMessage) {
        String translatedMessage = message.message;

        // Check for translations and append
        final translatedMessageJSON = message.translations;
        final enTranslatedMessage = message.translations['en'];
        print('Original Message: ${message.message}');
        print('Original Message: ${translatedMessageJSON}');
        print('Original Message: ${enTranslatedMessage}');
        print("\n");


        translatedMessage += "\n\nEnglish: $enTranslatedMessage";
      
        return ChatMessage(
          createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
          text: translatedMessage, // Show translated message
          user: asDashChatUser(message.sender!),
        );
      }
      return ChatMessage(
        createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
        text: '[Unsupported message type]',
        user: ChatUser(id: 'unknown'),
      );
    }).toList();
  }

  ChatUser asDashChatUser(User user) {
    return ChatUser(
      id: user.userId,
      profileImage: user.profileUrl ?? '',
    );
  }
}