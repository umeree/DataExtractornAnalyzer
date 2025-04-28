import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:dataextractor_analyzer/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/cutom_button.dart';
import 'package:dataextractor_analyzer/utils/components/document-tile.dart';
import 'package:dataextractor_analyzer/utils/media_query_util.dart';
import 'package:dataextractor_analyzer/view/home.dart';
import 'package:provider/provider.dart';
import 'package:dataextractor_analyzer/view-model/edit-text-view-model.dart';

import '../db_helper/database_helper.dart';

class ExtractionResult extends StatefulWidget {
  final String initialValue;
  ExtractionResult({super.key, required this.initialValue});

  @override
  State<ExtractionResult> createState() => _ExtractionResultState();
}

class _ExtractionResultState extends State<ExtractionResult> {
  TextEditingController _textController = TextEditingController();
  double _fontSize = 12.0;
  bool _isBold = false;
  bool _isItalic = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialValue;
  }

  Future<pw.Font> loadRobotoFont() async {
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    return pw.Font.ttf(fontData);
  }
  Future<pw.Font> loadRobotoBoldFont() async {
    final fontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    return pw.Font.ttf(fontData);
  }

  Future<void> _generateAndSavePDF(String longText) async {
    try {
      var status = await Permission.storage.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      final pdf = pw.Document();
      final robotoFont = await loadRobotoFont();
      final robotoFontBold = await loadRobotoFont();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              pw.Text(
                "Generated PDF",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: robotoFont,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Paragraph(
            text: longText,
            style: pw.TextStyle(
            font: _isBold ? robotoFontBold : robotoFont,
            fontSize: _fontSize,
            ),
            )
            ];
          },
        ),
      );
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final pdfPath = "${directory.path}/data_extracted_$timestamp.pdf";
      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());
      await DatabaseHelper.instance.insertPDF(pdfPath);
      await DatabaseHelper.instance.getPDFs();
      Utils().showSuccessFlushbar(context, pdfPath);

    } catch (e) {
      debugPrint(e.toString());
      Flushbar(
        message: "Error generating PDF: $e",
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red.shade700,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        onLeadingPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        },
      ),
      body: Consumer<EditTextViewModel>(builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Extraction Results",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Font Size Selector with Label
                  Row(
                    children: [
                      Icon(Icons.text_fields, color: Colors.black54),
                      const SizedBox(width: 8),
                      DropdownButton<double>(
                        value: _fontSize,
                        dropdownColor: Colors.white,
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        underline: Container(),
                        items: [12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0]
                            .map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text(
                              size.toString(),
                              style: TextStyle(
                                  fontSize: size, fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  // Font Style Buttons with Elevated Look
                  Row(
                    children: [
                      _buildStyledIconButton(Icons.format_bold, _isBold, () {
                        setState(() {
                          _isBold = !_isBold;
                        });
                      }),
                      const SizedBox(width: 10),
                      _buildStyledIconButton(Icons.format_italic, _isItalic,
                          () {
                        setState(() {
                          _isItalic = !_isItalic;
                        });
                      }),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Text Field
              TextFormField(
                controller: _textController,
                maxLines: 8,
                readOnly: value.readOnly,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                  color: Colors.black,
                  fontFamily: GoogleFonts.roboto().fontFamily,
                ),
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 10),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                      text: "Edit",
                      onPressed: () {
                        value.setReadOnly(false);
                      }),
                  const SizedBox(width: 5),
                  CustomButton(
                      text: "Export",
                      onPressed: () {
                        showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          context: context,
                          builder: (BuildContext modalContext) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Makes height depend on content
                                children: [
                                  DocumentTile(
                                    icon: Icons.picture_as_pdf,
                                    color: AppColors.redColor,
                                    text: "PDF Document",
                                    onPress: () {
                                      Navigator.pop(modalContext);
                                      if (_textController.text.isNotEmpty) {
                                        _generateAndSavePDF(_textController.text);
                                      } else {
                                        debugPrint("Text is empty!");
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                      }),
                ],
              ),

              const Spacer(),

            ],
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
                text: "Back",
                onPressed: () {
                  Navigator.pop(context);
                }),
            const SizedBox(width: 15),
            CustomButton(text: "Save", onPressed: () {
              showModalBottomSheet(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                context: context,
                builder: (BuildContext modalContext) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Center(
                      child: DocumentTile(
                        icon: Icons.picture_as_pdf,
                        color: AppColors.redColor,
                        text: "PDF Document",
                        onPress: () {
                          if (_textController.text.isNotEmpty) {
                            _generateAndSavePDF(_textController.text);
                          } else {
                            debugPrint("Text is empty!");
                          }
                        },
                      ),
                    ),
                  );
                },
              );

            }),
          ],
        ),
      ),
    );
  }
}

Widget _buildStyledIconButton(
    IconData icon, bool isActive, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: isActive ? Colors.blue : Colors.grey.shade300),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Icon(icon, color: isActive ? Colors.blue : Colors.black),
    ),
  );
}
