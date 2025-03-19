import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/data_storage_tile.dart';
import 'package:flutter/material.dart';

import '../db_helper/database_helper.dart';

class DataStorage extends StatefulWidget {
  const DataStorage({super.key});

  @override
  State<DataStorage> createState() => _DataStorageState();
}

class _DataStorageState extends State<DataStorage> {
  List<String> allPdfs = [];

  @override
  void initState() {
    super.initState();
    _loadPDFs(); // Call async function
  }

  Future<void> _loadPDFs() async {
    final pdfs = await DatabaseHelper.instance.getPDFs();
    setState(() {
      allPdfs = pdfs;
    });
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
      body: ListView.builder(
        itemCount: allPdfs.length,
        itemBuilder: (context, index) {
          return DataStorageTile(filePath: allPdfs[index]);
        },
      ),
    );
  }
}

