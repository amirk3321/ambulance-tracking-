import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AmbulanceRequestEvent extends Equatable {
  AmbulanceRequestEvent([List props = const <dynamic>[]]) : super(props);
}

class AmbulanceRequest extends AmbulanceRequestEvent{
  final String otherUID;

  AmbulanceRequest({this.otherUID}) :super([otherUID]);
  @override
  String toString() => "AmbulanceRequest";
}
class AmbulanceRequestCancel extends AmbulanceRequestEvent{
  final String otherUID;

  AmbulanceRequestCancel({this.otherUID}) :super([otherUID]);
  @override
  String toString() => "AmbulanceRequestCancel";
}
