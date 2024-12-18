import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class LoginView extends StatefulWidget {
  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final _userIdController = TextEditingController();
  bool _enableSignInButton = false;
  final String appId = "5924FDA5-841D-4DED-97C2-36C096937A47"; // Add your Sendbird app ID here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: body(context),
    );
  }

  Widget navigationBar() {
    return AppBar(
      toolbarHeight: 65,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: true,
      title: Text('Sendbird Sample', style: TextStyle(color: Colors.black)),
      actions: [],
      centerTitle: true,
    );
  }

  Widget body(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text('Sendbird Sample', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 40),
          TextField(
            controller: _userIdController,
            onChanged: (value) {
              setState(() {
                _enableSignInButton = _shouldEnableSignInButton();
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'User Id',
              filled: true,
              fillColor: Colors.grey[200],
              suffixIcon: IconButton(
                onPressed: () {
                  _userIdController.clear();
                },
                icon: Icon(Icons.clear),
              ),
            ),
          ),
          const SizedBox(height: 30),
          FractionallySizedBox(
            widthFactor: 1,
            child: _signInButton(context, _enableSignInButton),
          ),
        ],
      ),
    );
  }

  bool _shouldEnableSignInButton() {
    return _userIdController.text.isNotEmpty;
  }

  Widget _signInButton(BuildContext context, bool enabled) {
    if (!enabled) {
      return TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.grey),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.grey),
        ),
        onPressed: () {},
        child: const Text(
          "Sign In",
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Color(0xff742DDD)),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
      onPressed: () {
        // Login with Sendbird
        connect(appId, _userIdController.text).then((user) {
          Navigator.pushNamed(context, '/channel_list');
        }).catchError((error) {
          print('login_view: _signInButton: ERROR: $error');
        });
      },
      child: const Text(
        "Sign In",
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }

  Future<User> connect(String appId, String userId) async {
    // Init Sendbird SDK and connect with current user id
    try {
      final sendbird = SendbirdSdk(appId: appId);
      final user = await sendbird.connect(userId);
      return user;
    } catch (e) {
      print('login_view: connect: ERROR: $e');
      rethrow;
    }
  }
}
