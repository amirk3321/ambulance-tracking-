import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RegistorState extends Equatable {
  RegistorState([List props = const <dynamic>[]]) : super(props);
}

class InitialState extends RegistorState {
  @override
  String toString()  => "InitialState";
}

class LoadingState extends RegistorState{
  @override
  String toString()  => "LoadingState";
}

class SuccessState extends RegistorState{
  @override
  String toString()  => "SuccessState";
}

class FailureState extends RegistorState{
  @override
  String toString()  => "FailureState";
}