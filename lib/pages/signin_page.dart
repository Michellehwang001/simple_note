import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_note/pages/signup_page.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/providers/auth_provider.dart';
import 'package:simple_note/widgets/error_dialog.dart';

class SigninPage extends StatefulWidget {
  static const String routeName = 'signin-page';

  const SigninPage({Key? key}) : super(key: key);

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _fKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  String _email = '';
  String _passwd = '';

  Future<void> _submit() async {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    if (!_fKey.currentState!.validate()) return;

    _fKey.currentState!.save();

    try {
      await context
          .read<AuthProvider>()
          .signIn(email: _email, password: _passwd);
    } on FirebaseAuthException catch (e) {
      print('Error : $e');
      errorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>().state;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Your Notes',
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.0,
              ),
              Form(
                key: _fKey,
                autovalidateMode: autovalidateMode,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (String? val) {
                          // 정규표현식으로 정교하게 체크 가능
                          if (val == null || val.trim().length == 0) {
                            return '이메일을 입력해 주세요!';
                          }
                          if (!val.trim().contains('@')) {
                            return '이메일 형식을 확인해 주세요!';
                          }
                          return null;
                        },
                        onSaved: (val) => _email = val ?? '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        obscureText: true, // 글자 안보이게
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (String? val) {
                          // 정규표현식으로 정교하게 체크 가능
                          if (val == null || val.trim().length == 0) {
                            return '비밀번호를 입력해 주세요.';
                          }
                          if (val.trim().length < 6) {
                            return '비밀번호는 6자 이상입니다.';
                          }
                          return null;
                        },
                        onSaved: (val) => _passwd = val ?? '',
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    OutlinedButton.icon(
                        onPressed: authState.loading == true ? null : _submit,
                        icon: Icon(Icons.send),
                        label: Text(
                          '로그인',
                          style: TextStyle(fontSize: 20.0),
                        )),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, SignupPage.routeName);
                      },
                      child: Text(
                        'No account? Sign Up!',
                        style: TextStyle(
                            fontSize: 18.0,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
