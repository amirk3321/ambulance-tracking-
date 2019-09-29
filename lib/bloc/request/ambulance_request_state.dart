import 'package:equatable/equatable.dart';
import 'package:ksars_smart/model/paitent.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AmbulanceRequestState extends Equatable {
  AmbulanceRequestState([List props = const <dynamic>[]]) : super(props);
}

class AmbulanceRequestLoading extends AmbulanceRequestState {
  @override
  String toString() => 'AmbulanceRequestLoading';
}

class AmbulanceRequestLoaded extends AmbulanceRequestState {
  final List<Patient> patient;

  AmbulanceRequestLoaded([this.patient]) : super([patient]);

  @override
  String toString() => 'AmbulanceRequestLoaded { patient: $patient }';
}
