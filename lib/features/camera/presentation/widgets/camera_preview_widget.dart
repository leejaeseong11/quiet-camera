import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key, required this.controller});
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final size = MediaQuery.of(context).size;

    // Use 3:4 aspect ratio for portrait (standard smartphone photo ratio)
    // This means height is 4/3 of width (taller than wide in portrait mode)
    const targetAspectRatio = 3.0 / 4.0; // width:height = 3:4 for portrait

    // Calculate preview dimensions
    double previewWidth = size.width;
    double previewHeight =
        size.width / targetAspectRatio; // height = width * (4/3)

    // If calculated height exceeds screen height, adjust based on height
    if (previewHeight > size.height) {
      previewHeight = size.height;
      previewWidth = size.height * targetAspectRatio; // width = height * (3/4)
    }

    return Container(
      width: size.width,
      height: size.height,
      color: Colors.black, // Black background for bars
      child: Center(
        child: SizedBox(
          width: previewWidth,
          height: previewHeight,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: previewWidth,
                  height: previewWidth / (controller.value.aspectRatio),
                  child: CameraPreview(controller),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Calculate the actual preview bounds within the screen
  /// This accounts for aspect ratio and returns the Rect where the preview is displayed
  static Rect calculatePreviewBounds({
    required Size screenSize,
    required Size previewSize,
  }) {
    // Use 3:4 aspect ratio for portrait (standard smartphone photo ratio)
    const targetAspectRatio = 3.0 / 4.0; // width:height = 3:4 for portrait

    // Calculate preview dimensions
    double previewWidth = screenSize.width;
    double previewHeight =
        screenSize.width / targetAspectRatio; // height = width * (4/3)

    // If calculated height exceeds screen height, adjust based on height
    if (previewHeight > screenSize.height) {
      previewHeight = screenSize.height;
      previewWidth =
          screenSize.height * targetAspectRatio; // width = height * (3/4)
    }

    // Calculate offset to center the preview
    final left = (screenSize.width - previewWidth) / 2;
    final top = (screenSize.height - previewHeight) / 2;

    return Rect.fromLTWH(left, top, previewWidth, previewHeight);
  }
}
