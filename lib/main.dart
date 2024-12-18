import 'package:flutter/material.dart';
import 'package:sendbird_chat_app/channel_list_view.dart';
import 'package:sendbird_chat_app/create_channel_view.dart';
import 'login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sendbird Demo',
      initialRoute: "/login",
      routes: {
        '/login': (context) => LoginView(),
        '/channel_list': (context) => const ChannelListView(),
        '/create_channel': (context) => CreateChannelView(),
      },
      theme: ThemeData(
        fontFamily: 'Gellix',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xff742DDD),
          secondary: const Color(0xff742DDD),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xff742DDD),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xff732cdd),
          selectionHandleColor: Color(0xff732cdd),
          selectionColor: Color(0xffD1BAF4),
        ),
      ),
    );
  }
}
