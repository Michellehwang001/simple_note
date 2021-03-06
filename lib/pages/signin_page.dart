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
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Your Notes',
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
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
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (String? val) {
                          // ????????????????????? ???????????? ?????? ??????
                          if (val == null || val.trim().isEmpty) {
                            return '???????????? ????????? ?????????!';
                          }
                          if (!val.trim().contains('@')) {
                            return '????????? ????????? ????????? ?????????!';
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
                        obscureText: true, // ?????? ????????????
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (String? val) {
                          // ????????????????????? ???????????? ?????? ??????
                          if (val == null || val.trim().isEmpty) {
                            return '??????????????? ????????? ?????????.';
                          }
                          if (val.trim().length < 6) {
                            return '??????????????? 6??? ???????????????.';
                          }
                          return null;
                        },
                        onSaved: (val) => _passwd = val ?? '',
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    OutlinedButton.icon(
                        onPressed: authState.loading == true ? null : _submit,
                        icon: const Icon(Icons.send),
                        label: const Text(
                          '?????????',
                          style: TextStyle(fontSize: 20.0),
                        )),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, SignupPage.routeName);
                      },
                      child: const Text(
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
