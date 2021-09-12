import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class ProfilePage extends StatefulWidget {
  static const String routeName = 'note-page';

  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<firebase_auth.User?>();

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
      body: const Center(
        child: Text('Profile'),
      ),
    );
  }
}
