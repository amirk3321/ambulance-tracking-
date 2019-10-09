import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ksars_smart/model/LocationMessageEntity.dart';

class LocationMessage {
  final String senderId;
  final bool isFlag;
  final String channelId;
  final String recipientId;
  final String driverName;
  final String patientName;
  final GeoPoint ambulancePosition;
  final GeoPoint patientPosition;
  final List<String> locationChannelUserIds;

  LocationMessage(
      {this.senderId = '',
      this.isFlag = false,
      this.recipientId = '',
      this.channelId = '',
      this.ambulancePosition,
      this.patientPosition,
      this.driverName,
      this.patientName,
      this.locationChannelUserIds = const []});

  LocationMessage copyWith({
    String senderId,
    bool isFlag,
    String channelId,
    String recipientId,
    GeoPoint ambulancePosition,
    GeoPoint patientPosition,
    List<String> locationChannelUserIds,
  }) {
    return LocationMessage(
      senderId: senderId ?? this.senderId,
      isFlag: isFlag ?? this.isFlag,
      channelId: channelId ?? this.channelId,
      recipientId: recipientId ?? this.recipientId,
      ambulancePosition: ambulancePosition ?? this.ambulancePosition,
      patientPosition: patientPosition ?? this.patientPosition,
      locationChannelUserIds: locationChannelUserIds ?? this.locationChannelUserIds,
    );
  }

  @override
  // TODO: implement hashCode
  int get hashCode =>
      senderId.hashCode ^
      isFlag.hashCode ^
      channelId.hashCode ^
      recipientId.hashCode ^
      ambulancePosition.hashCode ^
      patientPosition.hashCode ^
      patientName.hashCode ^
      driverName.hashCode^
      locationChannelUserIds.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, LocationMessage) ||
      other is LocationMessage &&
          runtimeType == other.runtimeType &&
          senderId == other.senderId &&
          isFlag == other.isFlag &&
          channelId == other.channelId &&
          recipientId == other.recipientId &&
          ambulancePosition == other.ambulancePosition &&
          patientPosition == other.patientPosition &&
          patientName == other.patientName &&
          driverName == other.driverName &&
          locationChannelUserIds == other.locationChannelUserIds;

  @override
  String toString() => '''
  recipientId :$recipientId , 
  senderId $senderId, 
  isFlag $isFlag, 
  channelId $channelId, 
  ambulancePosition $ambulancePosition,
  paitientPosition $patientPosition,
  patientName $patientName,
  driverName $driverName
  ''';

  LocationMessageEntity toEntity() => LocationMessageEntity(
      this.senderId,
      this.isFlag,
      this.channelId,
      this.recipientId,
      this.ambulancePosition,
      this.patientPosition,
      this.patientName,
      this.driverName,
  locationChannelUserIds: this.locationChannelUserIds);

  static LocationMessage formEntity(LocationMessageEntity entity) {
    return LocationMessage(
        senderId: entity.senderId,
        isFlag: entity.isFlag,
        channelId: entity.channelId,
        recipientId: entity.recipientId,
        ambulancePosition: entity.ambulancePosition,
        patientPosition: entity.patientPosition,
        patientName: entity.patientName,
        driverName: entity.driverName,
        locationChannelUserIds: entity.locationChannelUserIds,
    );
  }
}
