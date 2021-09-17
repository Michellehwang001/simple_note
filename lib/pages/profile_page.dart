import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:simple_note/providers/profile_provider.dart';
import 'package:simple_note/widgets/error_dialog.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = 'note-page';

  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String _userId;
  late String _name;
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();

    // user 정보가져와야.
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final user = context.read<firebase_auth.User?>();
      if (user != null) {
        _userId = user.uid;
      }

      try {
        await context.read<ProfileProvider>().getUserProfile(_userId);
      } on Exception catch (e) {
        print(e);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().state;

    if (profile.user != null) {
      _emailController.text = profile.user!.email;
      _nameController.text = profile.user!.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(50.0, 50.0, 30.0, 10.0),
                  child: TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'Email',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 10.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'Name',
                    ),
                    validator: (val) =>
                        val!.trim().isEmpty ? '이름을 입력하세요' : null,
                    onSaved: (val) => _name = val!,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text(
                    '수정하기',
                    style: TextStyle(fontSize: 20.0),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      await context
          .read<ProfileProvider>()
          .editUserProfile(_userId, _name, _emailController.text);

      showDialog(context: context, builder: (context) {
        return const AlertDialog(
          content: Text('수정되었습니다!'),
          // actions: [
          //   TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          // ],
        );
      });
    } on Exception catch (e) {
      errorDialog(context, e);
    }
  }
}
