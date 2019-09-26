import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const <dynamic>[]]) : super(props);
}

class Submitted extends LoginEvent {
  final String email;
  final String password;
  Submitted({
    this.email,
    this.password,
  }) : super([email, password]);

  @override
  String toString() => ''' 
  email : $email,
  password :$password,
  ''';
}