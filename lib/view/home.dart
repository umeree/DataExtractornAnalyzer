import 'dart:io';
import 'dart:typed_data';

import 'package:dataextractor_analyzer/db_helper/database_helper.dart';
import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/home_buttons.dart';
import 'package:dataextractor_analyzer/view/type_of_extraction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final int itemCount = 10; // Total number of grid items
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

  List<String> _imagesPaths = [];

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 26);

      if (pickedFile != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = pickedFile.name;
        final File localImage =
            await File(pickedFile.path).copy('${appDir.path}/$fileName');
        await DatabaseHelper.instance.insertImage(localImage.path);
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(Uint8List.fromList(bytes));

        final images = await DatabaseHelper.instance.getImages();

        setState(() {
          _imageFile = file;
          _imageWidth = image?.width;
          _imageHeight = image?.height;
          _imagesPaths = images;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _loadImages() async {
    final images = await DatabaseHelper.instance.getImages();
    setState(() {
      _imagesPaths = images;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadImages();
    setState(() {
      _imageFile == null;
    });
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
      appBar: const CustomAppBar(
        action: true,
      ),
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
                  onTap: () {
                    pickImage(ImageSource.camera).then((val) {
                      if (_imageFile == null) return;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TypeOfExtraction(
                                    imageFile: _imageFile!,
                                  )));
                    });
                  },
                  child: _buildHomeButton(
                    context,
                    icon: Icons.camera_enhance_rounded,
                    label: "Capture Image",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    pickImage(ImageSource.gallery).then((val) {
                      if (_imageFile == null) return;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TypeOfExtraction(
                                    imageFile: _imageFile!,
                                  )));
                    });
                  },
                  child: _buildHomeButton(
                    context,
                    icon: Icons.cloud_upload_rounded,
                    label: "Upload Image",
                  ),
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
            _imagesPaths.length == 0 || _imagesPaths.isEmpty
                ? Center(
                    child: Text("No Recent Files"),
                  )
                : Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width,
                      height: containerHeight, // Dynamically calculated height
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                        ),
                      ),
                      child: GridView.builder(
                        // physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: _imagesPaths.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_imagesPaths[index]),
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
            SizedBox(
              height: 20,
            )
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
