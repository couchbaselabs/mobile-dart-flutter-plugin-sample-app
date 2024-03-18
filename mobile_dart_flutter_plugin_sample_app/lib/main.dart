import 'package:cbl_flutter_multiplatform/cbl_flutter_multiplatform.dart';
import 'package:flutter/material.dart';
import 'package:mobile_dart_flutter_plugin_sample_app/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CouchbaseLiteFlutter.init();

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
      home:  const LoginView(),
    );
  }
}