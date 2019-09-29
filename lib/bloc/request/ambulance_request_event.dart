import 'package:equatable/equatable.dart';
import 'package:ksars_smart/model/paitent.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AmbulanceRequestEvent extends Equatable {
  AmbulanceRequestEvent([List props = const <dynamic>[]]) : super(props);
}

class AmbulanceRequest extends AmbulanceRequestEvent{
  final String otherUID;
  final Patient patient;

  AmbulanceRequest({this.otherUID,this.patient}) :super([otherUID,patient]);
  @override
  String toString() => "AmbulanceRequest";
}
class AmbulanceRequestCancel extends AmbulanceRequestEvent{
  final String otherUID;

  AmbulanceRequestCancel({this.otherUID}) :super([otherUID]);
  @override
  String toString() => "AmbulanceRequestCancel";
}

class AmbulanceRequestLoad extends AmbulanceRequestEvent{
  String currentUID;
  AmbulanceRequestLoad(this.currentUID) :super([currentUID]);
  @override
  String toString() => "AmbulanceRequestLoad";
}

class AmbulanceRequestUpdated extends AmbulanceRequestEvent{
  final List<Patient> patient;

  AmbulanceRequestUpdated({this.patient}) :super([patient]);
  @override
  String toString() => "AmbulanceRequestUpdated";
}