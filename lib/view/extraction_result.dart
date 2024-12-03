import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/cutom_button.dart';
import 'package:dataextractor_analyzer/view/home.dart';
import 'package:flutter/material.dart';

class ExtractionResult extends StatefulWidget {
  const ExtractionResult({super.key});

  @override
  State<ExtractionResult> createState() => _ExtractionResultState();
}

class _ExtractionResultState extends State<ExtractionResult> {

  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool readOnly = true;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(onLeadingPressed: (){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false, // Predicate: Remove all previous routes
        );

      },),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Extraction Results",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),

            Text("Text", style: Theme.of(context).textTheme.headlineMedium,),
            TextFormField(
              // controller: _textController,
              initialValue: "This is a multi-line TextFormField. It is non-editable, has a background color, and scrolls if the text goes beyond 5–6 lines.",
              maxLines: 8, 
              readOnly: readOnly,
              decoration: InputDecoration(
                filled: true, // Enables background color
                fillColor: Colors.grey[200], // Background color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  borderSide: BorderSide(
                    color: Colors.grey, // Border color
                    width: 1.0, // Border width
                  ),
                ),
                contentPadding: EdgeInsets.all(12), // Padding inside the field
              ),
              style: TextStyle(fontSize: 16, color: Colors.black), // Text styling
              keyboardType: TextInputType.multiline, // Multi-line text input
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(text: "Edit", onPressed: (){
                  setState(() {
                    readOnly = false;
                  });
                }),
                SizedBox(width: 5,),
                CustomButton(text: "Export", onPressed: (){}),
              ],
            ),
            Spacer(),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               CustomButton(text: "Back", onPressed: (){
                 Navigator.pop(context);
               }),
               SizedBox(width: 15,),
               CustomButton(text: "Save", onPressed: (){}),
             ],
           ),
            SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }
}
