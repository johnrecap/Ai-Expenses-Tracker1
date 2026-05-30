import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'ai_expense_service.dart';
import 'ai_gateway_client.dart';

/// {@template camera_scanner_service}
/// Service that captures receipt images and extracts structured expense data.
///
/// Uses the device's camera via `image_picker` and can optionally send the
/// image to the AI gateway for OCR + parsing. Falls back to a mock flow
/// when the gateway is unavailable so the UI can still be tested.
/// {@endtemplate}
class CameraScannerService {
  /// Creates a [CameraScannerService].
  ///
  /// [aiExpenseService] is used to parse any text extracted from the receipt.
  /// [gatewayClient] is optional; when provided, images are sent to the
  /// backend for OCR. [imagePicker] can be injected for testing.
  CameraScannerService({
    required this.aiExpenseService,
    this.gatewayClient,
    ImagePicker? imagePicker,
  }) : _picker = imagePicker ?? ImagePicker();

  /// The AI expense service that turns extracted text into structured data.
  final AiExpenseService aiExpenseService;

  /// Optional AI gateway client for server-side receipt OCR.
  final AiGatewayClient? gatewayClient;

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
  /// If [gatewayClient] is available, the image is base64-encoded and sent to
  /// the AI gateway (`/aiReceipt`). Otherwise the method falls back to a
  /// local heuristic that simply passes any embedded text to
  /// [AiExpenseService.processInput].
  ///
  /// Returns an [AiExpenseResult] containing the parsed expense, or an empty
  /// result if scanning or parsing failed.
  Future<AiExpenseResult> scanReceipt(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      if (gatewayClient != null) {
        return await _scanWithGateway(bytes);
      }

      return await _scanLocally(bytes);
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

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<AiExpenseResult> _scanWithGateway(Uint8List bytes) async {
    try {
      // Encode image to base64 for transport.
      final base64Image = _bytesToBase64(bytes);

      final response = await gatewayClient!.extractReceipt(base64Image);

      // The gateway returns a JSON map with extracted fields.
      final extractedText = response['text'] as String? ?? '';
      if (extractedText.trim().isEmpty) {
        return AiExpenseResult.empty('');
      }

      return aiExpenseService.processInput(extractedText);
    } on AiGatewayException catch (e) {
      developer.log(
        'Gateway receipt extraction failed: ${e.message}',
        name: 'CameraScannerService',
        error: e,
      );
      return AiExpenseResult.empty('');
    }
  }

  Future<AiExpenseResult> _scanLocally(Uint8List bytes) async {
    // Without a local OCR engine we fall back to a mock / placeholder
    // behaviour: create a placeholder note so the user can manually fill
    // the amount and category while the image is preserved as attachment.
    developer.log(
      'No OCR engine available; returning placeholder result',
      name: 'CameraScannerService',
    );

    // Return a low-confidence result that signals the UI to show a manual
    // review form with the image attached.
    return AiExpenseResult.empty('camera_scan_placeholder');
  }

  String _bytesToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }
}
