import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/b2_storage_service.dart';

/// Service for handling image storage operations using Backblaze B2
class StorageService {
  final B2StorageService _b2Service = B2StorageService();
  bool _initialized = false;

  /// Initialize B2 connection
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _b2Service.initialize(bucketName: 'antam-photos');
      _initialized = true;
    }
  }

  /// Upload image to B2 Storage
  /// Returns the download URL of the uploaded image
  /// Supports both mobile (File) and web (XFile/bytes)
  Future<String> uploadImage({
    File? imageFile,
    XFile? imageFileWeb,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      await _ensureInitialized();
      
      debugPrint('Starting upload to B2: $path');
      
      // Upload to B2
      final downloadUrl = await _b2Service.uploadImage(
        imageFile: imageFile,
        imageFileWeb: imageFileWeb,
        fileName: path,
        onProgress: onProgress,
      );

      debugPrint('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      debugPrint('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Delete image from B2 Storage using URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _ensureInitialized();
      await _b2Service.deleteImage(imageUrl);
      debugPrint('Image deleted successfully: $imageUrl');
    } catch (e) {
      debugPrint('Error deleting image: $e');
      rethrow;
    }
  }

  /// Get download URL for a storage path (B2 returns URL directly on upload)
  Future<String> getDownloadUrl(String path) async {
    // For B2, the URL is constructed as: downloadUrl/file/bucketName/fileName
    return 'https://f005.backblazeb2.com/file/antam-photos/$path';
  }

  /// Authorize a B2 public URL with a download token for private access
  Future<String> authorizeUrl(String fullUrl) async {
    await _ensureInitialized();
    return await _b2Service.authorizeUrl(fullUrl);
  }
}
