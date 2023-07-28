import 'dart:io';
import 'dart:typed_data';
import 'socket_services.dart';

Future<void> main() async {
  final socket = await Socket.connect("0.0.0.0", 3000);
  print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

  socket.listen(
    (Uint8List data) {
      final serverResponse = String.fromCharCodes(data);
      var parsedCommand = parseCommand(serverResponse);

      if (parsedCommand.key == SocketAction.successMessage) {
        print(parsedCommand.value.toString());
      }
    },
    // handle errors
    onError: (error) {
      print(error);
      socket.destroy();
    },

    // handle server ending connection
    onDone: () {
      print('Server left.');
      socket.destroy();
    },
  );

// Ask user for its username
  String? username;

  do {
    print("Please enter your username");
    username = stdin.readLineSync();
  } while (username == null || username.isEmpty);

  sendMessageToServer(socket, MapEntry(SocketAction.login, username));
}
