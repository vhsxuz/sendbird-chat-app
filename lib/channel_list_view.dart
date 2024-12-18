import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart' as sendbird_sdk;
import 'group_channel_view.dart';

class ChannelListView extends StatefulWidget {
  const ChannelListView({super.key});

  @override
  _ChannelListViewState createState() => _ChannelListViewState();
}

class _ChannelListViewState extends State<ChannelListView>
    with sendbird_sdk.ChannelEventHandler {
  Future<List<sendbird_sdk.GroupChannel>> getGroupChannels() async {
    try {
      final query = sendbird_sdk.GroupChannelListQuery()
        ..includeEmptyChannel = true
        ..order = sendbird_sdk.GroupChannelListOrder.latestLastMessage
        ..limit = 15;
      return await query.loadNext();
    } catch (e) {
      print('channel_list_view: getGroupChannels: ERROR: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    sendbird_sdk.SendbirdSdk().addChannelEventHandler('channel_list_view', this);
  }

  @override
  void dispose() {
    sendbird_sdk.SendbirdSdk().removeChannelEventHandler("channel_list_view");
    super.dispose();
  }

  @override
  void onChannelChanged(sendbird_sdk.BaseChannel channel) {
    setState(() {
      // Force the list future builder to rebuild.
    });
  }

  @override
  void onChannelDeleted(String channelUrl, sendbird_sdk.ChannelType channelType) {
    setState(() {
      // Force the list future builder to rebuild.
    });
  }

  @override
  void onUserJoined(sendbird_sdk.GroupChannel channel, sendbird_sdk.User user) {
    setState(() {
      // Force the list future builder to rebuild.
    });
  }

  @override
  void onUserLeaved(sendbird_sdk.GroupChannel channel, sendbird_sdk.User user) {
    setState(() {
      // Force the list future builder to rebuild.
    });
    super.onUserLeaved(channel, user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navigationBar(),
      body: body(context),
    );
  }

  PreferredSizeWidget navigationBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: BackButton(color: Theme.of(context).primaryColor),
      title: const Text(
        'Channels',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        Container(
          width: 60,
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.black),  // Plus icon
            onPressed: () {
              Navigator.pushNamed(context, '/create_channel');
            },
          ),
        ),
      ],
    );
  }

  Widget body(BuildContext context) {
    return FutureBuilder<List<sendbird_sdk.GroupChannel>>(
      future: getGroupChannels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == sendbird_sdk.ConnectionState.connecting) {
          // Loading indicator while fetching data
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading channels.'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No channels available.'));
        }

        List<sendbird_sdk.GroupChannel> channels = snapshot.data!;
        return ListView.builder(
          itemCount: channels.length,
          itemBuilder: (context, index) {
            sendbird_sdk.GroupChannel channel = channels[index];
            return ListTile(
              // Display all channel members as the title
              title: Text(
                [for (final member in channel.members) member.nickname]
                    .join(", "),
              ),
              // Display the last message presented
              subtitle: Text(channel.lastMessage?.message ?? 'No message'),
              onTap: () {
                gotoChannel(channel.channelUrl);
              },
            );
          },
        );
      },
    );
  }

  void gotoChannel(String channelUrl) {
    sendbird_sdk.GroupChannel.getChannel(channelUrl).then((channel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChannelView(groupChannel: channel),
        ),
      );
    }).catchError((e) {
      // Handle error while fetching the channel
      print('channel_list_view: gotoChannel: ERROR: $e');
    });
  }
}