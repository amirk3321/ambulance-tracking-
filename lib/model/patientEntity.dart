
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable{
  final String name;
  final String uid;
  final String profile;
  final Timestamp time;
  final String request_type;
  final GeoPoint patientPosition;
  final GeoPoint hospitalPosition;


  PatientEntity(this.name,this.uid,this.profile,this.time,this.request_type,this.patientPosition,this.hospitalPosition);

  static PatientEntity fromJson(Map<String,Object> json) =>
      PatientEntity(
        json['name'] as String,
        json['uid'] as String,
        json['profile'] as String,
        json['time'] as Timestamp,
        json['request_type'] as String,
        json['patientPosition'] as GeoPoint,
        json['hospitalPosition'] as GeoPoint,
      );

  Map<String,Object> toJson() => {
  'name' : name,
  'uid' : uid,
  'profile' :profile,
  'time' : time,
  'request_type' :request_type,
  'patientPosition' :patientPosition,
  'hospitalPosition' :hospitalPosition,
  };


  static PatientEntity formSnapshot(DocumentSnapshot snapshot) =>
      PatientEntity(
        snapshot.data['name'],
        snapshot.data['uid'],
        snapshot.data['profile'],
        snapshot.data['time'],
        snapshot.data['request_type'],
        snapshot.data['patientPosition'],
        snapshot.data['hospitalPosition'],
      );

  Map<String,Object> toDocument() => {
    'name' : name,
    'uid' : uid,
    'profile' :profile,
    'time' : time,
    'request_type' :request_type,
    'patientPosition' :patientPosition,
    'hospitalPosition' :hospitalPosition,
  };

  @override
  String toString() => '''
    name $name,
    uid $uid,
    profile $profile,
    timestap $time,
    request_type $request_type
    patientPosition $patientPosition,
    hospitalPosition $hospitalPosition,
  ''';



}