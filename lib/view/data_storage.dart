import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/data_storage_tile.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../db_helper/database_helper.dart';

class DataStorage extends StatefulWidget {
  const DataStorage({super.key});

  @override
  State<DataStorage> createState() => _DataStorageState();
}

class _DataStorageState extends State<DataStorage> {
  List<Map<String, dynamic>> allPdfs = []; // Changed to store full records with ID

  @override
  void initState() {
    super.initState();
    _loadPDFs();
  }

  Future<void> _loadPDFs() async {
    final pdfs = await DatabaseHelper.instance.getAllPDFRecords(); // Get full records
    setState(() {
      allPdfs = pdfs;
    });
  }

  Future<void> _deletePDF(int id, String filePath) async {
    try {
      // Show confirmation dialog
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete PDF'),
            content: const Text('Are you sure you want to delete this PDF file?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        // Delete from database
        await DatabaseHelper.instance.deletePDF(id);

        // Delete physical file
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }

        // Refresh the list
        await _loadPDFs();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        title: Text("Data Storage", style: Theme.of(context).textTheme.displayLarge),
      ),
      body: allPdfs.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No PDFs found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create some PDFs to see them here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: allPdfs.length,
        itemBuilder: (context, index) {
          final pdfRecord = allPdfs[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: DataStorageTile(
              filePath: pdfRecord['path'],
              id: pdfRecord['id'],
              onDelete: () => _deletePDF(pdfRecord['id'], pdfRecord['path']),
            ),
          );
        },
      ),
    );
  }
}