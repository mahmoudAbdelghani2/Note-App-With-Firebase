import 'package:flutter/material.dart';
import 'package:flutter_application/cubit/note_cubit.dart';
import 'package:flutter_application/cubit/note_states.dart';
import 'package:flutter_application/cubit/signin_cubit.dart';
import 'package:flutter_application/views/screens/add_note_screen.dart';
import 'package:flutter_application/views/screens/login_screen.dart';
import 'package:flutter_application/views/widgets/list_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllNotesScreen extends StatefulWidget {
  const AllNotesScreen({super.key});

  @override
  State<AllNotesScreen> createState() => _AllNotesScreenState();
}

class _AllNotesScreenState extends State<AllNotesScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<NoteCubit>(context).loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 0, 140, 255),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
            (route) => false,
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Notes List'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0D1C1C),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF0D1C1C),
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showSignOutDialog(context);
            },
            icon: Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: BlocConsumer<NoteCubit, NoteState>(
          listener: (context, state) {
            if (state is DeletedNoteState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Note deleted successfully!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            } else if (state is ErrorNoteState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error: ${state.message}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: Duration(seconds: 4),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is LoadingNoteState) {
              return CircularProgressIndicator();
            } else if (state is NotesLoadedState) {
              final notes = state.notes;
              if (notes.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListWidget(note: note);
                },
              );
            } else if (state is ErrorNoteState) {
              return Text(
                'Error: ${state.message}',
                style: TextStyle(fontSize: 18, color: Colors.red),
              );
            } else {
              return _buildEmptyState(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No notes in the list. Go ahead and add some!',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 23, 53, 53),
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AddNoteScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text(
              'Add a new note',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sign Out',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1C1C),
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(fontSize: 16, color: Color(0xFF4A9C9C)),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF4A9C9C), fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );

                final noteCubit = BlocProvider.of<NoteCubit>(context);
                final authCubit = BlocProvider.of<AuthCubit>(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Signing out...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Color(0xFF4A9C9C),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );

                Future.delayed(Duration(milliseconds: 800), () {
                  if (mounted) {
                    noteCubit.clearNotes();
                    authCubit.signOut();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
