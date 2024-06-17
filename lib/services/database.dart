import 'package:brew_crew/models/brew.dart';
import 'package:brew_crew/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference brewCollection =
  FirebaseFirestore.instance.collection('brews');
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('users');

  Future updateUserData(String username, String profilePicture) async {
    return await userCollection.doc(uid).set({
      'username': username,
      'profilePicture': profilePicture,
    });
  }

  Future updateBrewData(String sugars, int strength, String uid) async {
    return await brewCollection.doc(uid).set({
      'sugars': sugars,
      'strength': strength,
    });
  }

  List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return Brew(
        sugars: data?['sugars'] ?? '0',
        strength: data?['strength'] ?? 0,
        uid: doc.id,
      );
    }).toList();
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return UserData(
      uid: uid,
      username: data?['username'] ?? '',
      profilePicture: data?['profilePicture'] ?? '',
    );
  }

  Stream<List<Brew>> get brews {
    return brewCollection.snapshots().map(_brewListFromSnapshot);
  }

  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}