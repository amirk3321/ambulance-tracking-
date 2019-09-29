import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class LocationMessageEntity extends Equatable {
  final String senderId;
  final String recipientId;
  final String driverName;
  final String patientName;
  final GeoPoint ambulancePosition;
  final GeoPoint patientPosition;

  LocationMessageEntity(this.senderId, this.recipientId, this.ambulancePosition,
      this.patientPosition, this.patientName, this.driverName);

  Map<String, Object> toJson() => {
        'senderId': senderId,
        'recipientId': recipientId,
        'ambulancePosition': ambulancePosition,
        'patientPosition': patientPosition,
        'patientName': patientName,
        'driverName': driverName
      };

  static LocationMessageEntity fromJson(Map<String, Object> json) =>
      LocationMessageEntity(
        json['senderId'] as String,
        json['recipientId'] as String,
        json['ambulancePosition'] as GeoPoint,
        json['patientPosition'] as GeoPoint,
        json['patientName'] as String,
        json['driverName'] as String,
      );

  static LocationMessageEntity fromDocumentSnapshot(
          DocumentSnapshot snapshot) =>
      LocationMessageEntity(
        snapshot.data['senderId'],
        snapshot.data['recipientId'],
        snapshot.data['ambulancePosition'],
        snapshot.data['patientPosition'],
        snapshot.data['patientName'],
        snapshot.data['driverName'],
      );

  Map<String, Object> toDocument() => {
        'senderId': senderId,
        'recipientId': recipientId,
        'ambulancePosition': ambulancePosition,
        'patientPosition': patientPosition,
        'patientName': patientName,
        'driverName': driverName
      };
}
