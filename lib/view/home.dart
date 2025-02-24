import 'dart:io';
import 'dart:typed_data';

import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/home_buttons.dart';
import 'package:dataextractor_analyzer/view/type_of_extraction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int itemCount = 10; // Total number of grid items
  final int crossAxisCount = 2; // Number of items per row
  final double itemHeight = 120; // Fixed height of each grid item
  final double spacing = 4; // Spacing between grid items
  File? _imageFile;
  int? _imageWidth;
  int? _imageHeight;
  final List<String> imageUrls = [
    'https://via.placeholder.com/150',
    'https://via.placeholder.com/150/0000FF',
    'https://via.placeholder.com/150/FF0000',
    'https://via.placeholder.com/150/00FF00',
    'https://via.placeholder.com/150/FFFF00',
    'https://via.placeholder.com/150/FF00FF',
    'https://via.placeholder.com/150/00FFFF',
    'https://via.placeholder.com/150/CCCCCC',
  ];

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 26
    );

    if(pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(Uint8List.fromList(bytes));

      setState(() {
        _imageFile = file;
        _imageWidth = image?.width;
        _imageHeight = image?.height;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic height to fit the screen
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = kToolbarHeight;
    final double paddingHeight = 20 + 20 + 10 + 30; // Total padding and spacing
    final double containerHeight = screenHeight - appBarHeight - paddingHeight;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar:  const CustomAppBar(action: true,),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Data Extractor & Analyzer",
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: (){
                    pickImage(ImageSource.camera).then((val) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>const TypeOfExtraction()));
                    });
                  },
                  child: _buildHomeButton(
                    context,
                    icon: Icons.camera_enhance_rounded,
                    label: "Capture Image",
                  ),
                ),
                _buildHomeButton(
                  context,
                  icon: Icons.cloud_upload_rounded,
                  label: "Upload Image",
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 5),
                Text(
                  "Recent Files",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Container to display the grid
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width,
                height: containerHeight, // Dynamically calculated height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1,),
                ),
                child: GridView.builder(
                  // physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrls[index % imageUrls.length],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
  // Helper method to build reusable Home Button widgets
  Widget _buildHomeButton(BuildContext context,
      {required IconData icon, required String label}) {
    return Column(
      children: [
        HomeButtons(
          icon: icon,
          iconName: label,
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ],
    );
  }
}
