import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class LocationMessageEntity extends Equatable{
  final String senderId;
  final String recipientId;
  final GeoPoint point;

  LocationMessageEntity(this.senderId, this.recipientId, this.point);

  Map<String, Object> toJson() =>
      {'senderId': senderId, 'recipientId': recipientId, 'point': point};

  static LocationMessageEntity fromJson(Map<String, Object> json) =>
      LocationMessageEntity(
        json['senderId'] as String,
        json['recipientId'] as String,
        json['point'] as GeoPoint,
      );

  static LocationMessageEntity fromDocumentSnapshot(
          DocumentSnapshot snapshot) =>
      LocationMessageEntity(snapshot.data['senderId'],
          snapshot.data['recipientId'], snapshot.data['point']);

  Map<String, Object> toDocument() =>
      {'senderId': senderId, 'recipientId': recipientId, 'point': point};
}
