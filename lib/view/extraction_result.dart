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
  FocusNode _focusNode = FocusNode();

  // Text formatting properties
  double _fontSize = 16.0;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  Color _textColor = Colors.black;
  TextAlign _textAlign = TextAlign.left;
  String _fontFamily = 'Roboto';

  // Editor state
  int _currentLineCount = 1;
  bool _showFormatting = true;
  String pdfName = 'data_extraction_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';

  // Available fonts
  final List<String> _availableFonts = [
    'Roboto',
    'Times New Roman',
    'Arial',
    'Courier New',
    'Georgia',
    'Verdana'
  ];

  // Available colors
  final List<Color> _availableColors = [
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.brown,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialValue;
    _textController.addListener(_updateLineCount);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateLineCount);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateLineCount() {
    final text = _textController.text;
    final lineCount = '\n'.allMatches(text).length + 1;
    if (_currentLineCount != lineCount) {
      setState(() {
        _currentLineCount = lineCount;
      });
    }
  }

  Future<pw.Font> loadRobotoFont() async {
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    return pw.Font.ttf(fontData);
  }

  Future<pw.Font> loadRobotoBoldFont() async {
    final fontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    return pw.Font.ttf(fontData);
  }

  Future<String?> showPDFNameDialog(BuildContext context) async {
    TextEditingController _controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter PDF Name'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'e.g. MyDocument',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String inputName = _controller.text.trim();
                if (inputName.isNotEmpty) {
                  Navigator.of(context).pop(inputName);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndSavePDF(String longText) async {
    final name = await showPDFNameDialog(context);
    if (name != null) {
      setState(() {
        pdfName = name;
      });
      await generatePDF(longText);
    }
  }

  Future<void> generatePDF(String longText) async {
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
      final robotoFontBold = await loadRobotoBoldFont();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
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

      final pdfPath = "${directory.path}/data_extraction_${pdfName}.pdf";
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

  void _insertText(String text) {
    final currentPosition = _textController.selection.start;
    if (currentPosition < 0) return;

    final currentText = _textController.text;
    final newText = currentText.substring(0, currentPosition) +
        text +
        currentText.substring(currentPosition);

    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
      offset: currentPosition + text.length,
    );
  }

  void _formatSelection() {
    setState(() {});
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
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Text(
                "Rich Text Editor",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),

            // Formatting Toolbar
            if (_showFormatting) _buildFormattingToolbar(),

            // Main Editor Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Ruler/Info Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lines: $_currentLineCount | Words: ${_textController.text.split(' ').where((word) => word.isNotEmpty).length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _showFormatting ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showFormatting = !_showFormatting;
                                });
                              },
                              tooltip: _showFormatting ? 'Hide Formatting' : 'Show Formatting',
                            ),
                          ],
                        ),
                      ),

                      // Text Editor
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          maxLines: null,
                          expands: true,
                          readOnly: value.readOnly,
                          textAlign: _textAlign,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            hintText: 'Start typing your document...',
                          ),
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                            fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                            decoration: _isUnderlined ? TextDecoration.underline : TextDecoration.none,
                            color: _textColor,
                            fontFamily: _fontFamily == 'Times New Roman' ? 'serif' :
                            _fontFamily == 'Courier New' ? 'monospace' :
                            GoogleFonts.roboto().fontFamily,
                            height: 1.5,
                          ),
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomButton(
                        text: value.readOnly ? "Edit" : "Done",
                        onPressed: () {
                          value.setReadOnly(!value.readOnly);
                          if (!value.readOnly) {
                            // Small delay to ensure state is updated
                            Future.delayed(Duration(milliseconds: 100), () {
                              if (mounted) {
                                _focusNode.requestFocus();
                              }
                            });
                          } else {
                            _focusNode.unfocus();
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      CustomButton(
                        text: "Export",
                        onPressed: () => _showExportOptions(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomButton(
                        text: "Back",
                        onPressed: () => Navigator.pop(context),
                      ),


                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // First Row - Font and Size
          Row(
            children: [
              // Font Family Dropdown
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<String>(
                    value: _fontFamily,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _availableFonts.map((font) {
                      return DropdownMenuItem(
                        value: font,
                        child: Text(font, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _fontFamily = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Font Size
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButton<double>(
                  value: _fontSize,
                  underline: const SizedBox(),
                  items: [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 32.0, 36.0]
                      .map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text(size.toInt().toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _fontSize = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Second Row - Formatting Options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Text Style Buttons
                _buildStyledIconButton(Icons.format_bold, _isBold, () {
                  setState(() {
                    _isBold = !_isBold;
                  });
                }),
                const SizedBox(width: 8),
                _buildStyledIconButton(Icons.format_italic, _isItalic, () {
                  setState(() {
                    _isItalic = !_isItalic;
                  });
                }),
                const SizedBox(width: 8),
                _buildStyledIconButton(Icons.format_underlined, _isUnderlined, () {
                  setState(() {
                    _isUnderlined = !_isUnderlined;
                  });
                }),
                const SizedBox(width: 15),

                // Alignment Buttons
                _buildStyledIconButton(Icons.format_align_left, _textAlign == TextAlign.left, () {
                  setState(() {
                    _textAlign = TextAlign.left;
                  });
                }),
                const SizedBox(width: 8),
                _buildStyledIconButton(Icons.format_align_center, _textAlign == TextAlign.center, () {
                  setState(() {
                    _textAlign = TextAlign.center;
                  });
                }),
                const SizedBox(width: 8),
                _buildStyledIconButton(Icons.format_align_right, _textAlign == TextAlign.right, () {
                  setState(() {
                    _textAlign = TextAlign.right;
                  });
                }),
                const SizedBox(width: 8),
                _buildStyledIconButton(Icons.format_align_justify, _textAlign == TextAlign.justify, () {
                  setState(() {
                    _textAlign = TextAlign.justify;
                  });
                }),
                const SizedBox(width: 15),

                // Color Picker
                GestureDetector(
                  onTap: () => _showColorPicker(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.format_color_text, color: _textColor),
                        const SizedBox(width: 4),
                        Container(
                          width: 20,
                          height: 4,
                          color: _textColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Third Row - Additional Tools
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToolButton(Icons.format_list_bulleted, "Bullet List", () {
                  _insertText("• ");
                }),
                const SizedBox(width: 8),
                _buildToolButton(Icons.format_list_numbered, "Numbered List", () {
                  _insertText("1. ");
                }),
                const SizedBox(width: 8),
                _buildToolButton(Icons.format_indent_increase, "Indent", () {
                  _insertText("    ");
                }),
                const SizedBox(width: 8),
                _buildToolButton(Icons.format_quote, "Quote", () {
                  _insertText('"');
                }),
                const SizedBox(width: 15),
                _buildToolButton(Icons.undo, "Undo", () {
                  // Implement undo functionality if needed
                }),
                const SizedBox(width: 8),
                _buildToolButton(Icons.redo, "Redo", () {
                  // Implement redo functionality if needed
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledIconButton(IconData icon, bool isActive, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? Colors.blue : Colors.grey.shade300),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.blue : Colors.black54,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(icon, color: Colors.black54, size: 20),
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Text Color'),
          content: SizedBox(
            width: 200,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _availableColors.length,
              itemBuilder: (context, index) {
                final color = _availableColors[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _textColor = color;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _textColor == color ? Colors.grey : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      context: context,
      builder: (BuildContext modalContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
  }

  void _showSaveOptions() {
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
                Navigator.pop(modalContext);
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
  }
}