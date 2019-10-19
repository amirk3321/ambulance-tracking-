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
  final bool isFlag;
  final String currentUID;
  final String patientName;
  final String driverName;
  final GeoPoint patientPosition;
  final GeoPoint ambulancePosition;
  final GeoPoint hospitalPosition;
  ConfirmLocationChannelCreate({this.otherUID,this.isFlag,this.currentUID,this.patientName,this.driverName,this.patientPosition,this.ambulancePosition,this.hospitalPosition}) :super([otherUID,currentUID,patientName,driverName,patientPosition,ambulancePosition,hospitalPosition]);

  @override
  String toString() => 'ConfirmLocationChannelCreate';
}

class LocationUpdated extends LocationChannelEvent{
  final List<LocationMessage> locationMessages;
  final List<String> channelIds;
  LocationUpdated({this.locationMessages,this.channelIds}) :super([locationMessages,channelIds]);
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
  final bool isFlag;
  UpdateLocation({this.ambulanceLocation,this.channelId,this.isFlag}) :super([ambulanceLocation,channelId,isFlag]);
  @override
  String toString() => 'UpdateLocation';
}

class DeleteLocationChannel extends LocationChannelEvent{
  final String channelId;
  DeleteLocationChannel({this.channelId}) :super([channelId]);
  @override
  String toString() => "DeleteLocationChannel";
}

class DeleteEngagedLocationChannel extends LocationChannelEvent{
  final String otherUID;
  DeleteEngagedLocationChannel({this.otherUID}) : super([otherUID]);
  @override
  String toString() => "DeleteEngagedLocationChannel";
}