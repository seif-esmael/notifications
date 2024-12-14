import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:notifications/screens/chat_screen.dart';
import 'package:notifications/services/channel_services.dart';
import 'package:notifications/services/subscriptions_services.dart';
import 'package:notifications/services/user_services.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});
  static String channelsRoute = '/routes/channels';

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  final TextEditingController _channelController = TextEditingController();
  final Map<String, String> channelImages = {
    'Eldoksh': 'images/Eldoksh.jpg',
    'Saba7o': 'images/Saba7o.jpg',
    'MrBeast': 'images/MrBeast.jpg',
    'Spotify': 'images/spotify.png',
  };
  final List<Map<String, bool>> _channels = [];
  final List<String> _defaultChannels = [];

  @override
  void initState() {
    super.initState();
    _loadUserSubscriptions();
  }

  Future<void> _loadUserSubscriptions() async {
    try {
      String? uid = await UserServices.getUserId();
      if (uid == null) {
        throw Exception("User ID not found.");
      }
      DatabaseReference userSubscriptionsRef =
          FirebaseDatabase.instance.ref('subscriptions/users/$uid');

      final snapshot = await userSubscriptionsRef.get();
      Map<String, bool> userSubscriptions = {};
      if (snapshot.exists) {
        userSubscriptions = Map<String, bool>.from(snapshot.value as Map);
      }
      final firestoreChannels = await ChannelServices.getChannels().first;

      setState(() {
        _channels.clear();
        for (String defaultChannel in _defaultChannels) {
          _channels.add({
            defaultChannel: userSubscriptions[defaultChannel] ?? false,
          });
        }

        // Add Firestore channels
        for (String firestoreChannel in firestoreChannels) {
          _channels.add({
            firestoreChannel: userSubscriptions[firestoreChannel] ?? false,
          });
          if (!channelImages.containsKey(firestoreChannel)) {
            channelImages[firestoreChannel] = 'images/default.jpg';
          }
        }

        // Add remaining user-specific subscriptions
        userSubscriptions.forEach((channelName, isSubscribed) {
          if (!_defaultChannels.contains(channelName) &&
              !firestoreChannels.contains(channelName)) {
            _channels.add({channelName: isSubscribed});
            if (!channelImages.containsKey(channelName)) {
              channelImages[channelName] = 'images/default.jpg';
            }
          }
        });
      });
    } catch (e) {
      print("Error loading user subscriptions: $e");
    }
  }

  void _addChannel(String channelName) {
    setState(() {
      _channels.add({channelName: false});
      channelImages[channelName] = 'images/default.jpg';
    });
    ChannelServices.addChannelFireStore(channelName);
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String channelName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm delete for $channelName'),
          content: const Text('Do you want to delete this channel?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      await SubscriptionServices.unsubscribeFromChannelRealTimeDB(channelName);
      setState(() {
        _channels.removeWhere((channel) => channel.keys.first == channelName);
        ChannelServices.deleteChannelFireStore(channelName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('My Channels', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _channelController,
                decoration: InputDecoration(
                  hintText: 'Enter Channel Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final channelName = _channelController.text.trim();
                if (channelName.isNotEmpty) {
                  _addChannel(channelName);
                  _channelController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Channel name cannot be empty.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Channel'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _channels.length,
                itemBuilder: (context, index) {
                  final String channelName = _channels[index].keys.first;
                  final bool isSubscribed = _channels[index].values.first;
                  final String imagePath =
                      channelImages[channelName] ?? 'images/default.jpg';

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: ClipOval(
                        child: Image.asset(
                          imagePath,
                          width: 40.0,
                          height: 40.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        channelName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _channels[index][channelName] = !isSubscribed;
                          });

                          if (isSubscribed) {
                            SubscriptionServices.unsubscribeFromChannelRealTimeDB(channelName);
                          } else {
                            SubscriptionServices.subscribeToChannelRealTimeDB(channelName);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isSubscribed ? Colors.red : Colors.green,
                        ),
                        child: Text(
                          isSubscribed ? "Unsubscribe" : "Subscribe",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      onLongPress: () {
                        _showConfirmationDialog(context, channelName);
                      },
                      onTap: isSubscribed
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatScreen(channelId: channelName),
                                ),
                              );
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'You must subscribe to $channelName to access its chat.'),
                                ),
                              );
                            },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
