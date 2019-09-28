import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AmbulanceRequestState extends Equatable {
  AmbulanceRequestState([List props = const <dynamic>[]]) : super(props);
}

class InitialAmbulanceRequestState extends AmbulanceRequestState {}
class AmbulanceRequestLoading extends AmbulanceRequestState {}
class AmbulanceRequestLoaded extends AmbulanceRequestState {}
