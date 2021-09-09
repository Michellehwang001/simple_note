import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/pages/notes_page.dart';
import 'package:simple_note/pages/signin_page.dart';
import 'package:simple_note/pages/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:simple_note/providers/auth_provider.dart';

void main() async {
  // firebase를 사용하기 위해 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
        providers: [
          StreamProvider<firebaseAuth.User?>.value(
            value: firebaseAuth.FirebaseAuth.instance.authStateChanges(), initialData: null,
          ),
          ChangeNotifierProvider.value(
            value: AuthProvider(),
          ),
        ],
        child: MyApp(),
    ),
  );
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // 로그인 유무 체크
  isAuthenticated(BuildContext context) {
    if (context.watch<firebaseAuth.User?>() != null) {
      return NotesPage();
    }
    return SigninPage();
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
          SigninPage.routeName: (context) => SigninPage(),
          SignupPage.routeName: (context) => SignupPage(),
          NotesPage.routeName: (context) => NotesPage(),
        },
      );
  }
}
