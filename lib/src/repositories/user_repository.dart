import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/exceptions.dart';
import '../models/family_link_model.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection('users');
  CollectionReference get _familyLinks => _db.collection('familyLinks');

  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) throw const UserNotFoundException();
      return UserModel.fromFirestore(doc);
    } on UserNotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi lấy thông tin người dùng: ${e.message}');
    }
  }

  Stream<UserModel> streamUser(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) throw const UserNotFoundException();
      return UserModel.fromFirestore(doc);
    }).handleError((e) {
      throw e;
    });
  }

  Future<void> updateParentId(String childId, String parentId) async {
    await _users.doc(childId).update({'parentId': parentId});
  }

  Future<void> updatePhone(String userId, String phone) async {
    await _users.doc(userId).update({'phone': phone});
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final snap = await _users.where('email', isEqualTo: email).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return UserModel.fromFirestore(snap.docs.first);
  }

  Future<UserModel?> getUserByPhone(String phone, {String? role}) async {
    Query query = _users.where('phone', isEqualTo: phone);
    if (role != null) {
      query = query.where('role', isEqualTo: role);
    }
    final snap = await query.limit(1).get();
    if (snap.docs.isEmpty) return null;
    return UserModel.fromFirestore(snap.docs.first);
  }

  Stream<List<UserModel>> getChildrenForParent(String parentId) {
    return _users.where('parentId', isEqualTo: parentId).snapshots().map(
      (snap) => snap.docs.map((doc) => UserModel.fromFirestore(doc)).toList()
    );
  }

  Future<UserModel> getLinkedParent(String childUserId) async {
    final child = await getUserById(childUserId);
    if (child.parentId == null || child.parentId!.isEmpty) {
      throw const UserNotFoundException('Chưa liên kết với cha/mẹ');
    }
    return getUserById(child.parentId!);
  }

  Future<void> createFamilyLink(FamilyLinkModel link) async {
    try {
      await _familyLinks.add({
        ...link.toMap(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi tạo liên kết gia đình: ${e.message}');
    }
  }

  Future<void> acceptFamilyLink(String linkId, String childUserId) async {
    try {
      final doc = await _familyLinks.doc(linkId).get();
      if (!doc.exists) throw const UserNotFoundException('Không tìm thấy liên kết');

      final data = doc.data() as Map<String, dynamic>;
      final parentId = data['parentId'] as String? ?? '';

      // Cập nhật status link
      await _familyLinks.doc(linkId).update({'status': 'active'});

      // Cập nhật parentId trong profile của child
      await _users.doc(childUserId).update({'parentId': parentId});
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi chấp nhận liên kết: ${e.message}');
    }
  }

  Stream<UserModel> streamParentStatus(String parentId) {
    return _users.doc(parentId).snapshots().map((doc) {
      if (!doc.exists) throw const UserNotFoundException();
      return UserModel.fromFirestore(doc);
    }).handleError((e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        throw const PermissionDeniedException();
      }
      throw e;
    });
  }

  Stream<FamilyLinkModel?> getFamilyLinkForChild(String childId) {
    return _familyLinks
        .where('childId', isEqualTo: childId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return FamilyLinkModel.fromFirestore(snap.docs.first);
    });
  }
}
