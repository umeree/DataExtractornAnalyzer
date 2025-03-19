import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';

import '../../db_helper/database_helper.dart';

class DataStorageTile extends StatelessWidget {
  final String filePath;
  final int id;

  const DataStorageTile({super.key, required this.filePath, required this.id});

  void _openPDF() {
    OpenFilex.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 40),
      title: Text(
        basename(filePath), // Extracts filename from the full path
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Tap to open'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async{
          if (value == 'delete') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Delete selected")),
            );
              DatabaseHelper.instance.deletePDF(id);
              await DatabaseHelper.instance.getPDFs();
          }
        },
        color: Colors.black, // Set background color to black
        icon: Icon(Icons.more_vert_outlined, ), // More Vert Icon
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'delete',
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
          PopupMenuItem<String>(
            value: 'cancel',
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      onTap: _openPDF,
    );
  }
}
