import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';

/// Service for uploading images to Backblaze B2
class B2StorageService {
  // B2 Credentials - KEEP THESE SECRET!
  static const String _keyId = '0053326914a81470000000002';
  static const String _applicationKey = 'K005i9a4FCdCYOQ4XxTAgXSw3C81+S0';
  
  // Will be set after getting bucket info
  String? _bucketId;
  String? _bucketName;
  String? _authToken;
  String? _apiUrl;
  String? _downloadUrl;
  String? _downloadAuthToken;
  DateTime? _tokenExpiry;

  /// Initialize B2 connection and get auth token
  Future<void> initialize({required String bucketName}) async {
    try {
      _bucketName = bucketName;
      
      // Step 1: Authorize account
      final authResponse = await http.get(
        Uri.parse('https://api.backblazeb2.com/b2api/v2/b2_authorize_account'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_keyId:$_applicationKey'))}',
        },
      );

      if (authResponse.statusCode != 200) {
        throw Exception('B2 Authorization failed: ${authResponse.body}');
      }

      final authData = json.decode(authResponse.body);
      _authToken = authData['authorizationToken'];
      _apiUrl = authData['apiUrl'];
      _downloadUrl = authData['downloadUrl'];

      debugPrint('B2 authorized successfully');

      // Step 2: Get bucket ID
      final bucketsResponse = await http.post(
        Uri.parse('$_apiUrl/b2api/v2/b2_list_buckets'),
        headers: {
          'Authorization': _authToken!,
        },
        body: json.encode({
          'accountId': authData['accountId'],
          'bucketName': bucketName,
        }),
      );

      if (bucketsResponse.statusCode != 200) {
        throw Exception('Failed to get bucket: ${bucketsResponse.body}');
      }

      final bucketsData = json.decode(bucketsResponse.body);
      if (bucketsData['buckets'].isEmpty) {
        throw Exception('Bucket "$bucketName" not found');
      }

      _bucketId = bucketsData['buckets'][0]['bucketId'];
      debugPrint('Bucket ID: $_bucketId');
    } catch (e) {
      debugPrint('B2 initialization error: $e');
      rethrow;
    }
  }

  /// Upload image to B2
  Future<String> uploadImage({
    File? imageFile,
    XFile? imageFileWeb,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      // Ensure initialized
      if (_authToken == null || _bucketId == null) {
        throw Exception('B2 not initialized. Call initialize() first.');
      }

      debugPrint('Starting B2 upload: $fileName');

      // Get upload URL
      final uploadUrlResponse = await http.post(
        Uri.parse('$_apiUrl/b2api/v2/b2_get_upload_url'),
        headers: {
          'Authorization': _authToken!,
        },
        body: json.encode({
          'bucketId': _bucketId,
        }),
      );

      if (uploadUrlResponse.statusCode != 200) {
        throw Exception('Failed to get upload URL: ${uploadUrlResponse.body}');
      }

      final uploadData = json.decode(uploadUrlResponse.body);
      final uploadUrl = uploadData['uploadUrl'];
      final uploadAuthToken = uploadData['authorizationToken'];

      // Read file bytes
      Uint8List bytes;
      if (kIsWeb && imageFileWeb != null) {
        bytes = await imageFileWeb.readAsBytes();
      } else if (imageFile != null) {
        bytes = await imageFile.readAsBytes();
      } else {
        throw Exception('No image file provided');
      }

      debugPrint('File size: ${bytes.length} bytes');

      // Calculate SHA1 hash
      final sha1Hash = sha1.convert(bytes).toString();

      // Upload file
      final uploadResponse = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          'Authorization': uploadAuthToken,
          'X-Bz-File-Name': Uri.encodeComponent(fileName),
          'Content-Type': 'image/jpeg',
          'Content-Length': bytes.length.toString(),
          'X-Bz-Content-Sha1': sha1Hash,
        },
        body: bytes,
      );

      if (uploadResponse.statusCode != 200) {
        throw Exception('Upload failed: ${uploadResponse.body}');
      }

      final uploadResult = json.decode(uploadResponse.body);
      final fileId = uploadResult['fileId'];

      // Construct public URL
      final publicUrl = '$_downloadUrl/file/$_bucketName/$fileName';

      debugPrint('Upload successful: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('B2 upload error: $e');
      rethrow;
    }
  }

  /// Delete image from B2
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file name from URL
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;

      // Get file info
      final fileInfoResponse = await http.post(
        Uri.parse('$_apiUrl/b2api/v2/b2_list_file_names'),
        headers: {
          'Authorization': _authToken!,
        },
        body: json.encode({
          'bucketId': _bucketId,
          'startFileName': fileName,
          'maxFileCount': 1,
        }),
      );

      if (fileInfoResponse.statusCode != 200) {
        throw Exception('Failed to get file info: ${fileInfoResponse.body}');
      }

      final fileData = json.decode(fileInfoResponse.body);
      if (fileData['files'].isEmpty) {
        throw Exception('File not found');
      }

      final fileId = fileData['files'][0]['fileId'];
      final fileNameFromList = fileData['files'][0]['fileName'];

      // Delete file
      final deleteResponse = await http.post(
        Uri.parse('$_apiUrl/b2api/v2/b2_delete_file_version'),
        headers: {
          'Authorization': _authToken!,
        },
        body: json.encode({
          'fileId': fileId,
          'fileName': fileNameFromList,
        }),
      );

      if (deleteResponse.statusCode != 200) {
        throw Exception('Delete failed: ${deleteResponse.body}');
      }

      debugPrint('File deleted successfully');
    } catch (e) {
      debugPrint('B2 delete error: $e');
      rethrow;
    }
  }

  /// Appends download authorization token to a public URL for accessing private bucket
  Future<String> authorizeUrl(String fullUrl) async {
    if (fullUrl.contains('?Authorization=')) return fullUrl;

    try {
      if (_downloadAuthToken == null || _tokenExpiry == null || DateTime.now().isAfter(_tokenExpiry!)) {
        final response = await http.post(
          Uri.parse('$_apiUrl/b2api/v2/b2_get_download_authorization'),
          headers: {
            'Authorization': _authToken!,
          },
          body: json.encode({
            'bucketId': _bucketId,
            'fileNamePrefix': '',
            'validDurationInSeconds': 604800, // 7 days
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _downloadAuthToken = data['authorizationToken'];
          _tokenExpiry = DateTime.now().add(const Duration(days: 7));
        } else {
          debugPrint('Failed to get B2 download auth: ${response.body}');
          return fullUrl;
        }
      }
      return '$fullUrl?Authorization=$_downloadAuthToken';
    } catch (e) {
      debugPrint('Error authorizing B2 url: $e');
      return fullUrl;
    }
  }
}
