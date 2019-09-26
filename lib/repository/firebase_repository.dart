import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ksars_smart/model/user.dart';
import 'package:ksars_smart/model/user_entity.dart';
import 'package:ksars_smart/repository/repoBase.dart';

class FirebaseRepository extends RepoBase {
  FirebaseAuth _firebaseAuth;
  final _userCollection = Firestore.instance.collection('user');

  FirebaseRepository({FirebaseRepository firebaseUserRepository})
      : _firebaseAuth = firebaseUserRepository ?? FirebaseAuth.instance;

  @override
  Future<String> getCurrentUID() async {
    return (await _firebaseAuth.currentUser()).uid;
  }

  @override
  Future<void> getInitializedCurrentUser(
      {String email,
      String name,
      String phone,
      String type,
      String profile}) async {
    _userCollection
        .document((await _firebaseAuth.currentUser()).uid)
        .get()
        .then((user) async {
      if (!user.exists) {
        var newUser = User(
                email: email,
                profile: profile,
                name: name,
                type: type,
                phone: phone,
                uid: (await _firebaseAuth.currentUser()).uid)
            .toEntity()
            .toDocument();

        _userCollection
            .document((await _firebaseAuth.currentUser()).uid)
            .setData(newUser);
      } else {
        print('Already Exists');
      }
    }).catchError((exception) =>
            print("getInitializedCurrentUser ${exception.toString()}"));
  }

  @override
  Future<bool> isSignIn() async {
    return (await _firebaseAuth.currentUser()).uid != null;
  }

  @override
  Future<void> signInWithEmailPassword({String email, String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signUpWithEmailPassword({String email, String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> onUpdateUserInfo(
      {String name, String profile, String phoneNumber, String uid,GeoPoint point}) async {
    Map<String, Object> updateUser = Map();

    if (name.isNotEmpty) updateUser['name'] = name;
    if (profile != null) updateUser['profile'] = profile;
    if (phoneNumber != null) updateUser['profile'] = profile;
    if (point!=null) updateUser['position'] =point;
    _userCollection.document(uid).updateData(updateUser);
  }

  @override
  Stream<List<User>> users() {
    return _userCollection.snapshots().map((snapshot) {
      return snapshot.documents
          .map((docSnapshot) =>
              User.fromEntity(UserEntity.fromSnapshot(docSnapshot)))
          .toList();
    });
  }
}
