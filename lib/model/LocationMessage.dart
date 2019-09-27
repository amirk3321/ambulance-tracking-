import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ksars_smart/model/LocationMessageEntity.dart';

class LocationMessage {
  final String senderId;
  final String recipientId;
  final GeoPoint point;

  LocationMessage({this.senderId = '', this.recipientId = '', this.point});



  LocationMessage copyWith({
    String senderId,
    String recipientId,
    GeoPoint point,
  }) {
    return LocationMessage(
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      point: point ?? this.point,
    );
  }

  @override
  // TODO: implement hashCode
  int get hashCode => senderId.hashCode ^ recipientId.hashCode ^ point.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, LocationMessage) ||
      other is LocationMessage &&
          runtimeType == other.runtimeType &&
          senderId == other.senderId &&
          recipientId == other.recipientId &&
          point == other.point;

  @override
  String toString() => '''
  recipientId :$recipientId , 
  senderId $senderId, 
  point $point
  ''';

  LocationMessageEntity toEntity() =>
      LocationMessageEntity(this.senderId,this.recipientId,this.point);

  static LocationMessage formEntity(LocationMessageEntity entity){
    return LocationMessage(
      senderId: entity.senderId,
      recipientId: entity.recipientId,
      point: entity.point
    );
  }

}
