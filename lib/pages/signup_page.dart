import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/providers/auth_provider.dart';
import 'package:simple_note/widgets/error_dialog.dart';

class SignupPage extends StatefulWidget {
  static const String routeName = 'signup-page';

  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _fKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  String _name = '';
  String _email = '';
  String _passwd = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Check Validation
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    if (!_fKey.currentState!.validate()) return;

    // save
    _fKey.currentState!.save();

    // 회원가입
    try {
      await context
          .read<AuthProvider>()
          .signUp(context, name: _name, email: _email, password: _passwd);
    } on FirebaseAuthException catch(e) {
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
                          labelText: '이름',
                          prefixIcon: Icon(Icons.account_circle),
                        ),
                        validator: (String? val) {
                          // 정규표현식으로 정교하게 체크 가능
                          if (val == null || val.trim().isEmpty) {
                            return '이름을 입력해 주세요!';
                          }
                          return null;
                        },
                        onSaved: (val) => _name = val ?? '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: '이메일',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (String? val) {
                          // 정규표현식으로 정교하게 체크 가능
                          if (val == null || val.trim().isEmpty) {
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
                        controller: _passwordController,
                        obscureText: true,
                        // 글자 안보이게
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: '비밀번호',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (String? val) {
                          // 정규표현식으로 정교하게 체크 가능
                          if (val == null || val.trim().isEmpty) {
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        obscureText: true, // 글자 안보이게
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: '비밀번호 확인',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (String? val) {
                          // 정규표현식으로 정교하게 체크 가능
                          if (val == null || val.trim().isEmpty) {
                            return '비밀번호 확인을 입력해 주세요.';
                          }
                          if (_passwordController.text != val) {
                            return '비밀번호와 확인이 일치하지 않습니다.';
                          }
                          return null;
                        },
                        onSaved: (val) => _passwd = val ?? '',
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    OutlinedButton(
                      onPressed: authState.loading == true ? null : _submit,
                      child: const Text(
                        '회원가입',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Have an account? Sign In!',
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
