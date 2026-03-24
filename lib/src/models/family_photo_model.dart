import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyPhotoModel {
  final String id;
  final String parentId;
  final String uploadedBy;
  final String imageUrl;
  final String caption;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final int likes;
  final bool isVisible;

  const FamilyPhotoModel({
    required this.id,
    required this.parentId,
    required this.uploadedBy,
    required this.imageUrl,
    required this.caption,
    this.thumbnailUrl,
    required this.createdAt,
    this.likes = 0,
    this.isVisible = true,
  });

  factory FamilyPhotoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FamilyPhotoModel(
      id: doc.id,
      parentId: data['parentId'] as String? ?? '',
      uploadedBy: data['uploadedBy'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      isVisible: data['isVisible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'parentId': parentId,
        'uploadedBy': uploadedBy,
        'imageUrl': imageUrl,
        'caption': caption,
        'thumbnailUrl': thumbnailUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'likes': likes,
        'isVisible': isVisible,
      };
}
