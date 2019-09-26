import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ksars_smart/model/user.dart';
import 'package:meta/meta.dart';

@immutable
abstract class UserEvent extends Equatable {
  UserEvent([List props = const <dynamic>[]]) : super(props);
}
class LoadUser extends UserEvent{
  @override
  String toString() => 'LoadUser';
}

class UpdateUser extends UserEvent{
  final User user;
  final GeoPoint point;
  UpdateUser({this.user,this.point}) : super([user,point]);
  @override
  String toString() => 'UpdateUser';
}
class UsersUpdated extends UserEvent{
  final List<User> user;

  UsersUpdated({this.user}):super([user]);
  @override
  String toString() => 'UsersUpdated';
}