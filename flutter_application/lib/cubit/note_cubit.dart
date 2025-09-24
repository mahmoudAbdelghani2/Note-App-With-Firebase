import 'package:flutter_application/cubit/note_states.dart';
import 'package:flutter_application/models/note_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NoteCubit extends Cubit<NoteState> {
  NoteCubit() : super(InitialNoteState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'notes';
  List<NoteModel> notes = [];

  void loadNotes() async {
    emit(LoadingNoteState());
    try {
      QuerySnapshot snapshot = await _firestore.collection(collectionPath).get();
      notes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NoteModel.fromJson({...data, 'id': doc.id});
      }).toList();

      emit(NotesLoadedState(List.from(notes)));
    } catch (e) {
      debugPrint('Error getting notes: $e');
      emit(ErrorNoteState(e.toString()));
    }
  }

  void addNote(NoteModel note) async {
    emit(LoadingNoteState());
    try {
      final docRef = await _firestore.collection(collectionPath).add(note.toJson());
      final newNote = note.copyWith(id: docRef.id);

      notes.add(newNote);

      emit(NotesLoadedState(List.from(notes)));
    } catch (e) {
      debugPrint('Error adding note: $e');
      emit(ErrorNoteState(e.toString()));
    }
  }

  void deleteNote(String noteId) async {
    emit(LoadingNoteState());
    try {
      await _firestore.collection(collectionPath).doc(noteId).delete();

      notes.removeWhere((note) => note.id == noteId);

      emit(NotesLoadedState(List.from(notes)));
    } catch (e) {
      debugPrint('Error deleting note: $e');
      emit(ErrorNoteState(e.toString()));
    }
  }

  void updateNote(NoteModel updatedNote) async {
    emit(LoadingNoteState());
    try {
      await _firestore.collection(collectionPath).doc(updatedNote.id).update(updatedNote.toJson());

      int index = notes.indexWhere((note) => note.id == updatedNote.id);
      if (index != -1) {
        notes[index] = updatedNote;
      }

      emit(NotesLoadedState(List.from(notes)));
    } catch (e) {
      debugPrint('Error updating note: $e');
      emit(ErrorNoteState(e.toString()));
    }
  }
}
