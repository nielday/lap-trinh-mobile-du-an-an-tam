import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/family_photo_model.dart';
import '../services/storage_service.dart';

class FamilyPhotoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  /// Upload a new photo to Firebase Storage and save metadata to Firestore
  Future<FamilyPhotoModel> uploadPhoto({
    File? imageFile,
    XFile? imageFileWeb,
    required String parentId,
    required String uploadedBy,
    required String caption,
    Function(double)? onProgress,
  }) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'family_photos/$parentId/$timestamp.jpg';

      // Upload image to Storage
      final imageUrl = await _storageService.uploadImage(
        imageFile: imageFile,
        imageFileWeb: imageFileWeb,
        path: path,
        onProgress: onProgress,
      );

      // Create photo metadata
      final photoData = {
        'parentId': parentId,
        'uploadedBy': uploadedBy,
        'imageUrl': imageUrl,
        'caption': caption,
        'thumbnailUrl': null,
        'createdAt': Timestamp.now(),
        'likes': 0,
        'isVisible': true,
      };

      // Save to Firestore
      final docRef = await _firestore.collection('family_photos').add(photoData);
      
      debugPrint('Photo uploaded successfully: ${docRef.id}');

      // Return the created photo model
      final doc = await docRef.get();
      final data = doc.data()!;
      final authUrl = await _storageService.authorizeUrl(data['imageUrl'] as String);
      return FamilyPhotoModel(
        id: doc.id,
        parentId: data['parentId'] as String? ?? '',
        uploadedBy: data['uploadedBy'] as String? ?? '',
        imageUrl: authUrl,
        caption: data['caption'] as String? ?? '',
        thumbnailUrl: data['thumbnailUrl'] as String?,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        likes: (data['likes'] as num?)?.toInt() ?? 0,
        isVisible: data['isVisible'] as bool? ?? true,
      );
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      rethrow;
    }
  }

  /// Get all photos for a specific parent
  Stream<List<FamilyPhotoModel>> streamPhotos(String parentId) {
    return _firestore
        .collection('family_photos')
        .where('parentId', isEqualTo: parentId)
        .where('isVisible', isEqualTo: true)
        // Removed orderBy to avoid requiring a composite index
        .snapshots()
        .asyncMap((snapshot) async {
          final list = <FamilyPhotoModel>[];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final url = data['imageUrl'] as String? ?? '';
            final authUrl = await _storageService.authorizeUrl(url);
            
            final photo = FamilyPhotoModel(
              id: doc.id,
              parentId: data['parentId'] as String? ?? '',
              uploadedBy: data['uploadedBy'] as String? ?? '',
              imageUrl: authUrl,
              caption: data['caption'] as String? ?? '',
              thumbnailUrl: data['thumbnailUrl'] as String?,
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              likes: (data['likes'] as num?)?.toInt() ?? 0,
              isVisible: data['isVisible'] as bool? ?? true,
            );
            list.add(photo);
          }
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Get photos as a one-time fetch
  Future<List<FamilyPhotoModel>> getPhotos(String parentId) async {
    try {
      final snapshot = await _firestore
          .collection('family_photos')
          .where('parentId', isEqualTo: parentId)
          .where('isVisible', isEqualTo: true)
          // Removed orderBy to avoid requiring a composite index
          .get();

      final list = <FamilyPhotoModel>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final url = data['imageUrl'] as String? ?? '';
        final authUrl = await _storageService.authorizeUrl(url);
        
        final photo = FamilyPhotoModel(
          id: doc.id,
          parentId: data['parentId'] as String? ?? '',
          uploadedBy: data['uploadedBy'] as String? ?? '',
          imageUrl: authUrl,
          caption: data['caption'] as String? ?? '',
          thumbnailUrl: data['thumbnailUrl'] as String?,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          likes: (data['likes'] as num?)?.toInt() ?? 0,
          isVisible: data['isVisible'] as bool? ?? true,
        );
        list.add(photo);
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      debugPrint('Error getting photos: $e');
      rethrow;
    }
  }

  /// Delete a photo (both from Storage and Firestore)
  Future<void> deletePhoto(FamilyPhotoModel photo) async {
    try {
      // Delete from Storage
      // Remove any appended token before attempting to delete
      final rawUrl = photo.imageUrl.split('?').first;
      await _storageService.deleteImage(rawUrl);

      // Delete from Firestore
      await _firestore.collection('family_photos').doc(photo.id).delete();

      debugPrint('Photo deleted successfully: ${photo.id}');
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      rethrow;
    }
  }

  /// Update photo caption
  Future<void> updateCaption(String photoId, String newCaption) async {
    try {
      await _firestore.collection('family_photos').doc(photoId).update({
        'caption': newCaption,
      });
      debugPrint('Caption updated successfully');
    } catch (e) {
      debugPrint('Error updating caption: $e');
      rethrow;
    }
  }

  /// Toggle photo visibility
  Future<void> toggleVisibility(String photoId, bool isVisible) async {
    try {
      await _firestore.collection('family_photos').doc(photoId).update({
        'isVisible': isVisible,
      });
      debugPrint('Visibility updated successfully');
    } catch (e) {
      debugPrint('Error updating visibility: $e');
      rethrow;
    }
  }
}
