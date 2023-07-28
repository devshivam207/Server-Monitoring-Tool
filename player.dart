import 'dart:io';

class Player {
  late Socket socket;
  late String username;

  Player({required this.socket, required this.username});
}
