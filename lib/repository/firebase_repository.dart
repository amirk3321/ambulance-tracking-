import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ksars_smart/model/LocationMessage.dart';
import 'package:ksars_smart/model/LocationMessageEntity.dart';
import 'package:ksars_smart/model/paitent.dart';
import 'package:ksars_smart/model/patientEntity.dart';
import 'package:ksars_smart/model/user.dart';
import 'package:ksars_smart/model/user_entity.dart';
import 'package:ksars_smart/repository/repoBase.dart';
import 'package:ksars_smart/utils/shared_pref.dart';

class FirebaseRepository extends RepoBase {
  FirebaseAuth _firebaseAuth;
  final _userCollection = Firestore.instance.collection('user');
  final _locationChannels = Firestore.instance.collection('locationChannels');

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
      String profile,
      GeoPoint point}) async {
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
                point: point,
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
    await SharedPref.setCurrentUID((await _firebaseAuth.currentUser()).uid);
  }

  @override
  Future<void> signUpWithEmailPassword({String email, String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    await SharedPref.setCurrentUID((await _firebaseAuth.currentUser()).uid);
  }

  @override
  Future<void> onUpdateUserInfo(
      {String name,
      String profile,
      String phoneNumber,
      String uid,
        bool isBusy,
      GeoPoint point}) async {
    Map<String, Object> updateUser = Map();

    if (name.isNotEmpty) updateUser['name'] = name;
    if (profile != null) updateUser['profile'] = profile;
    if (phoneNumber != null) updateUser['phone'] = phoneNumber;
    if (point != null) updateUser['position'] = point;
    if (isBusy == false) updateUser['isBusy']=true;
    else updateUser['isBusy']=false;
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

  @override
  Future<void> getCreateLocationChannel(
      {String otherUID, Function onComplete}) async {
    _userCollection
        .document((await _firebaseAuth.currentUser()).uid)
        .collection('engagedLocationChannels')
        .document(otherUID)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        onComplete(snapshot.data['channelId']);
        return;
      }

      var newLocationChannel = _locationChannels.document();

      var channel = {'channelId': newLocationChannel.documentID};

      _userCollection
          .document((await _firebaseAuth.currentUser()).uid)
          .collection('engagedLocationChannels')
          .document(otherUID)
          .setData(channel);

      Firestore.instance
          .collection('user')
          .document(otherUID)
          .collection('engagedLocationChannels')
          .document((await _firebaseAuth.currentUser()).uid)
          .setData(channel);

      onComplete(newLocationChannel.documentID);
    })
          ..catchError((Exception e) =>
              print("getCreateLocationChannel :${e.toString()}"));
  }

  Future<void> getDeleteLocationChannel({
    String otherUID,
  }) async {
    _userCollection
        .document((await _firebaseAuth.currentUser()).uid)
        .collection('engagedLocationChannels')
        .document(otherUID)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        _userCollection
            .document((await _firebaseAuth.currentUser()).uid)
            .collection('engagedLocationChannels')
            .document(otherUID)
            .delete();

        Firestore.instance
            .collection('user')
            .document(otherUID)
            .collection('engagedLocationChannels')
            .document((await _firebaseAuth.currentUser()).uid)
            .delete();
        return;
      }else{
        print("there is no any engagedLocationChannels");
      }
    });
  }

  Future<void> getAmbulancePickRequest(
      {String otherUID, Patient patient}) async {
    _userCollection
        .document((await _firebaseAuth.currentUser()).uid)
        .collection('ambulanceRequest')
        .document(otherUID)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        return;
      }
      _userCollection
          .document((await _firebaseAuth.currentUser()).uid)
          .collection('ambulanceRequest')
          .document(otherUID)
          .setData({"request_type": "received"});

      Firestore.instance
          .collection('user')
          .document(otherUID)
          .collection('ambulanceRequest')
          .document((await _firebaseAuth.currentUser()).uid)
          .setData(patient.toEntity().toDocument());
    })
          ..catchError((Exception e) =>
              print("getAmbulancePickRequest ${e.toString()}"));
  }

  Future<void> getDeleteAmbulancePickRequest({String otherUID}) async {
    _userCollection
        .document((await _firebaseAuth.currentUser()).uid)
        .collection('ambulanceRequest')
        .document(otherUID)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        _userCollection
            .document((await _firebaseAuth.currentUser()).uid)
            .collection('ambulanceRequest')
            .document(otherUID)
            .delete();

        Firestore.instance
            .collection('user')
            .document(otherUID)
            .collection('ambulanceRequest')
            .document((await _firebaseAuth.currentUser()).uid)
            .delete();
        return;
      } else {
        print('there is not any requst?');
        return;
      }
    })
          ..catchError((Exception e) =>
              print("getDeleteAmbulancePickRequest ${e.toString()}"));
  }

  Stream<List<Patient>> patientList(String currentUID) {
    return _userCollection
        .document(currentUID)
        .collection('ambulanceRequest')
        .orderBy('time')
        .snapshots()
        .map((snapshot) {
      return snapshot.documents
          .map((snapshot) =>
              Patient.fromEntity(PatientEntity.formSnapshot(snapshot)))
          .toList();
    });
  }

  Future<void> shareLocationMessage(
      {LocationMessage locationMessage, String channelId}) async {
    _locationChannels
        .document(channelId)
        .setData(locationMessage.toEntity().toDocument())
        .catchError((e) => print(e.toString()));
  }

  Stream<List<LocationMessage>> locationMessages() {
    return _locationChannels.snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) => LocationMessage.formEntity(
              LocationMessageEntity.fromDocumentSnapshot(doc)))
          .toList();
    });
  }

  Future<void> updateLocation(
      {GeoPoint ambulanceLocation, String channelId, bool isFlag}) async {
    Map<String, Object> locationUpdate = Map();

    if (ambulanceLocation != null)
      locationUpdate['ambulancePosition'] = ambulanceLocation;

    locationUpdate['isFlag'] = isFlag;

    _locationChannels.document(channelId).updateData(locationUpdate);
  }

  Stream<List<String>> getChannelIds() {
    return _locationChannels.snapshots().map((snapshot) {
      return snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  Future<void> getRemoveLocationChannel({String channelId}) async {
    _locationChannels.document(channelId).get().then((locationChannel) {
      if (locationChannel.exists) {
        _locationChannels.document(channelId).delete();
        return;
      } else {
        print("LocationChannel is not exists");
        return;
      }
    });
  }
}
