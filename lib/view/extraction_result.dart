import 'dart:io';

import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/cutom_button.dart';
import 'package:dataextractor_analyzer/utils/components/document-tile.dart';
import 'package:dataextractor_analyzer/utils/media_query_util.dart';
import 'package:dataextractor_analyzer/view-model/edit-text-view-model.dart';
import 'package:dataextractor_analyzer/view/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

class ExtractionResult extends StatefulWidget {
  final String? initialValue;

  const ExtractionResult({super.key, required this.initialValue});

  @override
  State<ExtractionResult> createState() => _ExtractionResultState();
}

class _ExtractionResultState extends State<ExtractionResult> {
  final TextEditingController _textController = TextEditingController();

  /// Generates a PDF document with the current text content
  Future<void> generatePDF() async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
      return;
    }
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    print("Permission granted");
    // Create the PDF document
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            _textController.text,
            style: pw.TextStyle(fontSize: 20, font: ttf),
          ),
        ),
      ),
    );

    Future<Directory?> getDownloadDirectory() async {
      if (Platform.isAndroid) {
        return await getExternalStorageDirectory();
      } else {
        return await getApplicationDocumentsDirectory();
      }
    }
    // Get Downloads directory
    final directory = await getDownloadDirectory();
    if (directory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to access storage")),
      );
      return;
    }
    final path =
        '${directory?.path}/GeneratedPDF-${DateTime.now().microsecondsSinceEpoch}.pdf';
    final file = File(path);

    try {
      // Write the PDF to the file
      await Directory(directory.path).create(recursive: true);
      await file.writeAsBytes(await pdf.save());

      // Notify media scanner
      const platform = MethodChannel('flutter/media_scanner');
      await platform.invokeMethod('scanFile', {'path': path});

      // Show success dialog
      _showSuccessDialog(path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving PDF: $e")),
      );
    }
  }

  /// Shows a success dialog when the PDF is generated
  void _showSuccessDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("PDF Generated"),
        content: Text("PDF saved to Downloads: $path"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialValue ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        onLeadingPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
          );
        },
      ),
      body: Consumer<EditTextViewModel>(
        builder: (context, value, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(
                    "Extraction Results",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: 10),
                // Text Section
                Text(
                  "Text",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _textController,
                  maxLines: 8,
                  readOnly: value.readOnly,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 10),
                // Action Buttons (Edit & Export)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: "Edit",
                      onPressed: () {
                        value.setReadOnly(false);
                      },
                    ),
                    const SizedBox(width: 5),
                    CustomButton(
                      text: "Export",
                      onPressed: () {
                        _showExportOptions();
                      },
                    ),
                  ],
                ),
                const Spacer(),
                // Navigation Buttons (Back & Save)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: "Back",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 15),
                    CustomButton(
                      text: "Save",
                      onPressed: () {
                        // Handle save logic here
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Displays the export options
  void _showExportOptions() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          height: MediaQueryUtil.screenHeight(context) * 0.35,
          child: Center(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, value) {
                return DocumentTile(
                  icon: Icons.picture_as_pdf,
                  color: AppColors.redColor,
                  text: "PDF Document",
                  onTap: () async{
                    await generatePDF();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
