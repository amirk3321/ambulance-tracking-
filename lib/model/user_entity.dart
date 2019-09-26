import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity extends Equatable{
  final String email;
  final String name;
  final String type;
  final String uid;
  final String phone;
  final String profile;

  UserEntity(this.email,this.name,this.type,this.uid,this.phone,this.profile);

  Map<String,Object> toJson() =>{
    'email' :email,
    'name' :name,
    'type' :type,
    'uid' :uid,
    'phone' :phone,
    'profile' :profile,
  };
  @override
  String toString() {
    return 'UserEntity { email: $email name: $name, uid: $uid type $type phone $phone profile $profile}';
  }


  static UserEntity formJson(Map<String,Object> json){
    return UserEntity(
      json['email'] as String,
      json['name'] as String,
      json['type'] as String,
      json['uid'] as String,
      json['phone'] as String,
      json['profile'] as String,
    );
  }

  static UserEntity fromSnapshot(DocumentSnapshot snap) {
    return UserEntity(
      snap.data['email'],
      snap.data['name'],
      snap.data['type'],
      snap.data['uid'],
      snap.data['phone'],
      snap.data['profile'],
    );
  }
  Map<String, Object> toDocument() {
    return {
      'email': email,
      'name': name,
      'type': type,
      'uid': uid,
      'phone': phone,
      'profile': profile,
    };
  }
}