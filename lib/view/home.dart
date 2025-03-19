import 'dart:io';
import 'dart:typed_data';

import 'package:dataextractor_analyzer/db_helper/database_helper.dart';
import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/utils/components/custom_app_bar.dart';
import 'package:dataextractor_analyzer/utils/components/home_buttons.dart';
import 'package:dataextractor_analyzer/view/settings.dart';
import 'package:dataextractor_analyzer/view/type_of_extraction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_cropper/image_cropper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int crossAxisCount = 2;
  final double itemHeight = 120;
  final double spacing = 4;
  File? _imageFile;
  int? _imageWidth;
  int? _imageHeight;

  List<String> _imagesPaths = [];


  Future<void> pickImage(ImageSource source) async {
    var status = await Permission.mediaLibrary.status;
    debugPrint("Status of media library permission is $status");
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 26);

      if (pickedFile != null) {
        final CroppedFile? croppedFile = await cropImage(pickedFile.path);
        if (croppedFile == null) {
          debugPrint("Cropping was cancelled or failed.");
          return;
        }

        final File finalImage = File(croppedFile.path);
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = pickedFile.name;
        final File localImage =
        await finalImage.copy('${appDir.path}/$fileName');

        await DatabaseHelper.instance.insertImage(localImage.path);
        final images = await DatabaseHelper.instance.getImages();

        setState(() {
          _imageFile = finalImage;
          _imagesPaths = images;
        });

        // Navigate to TypeOfExtraction after cropping
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TypeOfExtraction(imageFile: _imageFile!),
          ),
        );
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
  Future<CroppedFile?> cropImage(String sourcePath) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Image',
            toolbarColor: AppColors.primaryColor, // Customize toolbar color
            toolbarWidgetColor: Colors.white, // Customize text/icon color
            backgroundColor: Colors.black, // Set background color
            activeControlsWidgetColor: AppColors.primaryColor, // Button highlight color
            statusBarColor: AppColors.primaryColor, // Status bar color
            cropFrameColor: Colors.white, // Frame color around cropped area
            cropGridColor: Colors.white, // Grid color inside the cropping frame
            showCropGrid: true, // Show cropping grid lines
            lockAspectRatio: false, // Allow free aspect ratio selection
          ),
          IOSUiSettings(
            title: 'Edit Image',
            rotateButtonsHidden: false, // Show rotation buttons
            rotateClockwiseButtonHidden: false, // Show clockwise rotation
            aspectRatioLockEnabled: false, // Allow free aspect ratio selection
            aspectRatioPickerButtonHidden: false, // Show aspect ratio picker
            resetButtonHidden: false, // Show reset button
            doneButtonTitle: 'Apply', // Custom done button text
            cancelButtonTitle: 'Cancel', // Custom cancel button text
          ),
        ],
      );
      return croppedFile;
    } catch (e) {
      debugPrint("Error cropping image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic height based on images count
    final double screenHeight = MediaQuery.of(context).size.height;
    final double minContainerHeight = 100; // Minimum height when no images
    final double maxContainerHeight = screenHeight * 0.5; // Max height for images

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        action: true,
        onSettingsPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Settings()),
          );
        },
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
                  onTap: () => pickImage(ImageSource.camera),
                  child: _buildHomeButton(
                    context,
                    icon: Icons.camera_enhance_rounded,
                    label: "Capture Image",
                  ),
                ),
                GestureDetector(
                  onTap: () => pickImage(ImageSource.gallery),
                  child: _buildHomeButton(
                    context,
                    icon: Icons.cloud_upload_rounded,
                    label: "Upload Image",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Recent Files",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),

            // Dynamically adjust height based on images count
            Container(
              padding: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width,
              height: _imagesPaths.isEmpty ? minContainerHeight : maxContainerHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1),
              ),
              child: _imagesPaths.isEmpty
                  ? const Center(
                child: Text(
                  "No Recent Files",
                  style: TextStyle(fontSize: 16, color: AppColors.greyColor),
                ),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1.5,
                ),
                itemCount: _imagesPaths.length,
                itemBuilder: (context, index) {
                  int reverseIndex = _imagesPaths.length - 1 - index;
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TypeOfExtraction(
                            imageFile: File(_imagesPaths[reverseIndex]),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_imagesPaths[reverseIndex]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
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
class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}