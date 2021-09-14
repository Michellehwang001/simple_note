import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/pages/home_page.dart';
import 'package:simple_note/pages/notes_page.dart';
import 'package:simple_note/pages/signin_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:simple_note/pages/signup_page.dart';
import 'package:simple_note/providers/auth_provider.dart';
import 'package:simple_note/providers/note_provider.dart';

void main() async {
  // firebase를 사용하기 위해 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<firebase_auth.User?>.value(
          value: firebase_auth.FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<NoteList>(
          create: (context) => NoteList(),
        ),
      ],
      child: const MyApp(),
    ),
  );
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // 로그인 유무 체크
  isAuthenticated(BuildContext context) {
    if (context.watch<firebase_auth.User?>() != null) {
      return const HomePage();
    }
    return const SigninPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: isAuthenticated(context),
      routes: {
        SigninPage.routeName: (context) => const SigninPage(),
        SignupPage.routeName: (context) => const SignupPage(),
        NotesPage.routeName: (context) => const NotesPage(),
      },
    );
  }
}
