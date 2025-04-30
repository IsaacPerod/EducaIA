import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/content.dart';
import '../models/history.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<User?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromMap(doc.data() as Map<String, dynamic>, uid);
    }
    return null;
  }

  Stream<List<Content>> getRecommendations(String uid) {
    return _db.collection('users').doc(uid).snapshots().asyncMap((userDoc) async {
      final userData = userDoc.data() as Map<String, dynamic>;
      final level = userData['level'];
      final interests = List<String>.from(userData['interests']);
      
      QuerySnapshot query = await _db
          .collection('contents')
          .where('difficulty', isEqualTo: level)
          .where('topics', arrayContainsAny: interests)
          .get();
      
      return query.docs.map((doc) => Content.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<void> updateHistory(History history) async {
    await _db
        .collection('user_history')
        .doc('${history.userId}_${history.contentId}')
        .set(history.toMap());
  }
}