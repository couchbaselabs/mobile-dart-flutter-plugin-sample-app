import 'package:flutter/material.dart';
import 'chat_mobile.dart' if (dart.library.html) 'chat_web.dart';

class LandingView extends StatefulWidget {
  const LandingView(
      {required this.username, required this.password, super.key});

  final String username;
  final String password;

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Public Channel'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatMessagesPage(
                            channel: 'public',
                            username: widget.username,
                            password: widget.password)),
                  );
                },
                child: const Text('Open Chat'),
              ),
              SizedBox(height: 20.0), // Add this line
              const Text('Private Channel'),
              // add textformfield for private channel
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  hintText: 'Private Channel',
                  labelText: 'Username for private chat',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  if (usernameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a username'),
                      ),
                    );

                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatMessagesPage(
                            channel: usernameController.text,
                            username: widget.username,
                            password: widget.password)),
                  );
                },
                child: const Text('Open Chat'),
              ),
            ]),
      ),
    );
  }
}
