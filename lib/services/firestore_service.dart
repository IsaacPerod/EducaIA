import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserHistory(String userId, String contentId, String status) async {
    await _firestore
        .collection('user_history')
        .doc('${userId}_$contentId')
        .set({
      'user_id': userId,
      'content_id': contentId,
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getUserHistory(String userId) {
    return _firestore
        .collection('user_history')
        .where('user_id', isEqualTo: userId)
        .snapshots();
  }

  Future<void> cacheContent(Map<String, dynamic> content) async {
    await _firestore
        .collection('contents')
        .doc(content['id'])
        .set(content, SetOptions(merge: true));
  }
}