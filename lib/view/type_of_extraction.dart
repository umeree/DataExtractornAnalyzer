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

class _TypeOfExtractionState extends State<TypeOfExtraction> {
  String? _selectedOption = "Text Extraction"; // Default value
    String _extractedText = '';


    Future<void> _extractText() async {
    if (widget.imageFile == null) return;

    final inputImage = InputImage.fromFile(widget.imageFile);
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      setState(() {
        _extractedText = recognizedText.text;
        // Navigator.push(context, MaterialPageRoute(builder: (context) => Home(extractedText: _extractedText)));
      });
    } catch (e) {
      setState(() {
        _extractedText = 'Error: $e';
      });
    } finally {
      textRecognizer.close();
    }
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
      },),
      body: Column(
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
          Container(
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
               await  _extractText().then((val) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExtractionResult(initialValue: _extractedText,)));
               });
              }),
              const SizedBox(width: 15,),
              CustomButton(text: "Cancel", onPressed: (){}),
            ],
          ),
          const SizedBox(height: 30,)
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

