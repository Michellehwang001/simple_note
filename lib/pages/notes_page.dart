import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  static const String routeName = 'note-page';
  const NotesPage({Key? key}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Notes'),
        ),
        body: Center(
          child: Text('Notes'),
        ),
    );
  }
}
