import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/family_photo_model.dart';
import '../repositories/family_photo_repository.dart';

class FamilyPhotoProvider extends ChangeNotifier {
  final FamilyPhotoRepository _repository = FamilyPhotoRepository();

  List<FamilyPhotoModel> _photos = [];
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  StreamSubscription<List<FamilyPhotoModel>>? _photosSub;

  List<FamilyPhotoModel> get photos => _photos;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;

  /// Update user and start listening to photos
  void updateUser({String? parentId}) {
    _photosSub?.cancel();
    _photosSub = null;
    _photos = [];
    _errorMessage = null;

    if (parentId != null && parentId.isNotEmpty) {
      _photosSub = _repository.streamPhotos(parentId).listen(
        (photos) {
          _photos = photos;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    }
  }

  /// Load photos for a specific parent
  Future<void> loadPhotos(String parentId) async {
    if (parentId.isEmpty) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _photos = await _repository.getPhotos(parentId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload a new photo
  Future<bool> uploadPhoto({
    File? imageFile,
    XFile? imageFileWeb,
    required String parentId,
    required String uploadedBy,
    required String caption,
  }) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
      notifyListeners();

      await _repository.uploadPhoto(
        imageFile: imageFile,
        imageFileWeb: imageFileWeb,
        parentId: parentId,
        uploadedBy: uploadedBy,
        caption: caption,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return false;
    }
  }

  /// Delete a photo
  Future<bool> deletePhoto(FamilyPhotoModel photo) async {
    try {
      _errorMessage = null;
      await _repository.deletePhoto(photo);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update photo caption
  Future<bool> updateCaption(String photoId, String newCaption) async {
    try {
      _errorMessage = null;
      await _repository.updateCaption(photoId, newCaption);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _photosSub?.cancel();
    super.dispose();
  }
}
