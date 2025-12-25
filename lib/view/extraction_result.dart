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
  ScrollController _scrollController = ScrollController();

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
  int _currentWordCount = 0;
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
    _textController.addListener(_updateTextStats);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateTextStats);
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // Keep toolbar visible when editing
    if (_focusNode.hasFocus && !_showFormatting) {
      setState(() {
        _showFormatting = true;
      });
    }
  }

  void _updateTextStats() {
    final text = _textController.text;
    final lineCount = '\n'.allMatches(text).length + 1;
    final wordCount = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

    if (_currentLineCount != lineCount || _currentWordCount != wordCount) {
      setState(() {
        _currentLineCount = lineCount;
        _currentWordCount = wordCount;
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
            autofocus: true,
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a name')),
                  );
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
      // Improved permission handling for Android:
      // - On Android 11+ writing to Download directly requires MANAGE_EXTERNAL_STORAGE
      // - Fall back to legacy STORAGE permission for older Android versions
      if (Platform.isAndroid) {
        // First try requesting managed external storage (Android 11+)
        PermissionStatus manageStatus = await Permission.manageExternalStorage.status;
        if (!manageStatus.isGranted) {
          manageStatus = await Permission.manageExternalStorage.request();
        }

        // Also request legacy storage permission as a fallback
        PermissionStatus storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          storageStatus = await Permission.storage.request();
        }

        // If neither permission is granted, handle denial cases
        if (!(manageStatus.isGranted || storageStatus.isGranted)) {
          // If permanently denied, prompt to open app settings
          if (manageStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
            // Show a dialog explaining the need for permission and offering to open settings
            final openSettings = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Storage Permission Required'),
                content: const Text(
                  'To save PDF files to the Downloads folder the app needs storage access.\n\n'
                  'Please grant storage permission in app settings.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );

            if (openSettings == true) {
              // This opens the OS app settings page for this app
              openAppSettings();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission is required to save PDF.')),
            );
            return;
          }

          // If just denied (not permanently), notify the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
          return;
        }
      } else {
        // On non-Android platforms, storage permission is generally not needed
        // (iOS handles file saving via app document dirs). Continue.
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
        // If downloads dir is not writable (permission issues), fallback to app documents
        try {
          if (!(await directory.exists())) {
            // Create directory reference doesn't exist; fallback
            directory = await getApplicationDocumentsDirectory();
          } else {
            // Try writing a small temp file to check writability
            final testFile = File('${directory.path}/.permission_test');
            try {
              await testFile.writeAsString('test');
              await testFile.delete();
            } catch (e) {
              // Can't write to downloads - fallback
              directory = await getApplicationDocumentsDirectory();
            }
          }
        } catch (e) {
          directory = await getApplicationDocumentsDirectory();
        }
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
    if (currentPosition < 0) {
      // If no cursor position, append to end
      _textController.text = _textController.text + text;
      _textController.selection = TextSelection.collapsed(
        offset: _textController.text.length,
      );
      return;
    }

    final currentText = _textController.text;
    final newText = currentText.substring(0, currentPosition) +
        text +
        currentText.substring(currentPosition);

    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
      offset: currentPosition + text.length,
    );

    // Keep focus on text field
    _focusNode.requestFocus();
  }

  void _clearAllFormatting() {
    setState(() {
      _fontSize = 16.0;
      _isBold = false;
      _isItalic = false;
      _isUnderlined = false;
      _textColor = Colors.black;
      _textAlign = TextAlign.left;
      _fontFamily = 'Roboto';
    });
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Text Editor",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  // Quick Stats Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.text_fields, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Text(
                          '$_currentWordCount words',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Formatting Toolbar - Compact and Always Visible When Editing
            if (_showFormatting) _buildFormattingToolbar(),

            // Main Editor Area with Better Scrolling
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _focusNode.hasFocus ? Colors.blue.shade300 : Colors.grey.shade300,
                      width: _focusNode.hasFocus ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _focusNode.hasFocus
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Info Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.edit_note, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lines: $_currentLineCount • Words: $_currentWordCount • Chars: ${_textController.text.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!value.readOnly)
                                  Tooltip(
                                    message: 'Clear Formatting',
                                    child: InkWell(
                                      onTap: _clearAllFormatting,
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.format_clear,
                                          size: 18,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showFormatting = !_showFormatting;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      _showFormatting ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Text Editor with Proper Scrolling
                      Expanded(
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          radius: const Radius.circular(4),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(20),
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              maxLines: null,
                              readOnly: value.readOnly,
                              textAlign: _textAlign,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Start typing your document...',
                                hintStyle: TextStyle(color: Colors.grey),
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
                                height: 1.6,
                              ),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildActionButton(
                        icon: value.readOnly ? Icons.edit : Icons.check,
                        label: value.readOnly ? "Edit" : "Done",
                        color: value.readOnly ? Colors.blue : Colors.green,
                        onPressed: () {
                          value.setReadOnly(!value.readOnly);
                          if (!value.readOnly) {
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
                      _buildActionButton(
                        icon: Icons.file_download,
                        label: "Export",
                        color: Colors.orange,
                        onPressed: () => _showExportOptions(),
                      ),
                    ],
                  ),
                  _buildActionButton(
                    icon: Icons.arrow_back,
                    label: "Back",
                    color: Colors.grey,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // First Row - Font Controls
          Row(
            children: [
              // Font Family
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _fontFamily,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                    items: _availableFonts.map((font) {
                      return DropdownMenuItem(
                        value: font,
                        child: Text(
                          font,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _fontFamily = value;
                        });
                        _focusNode.requestFocus();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Font Size
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.format_size, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 4),
                    DropdownButton<double>(
                      value: _fontSize,
                      underline: const SizedBox(),
                      items: [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 28.0, 32.0, 36.0]
                          .map((size) {
                        return DropdownMenuItem(
                          value: size,
                          child: Text(
                            size.toInt().toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _fontSize = value;
                          });
                          _focusNode.requestFocus();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 12),

          // Second Row - Text Formatting
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Style Buttons
                _buildFormatButton(
                  icon: Icons.format_bold,
                  isActive: _isBold,
                  tooltip: 'Bold',
                  onTap: () {
                    setState(() => _isBold = !_isBold);
                    _focusNode.requestFocus();
                  },
                ),
                const SizedBox(width: 6),
                _buildFormatButton(
                  icon: Icons.format_italic,
                  isActive: _isItalic,
                  tooltip: 'Italic',
                  onTap: () {
                    setState(() => _isItalic = !_isItalic);
                    _focusNode.requestFocus();
                  },
                ),
                const SizedBox(width: 6),
                _buildFormatButton(
                  icon: Icons.format_underlined,
                  isActive: _isUnderlined,
                  tooltip: 'Underline',
                  onTap: () {
                    setState(() => _isUnderlined = !_isUnderlined);
                    _focusNode.requestFocus();
                  },
                ),

                const SizedBox(width: 12),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                const SizedBox(width: 12),

                // Alignment Buttons
                _buildFormatButton(
                  icon: Icons.format_align_left,
                  isActive: _textAlign == TextAlign.left,
                  tooltip: 'Align Left',
                  onTap: () {
                    setState(() => _textAlign = TextAlign.left);
                    _focusNode.requestFocus();
                  },
                ),
                const SizedBox(width: 6),
                _buildFormatButton(
                  icon: Icons.format_align_center,
                  isActive: _textAlign == TextAlign.center,
                  tooltip: 'Align Center',
                  onTap: () {
                    setState(() => _textAlign = TextAlign.center);
                    _focusNode.requestFocus();
                  },
                ),
                const SizedBox(width: 6),
                _buildFormatButton(
                  icon: Icons.format_align_right,
                  isActive: _textAlign == TextAlign.right,
                  tooltip: 'Align Right',
                  onTap: () {
                    setState(() => _textAlign = TextAlign.right);
                    _focusNode.requestFocus();
                  },
                ),
                const SizedBox(width: 6),
                _buildFormatButton(
                  icon: Icons.format_align_justify,
                  isActive: _textAlign == TextAlign.justify,
                  tooltip: 'Justify',
                  onTap: () {
                    setState(() => _textAlign = TextAlign.justify);
                    _focusNode.requestFocus();
                  },
                ),

                const SizedBox(width: 12),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                const SizedBox(width: 12),

                // Color Picker
                _buildColorButton(),

                const SizedBox(width: 12),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                const SizedBox(width: 12),

                // List & Insert Tools
                _buildFormatButton(
                  icon: Icons.format_list_bulleted,
                  tooltip: 'Bullet Point',
                  onTap: () => _insertText('• '),
                ),
                const SizedBox(width: 6),
                _buildFormatButton(
                  icon: Icons.format_list_numbered,
                  tooltip: 'Numbered List',
                  onTap: () {
                    final lines = _textController.text.split('\n').length;
                    _insertText('${lines}. ');
                  },
                ),
                const SizedBox(width: 6),
                _buildFormatButton(
                  icon: Icons.format_indent_increase,
                  tooltip: 'Indent',
                  onTap: () => _insertText('    '),
                ),
                const SizedBox(width: 6),
                _buildFormatButton(
                  icon: Icons.format_quote,
                  tooltip: 'Quote',
                  onTap: () => _insertText('" "'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    bool isActive = false,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.shade500 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? Colors.blue.shade700 : Colors.grey.shade300,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey.shade700,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton() {
    return Tooltip(
      message: 'Text Color',
      child: GestureDetector(
        onTap: _showColorPicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.palette, color: _textColor, size: 20),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _textColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade400),
                ),
              ),
            ],
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
          title: Row(
            children: [
              Icon(Icons.palette, color: Colors.blue),
              const SizedBox(width: 10),
              Text('Choose Text Color'),
            ],
          ),
          content: SizedBox(
            width: 250,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _availableColors.length,
              itemBuilder: (context, index) {
                final color = _availableColors[index];
                final isSelected = _textColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _textColor = color;
                    });
                    Navigator.pop(context);
                    _focusNode.requestFocus();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _focusNode.requestFocus();
              },
              child: Text('Close'),
            ),
          ],
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

