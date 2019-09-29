import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ksars_smart/model/patientEntity.dart';

class Patient {
  final String name;
  final String uid;
  final String profile;
  final Timestamp time;
  final String request_type;

  Patient(
      {this.name = '',
      this.uid = '',
      this.profile = '',
      this.time,
      this.request_type = ''});

  Patient copyWith({
    String name,
    String uid,
    String profile,
    Timestamp time,
    String request_type,
  }) {
    return Patient(
      name: name ?? this.name,
      uid: uid ?? this.uid,
      profile: profile ?? this.profile,
      time: time ?? this.time,
      request_type: request_type ?? this.request_type,
    );
  }

  @override
  // TODO: implement hashCode
  int get hashCode =>
      name.hashCode ^
      uid.hashCode ^
      profile.hashCode ^
      time.hashCode ^
      request_type.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is Patient &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          uid == other.uid &&
          profile == other.profile &&
          time == other.time &&
          request_type == other.request_type;


   PatientEntity toEntity() =>
      PatientEntity(name,uid,profile,time,request_type);

  static Patient fromEntity(PatientEntity entity){
    return Patient(
      name: entity.name,
      uid: entity.uid,
      profile: entity.profile,
      time: entity.time,
      request_type: entity.request_type,
    );
  }
  @override
  String toString() => '''
    name $name,
    uid $uid,
    profile $profile,
    timestap $time,
    request_type $request_type
  ''';
}
