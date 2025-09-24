import 'package:flutter_application/models/note_model.dart';

abstract class NoteState {}

class InitialNoteState extends NoteState {}

class LoadingNoteState extends NoteState {}

class NotesLoadedState extends NoteState {
  final List<NoteModel> notes;
  NotesLoadedState(this.notes);
}

class ErrorNoteState extends NoteState {
  final String message;
  ErrorNoteState(this.message);
}

class AddedNoteState extends NoteState {
  final List<NoteModel> notes;
  AddedNoteState(this.notes);
}

class DeletedNoteState extends NoteState {
  final List<NoteModel> notes;
  DeletedNoteState(this.notes);
}

class UpdatedNoteState extends NoteState {
  final NoteModel updatedNote;
  UpdatedNoteState(this.updatedNote);
}