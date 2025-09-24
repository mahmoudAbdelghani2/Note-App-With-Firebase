import 'package:flutter/material.dart';
import 'package:flutter_application/models/note_model.dart';
import 'package:intl/intl.dart';

class DetailsScreen extends StatefulWidget {
  final NoteModel note;

  const DetailsScreen({super.key, required this.note});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String _formatDate(DateTime date) {
    final formatter = DateFormat('MM/dd/yyyy HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Note Details'),
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
            icon: Icon(Icons.edit, color: Color(0xFF0D1C1C)),
            onPressed: () {
              // TODO: Implement edit functionality here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.note.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1C1C),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.note.content,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF0D1C1C),
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Created At: ${_formatDate(widget.note.createdAt)}',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0XFF4A9C9C),
              ),
            ),
            if (widget.note.updatedAt != null) ...[
              SizedBox(height: 8),
              Text(
                'Last Updated: ${_formatDate(widget.note.updatedAt!)}',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
