import 'package:flutter_application/cubit/note_states.dart';
import 'package:flutter_application/models/note_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NoteCubit extends Cubit<NoteState> {
  NoteCubit() : super(InitialNoteState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collectionPath = 'notes';
  List<NoteModel> notes = [];

  // الحصول على معرف المستخدم الحالي
  String? get currentUserId => _auth.currentUser?.uid;

  void loadNotes() async {
    emit(LoadingNoteState());
    try {
      // التأكد من وجود مستخدم مسجل دخول
      if (currentUserId == null) {
        emit(ErrorNoteState('Please sign in to view your notes'));
        return;
      }

      // تحميل الملاحظات الخاصة بالمستخدم الحالي فقط
      QuerySnapshot snapshot = await _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: currentUserId)
          .get();
          
      notes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NoteModel.fromJson({...data, 'id': doc.id});
      }).toList();
      
      // ترتيب النتائج محلياً حسب تاريخ الإنشاء
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(NotesLoadedState(List.from(notes)));
    } catch (e) {
      debugPrint('Error getting notes: $e');
      emit(ErrorNoteState(e.toString()));
    }
  }

  void addNote(NoteModel note) async {
    emit(LoadingNoteState());
    try {
      // التأكد من وجود مستخدم مسجل دخول
      if (currentUserId == null) {
        emit(ErrorNoteState('Please sign in to add notes'));
        return;
      }

      // إنشاء ملاحظة مع معرف المستخدم
      final noteWithUserId = note.copyWith(userId: currentUserId);
      final docRef = await _firestore
          .collection(collectionPath)
          .add(noteWithUserId.toJson());
      
      final newNote = noteWithUserId.copyWith(id: docRef.id);
      notes.add(newNote);

      emit(AddedNoteState(List.from(notes)));
    } catch (e) {
      debugPrint('Error adding note: $e');
      emit(ErrorNoteState(e.toString()));
    }
  }

  void deleteNote(String noteId) async {
    emit(LoadingNoteState());
    try {
      // التأكد من وجود مستخدم مسجل دخول
      if (currentUserId == null) {
        emit(ErrorNoteState('Please sign in to delete notes'));
        return;
      }

      // التأكد من أن الملاحظة تخص المستخدم الحالي قبل الحذف
      final noteToDelete = notes.firstWhere((note) => note.id == noteId);
      if (noteToDelete.userId != currentUserId) {
        emit(ErrorNoteState('You can only delete your own notes'));
        return;
      }

      await _firestore.collection(collectionPath).doc(noteId).delete();
      notes.removeWhere((note) => note.id == noteId);

      emit(DeletedNoteState(List.from(notes)));
    } catch (e) {
      debugPrint('Error deleting note: $e');
      emit(ErrorNoteState(e.toString()));
    }
  }

  void updateNote(NoteModel updatedNote) async {
    emit(LoadingNoteState());
    try {
      // التأكد من وجود مستخدم مسجل دخول
      if (currentUserId == null) {
        emit(ErrorNoteState('Please sign in to update notes'));
        return;
      }

      // التأكد من أن الملاحظة تخص المستخدم الحالي قبل التحديث
      if (updatedNote.userId != currentUserId) {
        emit(ErrorNoteState('You can only update your own notes'));
        return;
      }

      await _firestore
          .collection(collectionPath)
          .doc(updatedNote.id)
          .update(updatedNote.toJson());

      int index = notes.indexWhere((note) => note.id == updatedNote.id);
      if (index != -1) {
        notes[index] = updatedNote;
        emit(UpdatedNoteState(updatedNote));
      } else {
        emit(NotesLoadedState(List.from(notes)));
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
      emit(ErrorNoteState(e.toString()));
    }
  }

  // تنظيف الملاحظات عند تسجيل الخروج
  void clearNotes() {
    notes.clear();
    emit(InitialNoteState());
  }
}