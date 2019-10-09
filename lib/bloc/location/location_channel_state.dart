import 'package:equatable/equatable.dart';
import 'package:ksars_smart/model/LocationMessage.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LocationChannelState extends Equatable {
  LocationChannelState([List props = const <dynamic>[]]) : super(props);
}

class  LocationLoading extends LocationChannelState {
  @override
  String toString() => 'LocationLoading';
}

class LocationLoaded extends LocationChannelState {
  final List<LocationMessage> locationMessage;
  final List<String> channelIds;

  LocationLoaded({this.locationMessage=const [],this.channelIds}) : super([locationMessage,channelIds]);

  @override
  String toString() => 'LocationLoaded { locationMessage : $locationMessage }';
}
class  LocationNotLoaded extends LocationChannelState {
  @override
  String toString() => 'LocationNotLoaded';
}