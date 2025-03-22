import 'dart:io';

import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/cutom_button.dart';
import 'package:dataextractor_analyzer/utils/media_query_util.dart';
import 'package:dataextractor_analyzer/view/extraction_result.dart';
import 'package:dataextractor_analyzer/view/home.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TypeOfExtraction extends StatefulWidget {
  File imageFile;
  TypeOfExtraction({super.key, required this.imageFile});

  @override
  State<TypeOfExtraction> createState() => _TypeOfExtractionState();
}

class _TypeOfExtractionState extends State<TypeOfExtraction>  with SingleTickerProviderStateMixin{

  String? _selectedOption = "Text Extraction";
    String _extractedText = '';
    bool _isFullScreenImage = false;
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Animation controller for fade effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

    Future<void> _extractText() async {
    if (widget.imageFile == null) return;
    setState(() {
      isLoading = true;
    });
    final inputImage = InputImage.fromFile(widget.imageFile);
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      setState(() {
        _extractedText = recognizedText.text;
        setState(() {
          isLoading = false;
        });
        // Navigator.push(context, MaterialPageRoute(builder: (context) => Home(extractedText: _extractedText)));
      });
    } catch (e) {
      setState(() {
        _extractedText = 'Error: $e';
        isLoading = false;
      });
    } finally {
      textRecognizer.close();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showFullScreenImage() {
    setState(() {
      _isFullScreenImage = true;
    });
    _animationController.forward();
  }

  void _hideFullScreenImage() {
    _animationController.reverse().then((_) {
      setState(() {
        _isFullScreenImage = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onLeadingPressed: (){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false, // Predicate: Remove all previous routes
        );
      },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Center(
                child: SizedBox(
                  width: MediaQueryUtil.widthPercentage(context, 0.75),
                  child: Text(
                    "Choose Data Type for Extraction",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _showFullScreenImage,
                child: Container(
                  width: MediaQueryUtil.widthPercentage(context, 0.85),
                  height: MediaQueryUtil.heightPercentage(context, 0.35),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners for the border
                    color: AppColors.primaryColor,          // Background color for the container
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 1.0,          // Border width
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Ensures rounded corners match the container
                    child: Image.file(widget.imageFile, fit: BoxFit.cover,),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Select Extraction Type",
                style: TextStyle(color: AppColors.textColor, fontSize: 14),
              ),
              _buildExtractionTile(
                context,
                titleText: "Text Extraction",
                labelText: "It will extract all the text from your image",
                radioButtonValue: "Text Extraction",
                groupValue: _selectedOption!,
                onChanged: (val) {
                  setState(() {
                    _selectedOption = val;
                  });
                },
                isSelected: _selectedOption == 'Text Extraction',
              ),
              _buildExtractionTile(
                context,
                titleText: "Table Extraction",
                labelText: "It will extract tables from your image.",
                radioButtonValue: "Table Extraction",
                groupValue: _selectedOption!,
                onChanged: (val) {
                  setState(() {
                    _selectedOption = val;
                  });
                },
                isSelected: _selectedOption == 'Table Extraction',
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(text: "Analyze", onPressed: () async{
                    await  _extractText();
                    if (_extractedText!.isNotEmpty || _extractedText != null) {
                      print("Here is extracted text ${_extractedText}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExtractionResult(
                            initialValue: _extractedText,
                          ),
                        ),
                      );
                    } else {
                      // Show an error message if extraction failed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to extract text. Please try again.')),
                      );
                    }
                  }),
                  const SizedBox(width: 15,),
                  CustomButton(text: "Cancel", onPressed: (){
                    Navigator.pop(context);
                  }),
                ],
              ),
              const SizedBox(height: 30,)
            ],
          ),
          if(_isFullScreenImage)
            FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _hideFullScreenImage,
                child: Container(
                  color: Colors.black.withOpacity(0.9),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if(isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent background
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor,),
                  ),
                  Text("Analyzign...", style: TextStyle(color: Colors.white),)
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildExtractionTile(
    BuildContext context, {
      required String titleText,
      required String labelText,
      required String radioButtonValue,
      required String groupValue,
      required ValueChanged<String?> onChanged, // Accept nullable String
      required bool isSelected, // Add a parameter to indicate selection
    }) {
  return Padding(
    padding: const EdgeInsets.only(top: 3, bottom: 3),
    child: Container(
      padding: EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.85,
      height: 80,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 2,
          color: isSelected ? AppColors.borderColor : AppColors.primaryColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titleText,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Radio<String>(
                value: radioButtonValue,
                groupValue: groupValue,
                onChanged: onChanged, // Pass the callback
                fillColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primaryColor; // Color when selected
                    }
                    return AppColors.primaryColor.withOpacity(0.6); // Color when unselected
                  },
                ),
                overlayColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                    if (states.contains(MaterialState.hovered)) {
                      return AppColors.primaryColor.withOpacity(0.1); // Hover color
                    }
                    return Colors.transparent;
                  },
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),

            ],
          ),
          Text(
            labelText,
            style: TextStyle(fontSize: 12, color: AppColors.textColor),
          ),
        ],
      ),
    ),
  );
}







