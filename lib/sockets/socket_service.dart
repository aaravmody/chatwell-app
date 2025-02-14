import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  bool isConnected = false;

  void connect(
      String username, String room, Function onConnect, Function onError) {
    try {
      socket = IO.io(
          'https://chat-site-7pl2.onrender.com',
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .build());

      socket.connect();

      socket.onConnect((_) {
        print('Connected to server');
        isConnected = true;
        socket.emit('joinroom', {'username': username, 'room': room});
        onConnect();
      });

      socket.on('message', (data) {
        print('Message received: $data');
      });

      socket.onDisconnect((_) {
        print('Disconnected from server');
        isConnected = false;
      });
    } catch (e) {
      print('Connection error: $e');
      onError(e);
    }
  }

  void sendMessage(String message) {
    if (isConnected) {
      socket.emit('chatmsg', message);
    } else {
      print('Cannot send message, not connected to server');
    }
  }

  void disconnect() {
    socket.disconnect();
  }
}
