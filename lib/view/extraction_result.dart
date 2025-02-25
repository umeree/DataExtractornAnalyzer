import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/cutom_button.dart';
import 'package:dataextractor_analyzer/utils/components/document-tile.dart';
import 'package:dataextractor_analyzer/utils/media_query_util.dart';
import 'package:dataextractor_analyzer/view-model/edit-text-view-model.dart';
import 'package:dataextractor_analyzer/view/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExtractionResult extends StatefulWidget {
  String initialValue;
  ExtractionResult({super.key, required this.initialValue});

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
      appBar: CustomAppBar(
        onLeadingPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false, // Predicate: Remove all previous routes
          );
        },
      ),
      body: Consumer<EditTextViewModel>(builder: (context, value, child) {
        return Padding(
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
              Text(
                "Text",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextFormField(
                // controller: _textController,
                initialValue: widget.initialValue,
                maxLines: 8,
                readOnly: value.readOnly,
                decoration: InputDecoration(
                  filled: true, // Enables background color
                  fillColor: Colors.grey[200], // Background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    borderSide: const BorderSide(
                      color: Colors.grey, // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.all(12), // Padding inside the field
                ),
                style: TextStyle(
                    fontSize: 16, color: Colors.black), // Text styling
                keyboardType: TextInputType.multiline, // Multi-line text input
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                      text: "Edit",
                      onPressed: () {
                        value.setReadOnly(false);
                      }),
                  SizedBox(
                    width: 5,
                  ),
                  CustomButton(
                      text: "Export",
                      onPressed: () {
                        showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                height:
                                    MediaQueryUtil.screenHeight(context) * 0.35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(2),
                                        topRight: Radius.circular(2))),
                                child: Center(
                                  child: ListView.builder(
                                      itemCount: 4,
                                      itemBuilder: (context, value) {
                                        return DocumentTile(
                                          icon: Icons.book_online_rounded,
                                          text: "Excel Document",
                                        );
                                      }),
                                ),
                              );
                            });
                      }),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      text: "Back",
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  SizedBox(
                    width: 15,
                  ),
                  CustomButton(text: "Save", onPressed: () {}),
                ],
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        );
      }),
    );
  }
}
