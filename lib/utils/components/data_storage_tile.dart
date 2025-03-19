import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';

class DataStorageTile extends StatelessWidget {
  final String filePath;

  const DataStorageTile({super.key, required this.filePath});

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
      trailing: IconButton(onPressed: (){}, icon: Icon(Icons.more_vert_outlined)),
      onTap: _openPDF,
    );
  }
}
