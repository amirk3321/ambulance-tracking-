import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ksars_smart/model/LocationMessageEntity.dart';

class LocationMessage {
  final String senderId;
  final String recipientId;
  final String driverName;
  final String patientName;
  final GeoPoint ambulancePosition;
  final GeoPoint patientPosition;

  LocationMessage(
      {this.senderId = '',
      this.recipientId = '',
      this.ambulancePosition,
      this.patientPosition,
      this.driverName,
      this.patientName});

  LocationMessage copyWith({
    String senderId,
    String recipientId,
    GeoPoint ambulancePosition,
    GeoPoint patientPosition,
  }) {
    return LocationMessage(
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      ambulancePosition: ambulancePosition ?? this.ambulancePosition,
      patientPosition: patientPosition ?? this.patientPosition,
    );
  }

  @override
  // TODO: implement hashCode
  int get hashCode =>
      senderId.hashCode ^
      recipientId.hashCode ^
      ambulancePosition.hashCode ^
      patientPosition.hashCode ^
      patientName.hashCode ^
      driverName.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, LocationMessage) ||
      other is LocationMessage &&
          runtimeType == other.runtimeType &&
          senderId == other.senderId &&
          recipientId == other.recipientId &&
          ambulancePosition == other.ambulancePosition &&
          patientPosition == other.patientPosition &&
          patientName == other.patientName &&
          driverName == other.driverName;

  @override
  String toString() => '''
  recipientId :$recipientId , 
  senderId $senderId, 
  ambulancePosition $ambulancePosition,
  paitientPosition $patientPosition,
  patientName $patientName,
  driverName $driverName
  ''';

  LocationMessageEntity toEntity() => LocationMessageEntity(
      this.senderId,
      this.recipientId,
      this.ambulancePosition,
      this.patientPosition,
      this.patientName,
      this.driverName);

  static LocationMessage formEntity(LocationMessageEntity entity) {
    return LocationMessage(
        senderId: entity.senderId,
        recipientId: entity.recipientId,
        ambulancePosition: entity.ambulancePosition,
        patientPosition: entity.patientPosition,
        patientName: entity.patientName,
        driverName: entity.driverName,
    );
  }
}
