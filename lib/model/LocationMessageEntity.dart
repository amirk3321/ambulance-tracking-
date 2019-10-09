import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class LocationMessageEntity extends Equatable {
  final String senderId;
  final bool isFlag;
  final String channelId;
  final String recipientId;
  final String driverName;
  final String patientName;
  final GeoPoint ambulancePosition;
  final GeoPoint patientPosition;
  final List<String> locationChannelUserIds;

  LocationMessageEntity(this.senderId,this.isFlag,this.channelId, this.recipientId, this.ambulancePosition,
      this.patientPosition, this.patientName, this.driverName,{this.locationChannelUserIds});

  Map<String, Object> toJson() => {
        'senderId': senderId,
        'isFlag': isFlag,
        'channelId': channelId,
        'recipientId': recipientId,
        'ambulancePosition': ambulancePosition,
        'patientPosition': patientPosition,
        'patientName': patientName,
        'driverName': driverName,
        'locationChannelUserIds': locationChannelUserIds,
      };

  static LocationMessageEntity fromJson(Map<String, Object> json) =>
      LocationMessageEntity(
        json['senderId'] as String,
        json['isFlag'] as bool,
        json['channelId'] as String,
        json['recipientId'] as String,
        json['ambulancePosition'] as GeoPoint,
        json['patientPosition'] as GeoPoint,
        json['patientName'] as String,
        json['driverName'] as String,
        locationChannelUserIds: json['driverName'] as List<String>,
      );

  static LocationMessageEntity fromDocumentSnapshot(
          DocumentSnapshot snapshot) =>
      LocationMessageEntity(
        snapshot.data['senderId'],
        snapshot.data['isFlag'],
        snapshot.data['channelId'],
        snapshot.data['recipientId'],
        snapshot.data['ambulancePosition'],
        snapshot.data['patientPosition'],
        snapshot.data['patientName'],
        snapshot.data['driverName'],
      );

  Map<String, Object> toDocument() => {
        'senderId': senderId,
        'isFlag': isFlag,
        'channelId': channelId,
        'recipientId': recipientId,
        'ambulancePosition': ambulancePosition,
        'patientPosition': patientPosition,
        'patientName': patientName,
        'driverName': driverName,
        'locationChannelUserIds': locationChannelUserIds,
      };
}
