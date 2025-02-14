import 'package:chatwell/screens/chat_screen.dart';
import 'package:chatwell/screens/join_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatWell',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => JoinScreen(),
        '/chat': (context) => ChatScreen(),
      },
    );
  }
}
