import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'dart:io';

class DataStorageTile extends StatelessWidget {
  final String filePath;
  final int id;
  final VoidCallback onDelete;

  const DataStorageTile({
    super.key,
    required this.filePath,
    required this.id,
    required this.onDelete,
  });

  void _openPDF() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await OpenFilex.open(filePath);
      } else {
        // File doesn't exist, show error
        debugPrint('File not found: $filePath');
      }
    } catch (e) {
      debugPrint('Error opening PDF: $e');
    }
  }

  String _getFileSize() {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        if (bytes < 1024) {
          return '${bytes} B';
        } else if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        } else {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
      }
      return 'Unknown size';
    } catch (e) {
      return 'Unknown size';
    }
  }

  String _getFileDate() {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final lastModified = file.lastModifiedSync();
        return '${lastModified.day}/${lastModified.month}/${lastModified.year}';
      }
      return 'Unknown date';
    } catch (e) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = basename(filePath);
    final fileExists = File(filePath).existsSync();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: fileExists ? Colors.red.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
              Icons.picture_as_pdf_rounded,
              color: fileExists ? Colors.red : Colors.grey,
              size: 32
          ),
        ),
        title: Text(
          fileName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: fileExists ? Colors.black : Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileExists ? 'Tap to open' : 'File not found',
              style: TextStyle(
                color: fileExists ? Colors.grey.shade600 : Colors.red.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_getFileSize()} • ${_getFileDate()}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          color: Colors.white,
          icon: const Icon(Icons.more_vert_outlined, color: Colors.grey),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text("Delete", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel_outlined, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text("Cancel", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        onTap: fileExists ? _openPDF : null,
      ),
    );
  }
}