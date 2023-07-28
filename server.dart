import 'dart:io';
import 'dart:typed_data';
import 'player.dart';
import 'socket_services.dart';
// import 'package:flutter/services.dart';

Future<void> main() async {
  final ip = InternetAddress.anyIPv4;
  final server = await ServerSocket.bind(ip, 3000);
  print("Server is running on: ${ip.address}:3000");
  server.listen((Socket event) {
    handleConnection(event);
  });
}

List<Player> players = [];

void handleConnection(Socket client) {
  print(
    "Connection from ${client.remoteAddress.address}:${client.remotePort}",
  );

  client.listen(
    (Uint8List data) async {
      final message = String.fromCharCodes(data);

      SocketCommand command = parseCommand(message);

      if (command.key == SocketAction.login) {
        for (var player in players) {
          player.socket.write(SocketCommand(
              SocketAction.successMessage, "${command.value} joined the game"));
        }

        players.add(Player(socket: client, username: command.value.toString()));

        client.write(
          SocketCommand(SocketAction.successMessage,
              "You are logged in as: ${command.value}"),
        );
      }
    }, // handle errors
    onError: (error) {
      print(error);
      client.close();
      players.removeWhere(((element) => element.socket == client));
    },

    // handle the client closing the connection
    onDone: () {
      print('Client left');
      client.close();
      players.removeWhere(((element) => element.socket == client));
    },
  );
}
