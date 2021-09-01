// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:simple_note/pages/signin_page.dart';

void main() async {
  // firebase를 사용하기 위해.
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SigninPage(),
    );
  }
}