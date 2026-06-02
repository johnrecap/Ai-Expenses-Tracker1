import 'dart:developer' as developer;
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'ai_expense_service.dart';
import 'ai_api_service.dart';

/// {@template camera_scanner_service}
/// Service that captures receipt images and extracts structured expense data.
///
/// Uses the device's camera via `image_picker`.
/// Receipt OCR is not enabled until a real server-side OCR path exists.
/// {@endtemplate}
class CameraScannerService {
  /// Creates a [CameraScannerService].
  ///
  /// [aiExpenseService] is used to parse any text extracted from the receipt.
  /// [aiApiService] is optional; when provided, images are sent to the
  /// backend for OCR. [imagePicker] can be injected for testing.
  CameraScannerService({
    required this.aiExpenseService,
    this.aiApiService,
    ImagePicker? imagePicker,
  }) : _picker = imagePicker ?? ImagePicker();

  /// The AI expense service that turns extracted text into structured data.
  final AiExpenseService aiExpenseService;

  /// Optional AI API service for server-side receipt OCR.
  final AiApiService? aiApiService;

  final ImagePicker _picker;

  /// Captures a photo using the device camera.
  ///
  /// Returns the captured [File], or `null` if the user cancelled or the
  /// camera is unavailable.
  Future<File?> capturePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null) return null;
      return File(picked.path);
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to capture photo',
        name: 'CameraScannerService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Picks an existing image from the device gallery.
  ///
  /// Returns the selected [File], or `null` if the user cancelled.
  Future<File?> pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null) return null;
      return File(picked.path);
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to pick image from gallery',
        name: 'CameraScannerService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Scans a receipt image and returns structured expense data.
  ///
  /// Returns an empty result until receipt OCR is connected to a real service.
  ///
  /// Returns an [AiExpenseResult] containing the parsed expense, or an empty
  /// result if scanning or parsing failed.
  Future<AiExpenseResult> scanReceipt(File imageFile) async {
    try {
      developer.log(
        'Receipt OCR is not connected; returning no parsed data',
        name: 'CameraScannerService',
      );
      return AiExpenseResult.empty('');
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Receipt scan failed',
        name: 'CameraScannerService',
        error: e,
        stackTrace: stackTrace,
      );
      return AiExpenseResult.empty('');
    }
  }

  /// Convenience method that captures a photo and immediately scans it.
  Future<AiExpenseResult> captureAndScan() async {
    final image = await capturePhoto();
    if (image == null) return AiExpenseResult.empty('');
    return scanReceipt(image);
  }
}
