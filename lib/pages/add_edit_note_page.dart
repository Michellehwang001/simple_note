import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_note/models/note_model.dart';
import 'package:simple_note/providers/note_provider.dart';
import 'package:simple_note/widgets/error_dialog.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AddEditNotePage extends StatefulWidget {
  final Note? note;

  const AddEditNotePage({Key? key, this.note}) : super(key: key);

  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String _title = '';
  String _desc = '';

  void _submit(String mode) async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    print('_title --> $_title, _desc --> $_desc ');

    try {
      final noteOwnerId = context.read<firebase_auth.User?>()!.uid;
      print('noteOwnerId --> $noteOwnerId, mode --> $mode');

      if (mode == 'add') {
        final newNote = Note(
          title: _title,
          desc: _desc,
          noteOwnerId: noteOwnerId,
          timestamp: Timestamp.fromDate(DateTime.now()),
        );
        // add
        await context.read<NoteProvider>().addNote(newNote);
      } else {
        // 수정 note는 있다고 본다
        final newNote = Note(
          id: widget.note!.id,
          title: _title,
          desc: _desc,
          noteOwnerId: noteOwnerId,
          timestamp: widget.note!.timestamp,
        );
        // edit
        await context.read<NoteProvider>().updateNote(newNote);
      }

      Navigator.pop(context);
    } on Exception catch (e) {
      errorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteState = context.watch<NoteProvider>().state;

    return Scaffold(
      appBar: AppBar(
        title: widget.note == null
            ? const Text('Add Note')
            : const Text('Edit Note'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 10.0),
                  child: TextFormField(
                    initialValue: widget.note != null ? widget.note!.title : '',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: '제목',
                    ),
                    validator: (val) =>
                    (val == null || val.trim().isEmpty) ? '제목을 입력해 주세요.' : null,
                    onSaved: (val) => _title = val!,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 10.0),
                  child: TextFormField(
                    initialValue: widget.note == null ? '' : widget.note!.desc,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: '내용',
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? '내용을 입력해 주세요.' : null,
                    onSaved: (val) => _desc = val!,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                    onPressed: noteState.loading
                        ? null
                        : () => _submit(widget.note == null ? 'add' : 'edit'),
                    child: Text(
                      widget.note == null ? 'Add Note' : 'Edit Note',
                      style: const TextStyle(fontSize: 20.0),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
