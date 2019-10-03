import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ksars_smart/model/LocationMessage.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LocationChannelEvent extends Equatable {
  LocationChannelEvent([List props = const <dynamic>[]]) : super(props);
}


class ConfirmLocationChannelCreate extends LocationChannelEvent{
  final String otherUID;
  final String currentUID;
  final String patientName;
  final String driverName;
  final GeoPoint patientPosition;
  final GeoPoint ambulancePosition;
  ConfirmLocationChannelCreate({this.otherUID,this.currentUID,this.patientName,this.driverName,this.patientPosition,this.ambulancePosition}) :super([otherUID,currentUID,patientName,driverName,patientPosition,ambulancePosition]);

  @override
  String toString() => 'ConfirmLocationChannelCreate';
}

class LocationUpdated extends LocationChannelEvent{
  final List<LocationMessage> locationMessages;
  LocationUpdated({this.locationMessages}) :super([locationMessages]);
  @override
  String toString() => 'LocationUpdated';
}

class LoadLocationMessage extends LocationChannelEvent{
  @override
  String toString() => 'LoadLocationMessage';
}

class UpdateLocation extends LocationChannelEvent{
  final GeoPoint ambulanceLocation;
  final String channelId;
  UpdateLocation({this.ambulanceLocation,this.channelId}) :super([ambulanceLocation,channelId]);
  @override
  String toString() => 'UpdateLocation';
}

