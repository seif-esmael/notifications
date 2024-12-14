import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notifications/services/chat_services.dart';
import 'package:notifications/services/user_services.dart';

class ChatScreen extends StatefulWidget {
  final String channelId;
  static String channelsRoute = '/routes/chatroom';

  ChatScreen({Key? key, required this.channelId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final Map<String, String> channelImages = {
    'Eldoksh': 'images/Eldoksh.jpg',
    'Saba7o': 'images/Saba7o.jpg',
    'MrBeast': 'images/MrBeast.jpg',
    'Spotify': 'images/spotify.png',
  };

  String? _userName;

  @override
  void initState() {
    super.initState();
    ChatServices.listenForMessagesRealtime(widget.channelId);
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String? userName = await UserServices.getUserName();
    setState(() {
      _userName = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = channelImages[widget.channelId] ?? 'images/default.jpg';
    return Scaffold(
      appBar: AppBar(
        leading: ClipOval(
          child: Image.asset(
            imagePath,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
          ),
        ),
        backgroundColor: Colors.grey[300],
        title: Text('${widget.channelId} Chatroom',
            style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('channels/${widget.channelId}/messages')
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No messages yet.'));
                }

                final data =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final messages = data.entries.toList()
                  ..sort((b, a) =>
                      a.value['timestamp'].compareTo(b.value['timestamp']));

                return FutureBuilder<String?>(
                  future: UserServices.getUserId(),
                  builder: (context, userIdSnapshot) {
                    if (!userIdSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final currentUserId = userIdSnapshot.data!;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final messageData = messages[index].value as Map;
                        final message = messageData['message'] ?? '';
                        final timestamp = messageData['timestamp'] ?? '';
                        final senderId = messageData['userId'] ?? '';
                        final senderName =
                            messageData['userName'] ?? 'Unknown User';
                        final time = DateTime.parse(timestamp);
                        final formattedTime =
                            DateFormat('hh:mm a').format(time);

                        final isCurrentUser = senderId == currentUserId;
                        final alignment = isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft;
                        final color = isCurrentUser
                            ? Colors.blue[400]
                            : Colors.grey[500];
                        final textColor = isCurrentUser
                            ? Colors.white
                            : Colors.white;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          child: Align(
                            alignment: alignment,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: isCurrentUser
                                      ? const Radius.circular(12)
                                      : Radius.zero,
                                  bottomRight: isCurrentUser
                                      ? Radius.zero
                                      : const Radius.circular(12),
                                ),
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              child: Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!isCurrentUser)
                                    Text(
                                      senderName,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  Text(
                                    message,
                                    style: TextStyle(color: textColor),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Message cannot be empty")),
                        );
                      } else {
                        ChatServices.sendMessageRealtime(
                            widget.channelId, _controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
