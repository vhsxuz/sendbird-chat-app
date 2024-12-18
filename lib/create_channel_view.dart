import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:sendbird_chat_app/group_channel_view.dart';

class CreateChannelView extends StatefulWidget {
  @override
  _CreateChannelViewState createState() => _CreateChannelViewState();
}

class _CreateChannelViewState extends State<CreateChannelView> {
  final Set<User> _selectedUsers = {};
  final List<User> _availableUsers = [];
  bool _isLoading = false;

  Future<void> getUsers() async {
    try {
      final query = ApplicationUserListQuery()
        ..limit = 30; // Example limit, adjust based on your needs
      final users = await query.loadNext();
      setState(() {
        _availableUsers.clear();
        _availableUsers.addAll(users);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users: $e')),
      );
    }
  }

  Future<void> createChannel(List<String> userIds) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final params = GroupChannelParams()
        ..userIds = userIds
        ..name = "New Channel"; // Example name, can be customized
      final channel = await GroupChannel.createChannel(params);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChannelView(groupChannel: channel),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create channel: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: BackButton(color: Theme.of(context).colorScheme.secondary),
        title: Text('Select Members', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: _selectedUsers.isNotEmpty && !_isLoading
                ? () => createChannel(
                      [for (final user in _selectedUsers) user.userId],
                    )
                : null,
            child: Text(
              "Create",
              style: TextStyle(
                fontSize: 20.0,
                color: _selectedUsers.isNotEmpty
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _availableUsers.length,
              itemBuilder: (context, index) {
                final user = _availableUsers[index];
                return CheckboxListTile(
                  title: Text(
                    (user.nickname.isEmpty) ? user.userId : user.nickname,
                    style: TextStyle(color: Colors.black),
                  ),
                  controlAffinity: ListTileControlAffinity.platform,
                  value: _selectedUsers.contains(user),
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        _selectedUsers.add(user);
                      } else {
                        _selectedUsers.remove(user);
                      }
                    });
                  },
                  secondary: CircleAvatar(
                    backgroundImage: user.profileUrl?.isEmpty ?? true
                        ? null
                        : NetworkImage(user.profileUrl!),
                    child: (user.profileUrl?.isEmpty ?? true)
                        ? Text(
                            (user.nickname.isEmpty
                                    ? user.userId
                                    : user.nickname)
                                .substring(0, 1)
                                .toUpperCase(),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}