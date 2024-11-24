import 'package:flutter/widgets.dart';

class MediaQueryUtil {
  // Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Get screen orientation
  static Orientation orientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  // Check if the screen is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Check if the screen is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Get a percentage of the screen width
  static double widthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  // Get a percentage of the screen height
  static double heightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }
}
