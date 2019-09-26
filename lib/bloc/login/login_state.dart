import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LoginState extends Equatable {
  LoginState([List props = const <dynamic>[]]) : super(props);
}
class InitialState extends LoginState {
  @override
  String toString()  => "InitialState";
}

class LoadingState extends LoginState{
  @override
  String toString()  => "LoadingState";
}

class SuccessState extends LoginState{
  @override
  String toString()  => "SuccessState";
}

class FailureState extends LoginState{
  @override
  String toString()  => "FailureState";
}