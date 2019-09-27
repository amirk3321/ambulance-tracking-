import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RegistorEvent extends Equatable {
  RegistorEvent([List props = const <dynamic>[]]) : super(props);
}
class Submitted extends RegistorEvent {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String type;
  final String profile;
  final GeoPoint point;

  Submitted({
    this.email,
    this.password,
    this.name,
    this.phoneNumber,
    this.type,
    this.profile,
    this.point,
  }) : super([email, password,name,phoneNumber,type,profile,point]);

  @override
  String toString() => ''' 
  email : $email,
  password :$password,
  ''';
}