import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_note/models/note_model.dart';
import 'package:simple_note/pages/add_edit_note_page.dart';
import 'package:simple_note/providers/note_provider.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  Future<List<QuerySnapshot>>? _notes;
  late String userId;
  late String searchTerm;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _searchController = TextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final user = context.read<firebase_auth.User?>();
      // Check null
      if (user != null) {
        userId = user.uid;
      }
    });
    super.initState();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _notes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: const TextStyle(color: Colors.white),
          controller: _searchController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
            filled: true,
            border: InputBorder.none,
            hintText: 'Search...',
            hintStyle: const TextStyle(color: Colors.white),
            prefixIcon: const Icon(
              Icons.search,
              size: 25.0,
              color: Colors.white,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.clear,
                size: 30.0,
                color: Colors.white,
              ),
              onPressed: _clearSearch,
            ),
          ),
          onSubmitted: (val) {
            searchTerm = val;

            if (searchTerm.isNotEmpty) {
              setState(() {
                _notes = context
                    .read<NoteProvider>()
                    .searchNotes(userId, searchTerm);
              });
            }
          },
        ),
      ),
      body: _notes == null
          ? const Center(
              child: Text(
                '찾으실 단어를 입력해 주세요.',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : FutureBuilder(
              future: _notes,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<Note> foundNotes = [];

                for (int i = 0; i < snapshot.data.length; i++) {
                  for (int j = 0; j < snapshot.data[i].docs.length; j++) {
                    foundNotes.add(Note.fromDoc(snapshot.data[i].docs[j]));
                  }
                }

                foundNotes = [
                  ...{...foundNotes}
                ];

                if (foundNotes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No note found, please try again',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  );
                }

                return ListView.builder(
                    itemCount: foundNotes.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Note note = foundNotes[index];

                      return Card(
                        child: ListTile(
                          onTap: () async {
                            final modified = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddEditNotePage(
                                    note: note,
                                  );
                                },
                              ),
                            );

                            if (modified == true) {
                              setState(() {
                                _notes = context
                                    .read<NoteProvider>()
                                    .searchNotes(userId, searchTerm);
                              });
                            }
                          },
                          title: Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('yyyy-MM-dd, hh:mm:ss')
                                .format(note.timestamp.toDate()),
                          ),
                        ),
                      );
                    });
              },
            ),
    );
  }
}
