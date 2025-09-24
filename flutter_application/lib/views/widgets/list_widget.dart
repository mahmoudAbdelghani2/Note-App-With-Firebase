import 'package:flutter/material.dart';
import 'package:flutter_application/cubit/note_cubit.dart';
import 'package:flutter_application/cubit/note_states.dart';
import 'package:flutter_application/models/note_model.dart';
import 'package:flutter_application/views/screens/details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListWidget extends StatefulWidget {
  final NoteModel note;
  const ListWidget({super.key, required this.note});

  @override
  State<ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(note: widget.note),
          ),
        );
      },
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
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: Colors.white,
            elevation: 4,
            child: ListTile(
              title: Text(
                widget.note.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF0D1C1C),
                ),
                textAlign: TextAlign.start,
              ),
              subtitle: Text(
                widget.note.content,
                style: TextStyle(fontSize: 16, color: Color(0xFF4A9C9C)),
                textAlign: TextAlign.start,
              ),
              trailing: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Delete Note'),
                        content: Text(
                          'Are you sure you want to delete this note?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              BlocProvider.of<NoteCubit>(
                                context,
                              ).deleteNote(widget.note.id!);
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFF0D1C1C),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
