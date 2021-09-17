import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/pages/add_edit_note_page.dart';
import 'package:simple_note/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:simple_note/providers/note_provider.dart';
import 'package:simple_note/widgets/error_dialog.dart';

class NotesPage extends StatefulWidget {
  static const String routeName = 'note-page';

  const NotesPage({Key? key}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String userId = 'guest';

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final user = context.read<firebase_auth.User?>();
      userId = user!.uid;

      try {
        print(userId);
        await context.read<NoteProvider>().getAllNotes(userId);
      } on Exception catch (e) {
        errorDialog(context, e);
      }
    });
    super.initState();
    // 데이터를 읽어온다.
  }

  @override
  Widget build(BuildContext context) {
    final noteList = context.watch<NoteProvider>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEditNotePage()),
                );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
          )
        ],
      ),
      body: _buildBody(noteList),
    );
  }

  Widget _buildBody(NoteListState noteList) {
    if (noteList.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (noteList.notes.isEmpty) {
      return const Center(
        child: Text(
          '등록된 메모가 없습니다.',
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }

    return ListView.builder(
      itemCount: noteList.notes.length,
      itemBuilder: (BuildContext context, int index) {
        final note = noteList.notes[index];

        return Dismissible(
          key: ValueKey(note.id),
          onDismissed: (_) async {
            try {
              print('delete mode!!! ');
              await context.read<NoteProvider>().removeNote(note);
            } on Exception catch (e) {
              errorDialog(context, e);
            }
          },
          confirmDismiss: (_) async {
            return await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('삭제하시겠습니까?'),
                  content: const Text('삭제하시면 복구할 수 없습니다. \n삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('예'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('아니오'),
                    ),
                  ],
                );
              },
            );
          },
          background: showDismissibleBackground(0),
          secondaryBackground: showDismissibleBackground(1),
          child: Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddEditNotePage(note: note)),
                  );
              },
              title: Text(
                note.title,
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(note.timestamp.toDate().toIso8601String(),),
            ),
          ),
        );
      },
    );
  }

  Widget showDismissibleBackground(int i) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: Colors.deepOrange,
      alignment: i == 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: const Icon(
        Icons.delete,
        size: 30,
        color: Colors.white,
      ),
    );
  }
}
