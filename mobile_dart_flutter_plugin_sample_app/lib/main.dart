import 'package:flutter/material.dart';
import 'package:mobile_dart_flutter_plugin_sample_app/presentation/view/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme:ThemeData(
        primaryColor: Colors.red,
        fontFamily: 'Roboto', colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.redAccent),
      ),
      home:  LoginView(),
    );
  }
}