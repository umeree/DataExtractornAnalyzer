import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/cutom_button.dart';
import 'package:dataextractor_analyzer/utils/media_query_util.dart';
import 'package:dataextractor_analyzer/view/extraction_result.dart';
import 'package:dataextractor_analyzer/view/home.dart';
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
      appBar: CustomAppBar(onLeadingPressed: (){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
              child: Image.network(
                "https://via.placeholder.com/150/FF0000",
                fit: BoxFit.cover, // Image scaling to cover the container
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
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(text: "Analyze", onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExtractionResult()));
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
    }) {
  return Padding(
    padding: const EdgeInsets.only(top: 3, bottom: 3),
    child: Container(
      padding: EdgeInsets.all(5),
      width: MediaQueryUtil.widthPercentage(context, 0.85),
      height: 80,
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    ),
  );
}
