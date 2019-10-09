import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ksars_smart/model/LocationMessage.dart';
import 'package:ksars_smart/repository/firebase_repository.dart';
import 'package:ksars_smart/utils/shared_pref.dart';
import './bloc.dart';

class LocationChannelBloc
    extends Bloc<LocationChannelEvent, LocationChannelState> {
  FirebaseRepository _repository;
  StreamSubscription _locationMessageStreamSubsription;

  String _channelId;

  LocationChannelBloc({FirebaseRepository repository})
      : assert(repository != null),
        _repository = repository;


  @override
  LocationChannelState get initialState => LocationLoading();

  @override
  Stream<LocationChannelState> mapEventToState(
    LocationChannelEvent event,
  ) async* {
    if (event is ConfirmLocationChannelCreate) {
      yield* _mapConfirmLocationChannelCreateToState(event);
    } else if (event is LocationUpdated) {
      yield* _mapLocationUpdatedToState(event);
    } else if (event is LoadLocationMessage) {
      yield* _mapOfLoadLocationMessageToState();
    }else if(event is UpdateLocation){
      yield* _mapOfUpdateLocation(event);
    }
  }

  Stream<LocationChannelState> _mapConfirmLocationChannelCreateToState(
      ConfirmLocationChannelCreate event) async* {
    await _repository.getCreateLocationChannel(
        otherUID: event.otherUID,
        onComplete: (channelId) async {
          print('ChannelId $channelId');
          await SharedPref.setChannelId(channelId: channelId);
          await _repository.shareLocationMessage(
              locationMessage: LocationMessage(
                  senderId: event.otherUID,
                  isFlag: event.isFlag,
                  channelId: channelId,
                  locationChannelUserIds: [event.currentUID,event.otherUID],
                  recipientId: event.currentUID,
                  driverName: event.driverName,
                  patientName: event.patientName,
                  patientPosition: event.patientPosition,
                  ambulancePosition: event.ambulancePosition),
              channelId: channelId);
          setChannelId(channelId: channelId);
          _locationMessageStreamSubsription?.cancel();
          _locationMessageStreamSubsription = _repository
              .locationMessages()
              .listen((locationMessages) {
            dispatch(LocationUpdated(locationMessages: locationMessages));
          });
//          _locationMessageStreamSubsription?.cancel();
//          _locationMessageStreamSubsription = _repository
//              .locationMessages(channelId: channelId)
//              .listen((locationMessages) {
//            dispatch(LocationUpdated(locationMessages: locationMessages));
//          });
        });
  }

  Stream<LocationChannelState> _mapLocationUpdatedToState(
      LocationUpdated event) async* {
    yield LocationLoaded(locationMessage: event.locationMessages);
  }

  Stream<LocationChannelState> _mapOfLoadLocationMessageToState() async* {

    _locationMessageStreamSubsription?.cancel();
    _locationMessageStreamSubsription = _repository
        .locationMessages()
        .listen((locationMessages) {
      dispatch(LocationUpdated(locationMessages: locationMessages));
    });

//    _repository.getChannelIds().listen((ids){
//      ids.forEach((channelIds){
//        _locationMessageStreamSubsription = _repository
//            .locationMessages(channelId: channelIds)
//            .listen((locationMessages) {
//          dispatch(LocationUpdated(locationMessages: locationMessages,channelIds: ids));
//        });
//      });
//    });


  }

 Stream<LocationChannelState> _mapOfUpdateLocation(UpdateLocation event) async*{
   await _repository.updateLocation(ambulanceLocation: event.ambulanceLocation,channelId: event.channelId,isFlag: event.isFlag);
 }

  @override
  void dispose() {
    _locationMessageStreamSubsription?.cancel();
    super.dispose();
  }
  void setChannelId({String channelId}){
    this._channelId=channelId;
  }
  String getChannelId(){
    return _channelId;
  }
}
