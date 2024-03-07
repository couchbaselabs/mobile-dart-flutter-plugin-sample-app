import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  ChatViewState createState() => ChatViewState();
}

class ChatViewState extends State<ChatView> {
  bool _isPrivate = false;
  final TextEditingController _roomController = TextEditingController();

  void _enterRoom() {
    // Implement logic to enter room
    String roomName = _roomController.text;
    // Navigate to the chat window with the room name
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatWindow(roomName: roomName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Page'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text(
                'Chat Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Join Private Chat'),
              onTap: () {
                setState(() {
                  _isPrivate = true;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Join Public Chat'),
              onTap: () {
                setState(() {
                  _isPrivate = false;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
             const SizedBox(height: 50,),
            Text(
              'You are in ${_isPrivate ? 'Private' : 'Public'} Chat',
              style: const TextStyle(fontSize: 20.0),
            ),

            _isPrivate ? const SizedBox(height: 20.0) : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _roomController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Room Name',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _enterRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text('Enter'),
                  ),
                ],
              ),
            ),
           
          ],
        ),
      ),
    );
  }
}

class ChatWindow extends StatelessWidget {
  final String roomName;

  const ChatWindow({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Text('Chat Window for $roomName'),
      ),
    );
  }
}