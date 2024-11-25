import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/media_query_util.dart';
import 'package:flutter/material.dart';

class TypeOfExtraction extends StatefulWidget {
  const TypeOfExtraction({super.key});

  @override
  State<TypeOfExtraction> createState() => _TypeOfExtractionState();
}

class _TypeOfExtractionState extends State<TypeOfExtraction> {
  String? _selectedOption = "Text Extraction"; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
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
            width: MediaQueryUtil.widthPercentage(context, 0.9),
            height: MediaQueryUtil.heightPercentage(context, 0.4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primaryColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                "https://via.placeholder.com/150/FF0000",
                fit: BoxFit.cover,
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
          ),
          _buildExtractionTile(
            context,
            titleText: "Image Analysis",
            labelText: "Analyze the content of the image.",
            radioButtonValue: "Image Analysis",
            groupValue: _selectedOption!,
            onChanged: (val) {
              setState(() {
                _selectedOption = val;
              });
            },
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
    }) {
  return Container(
    padding: EdgeInsets.all(10),
    width: MediaQueryUtil.widthPercentage(context, 0.9),
    height: 100,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(width: 1, color: AppColors.primaryColor),
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
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Radio<String>(
              value: radioButtonValue,
              groupValue: groupValue,
              onChanged: onChanged, // Pass the callback
            ),
          ],
        ),
        Text(
          labelText,
          style: TextStyle(fontSize: 12, color: AppColors.textColor),
        ),
      ],
    ),
  );
}
