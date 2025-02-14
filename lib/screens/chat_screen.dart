import 'package:chatwell/screens/join_screen.dart';
import 'package:chatwell/sockets/socket_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late SocketService socketService;
  bool isLoading = true;
  String username = '';
  String room = '';
  bool isInitialized = false;
  TextEditingController messageController = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      username = args['username']!;
      room = args['room']!;
      socketService = SocketService();
      socketService.connect(username, room, () {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }, (error) {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to connect: $error')),
          );
        }
      });
      socketService.socket.on('message', (data) {
        if (mounted && data['username'] != username) {
          setState(() {
            messages.add({'username': data['username'], 'text': data['text']});
          });
        }
      });
      isInitialized = true;
    }
  }

  @override
  void dispose() {
    socketService.disconnect();
    super.dispose();
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      socketService.sendMessage(messageController.text);
      if (mounted) {
        setState(() {
          messages.add({'username': username, 'text': messageController.text});
        });
      }
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Room - $room')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      bool isMe = messages[index]['username'] == username;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                messages[index]['username']!,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isMe ? Colors.white : Colors.black),
                              ),
                              SizedBox(height: 3),
                              Text(
                                messages[index]['text']!,
                                style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Enter message...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2), // Blue border when focused
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      FloatingActionButton(
                        backgroundColor: Colors.blue,
                        onPressed: sendMessage,
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
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
