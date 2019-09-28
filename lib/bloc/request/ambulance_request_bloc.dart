import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:ksars_smart/repository/firebase_repository.dart';
import './bloc.dart';

class AmbulanceRequestBloc
    extends Bloc<AmbulanceRequestEvent, AmbulanceRequestState> {
  FirebaseRepository _repository;

  AmbulanceRequestBloc({FirebaseRepository repository})
      : assert(repository != null),
        _repository = repository;

  @override
  AmbulanceRequestState get initialState => InitialAmbulanceRequestState();

  @override
  Stream<AmbulanceRequestState> mapEventToState(
    AmbulanceRequestEvent event,
  ) async* {
    if (event is AmbulanceRequest){
     yield* _mapAmbulanceRequestToState(event);
    }else if(event is AmbulanceRequestCancel){
      yield* _mapAmbulanceRequestCancelToState(event);
    }
  }

 Stream<AmbulanceRequestState> _mapAmbulanceRequestToState(AmbulanceRequest event) async*{
    await _repository.getAmbulancePickRequest(otherUID: event.otherUID);
 }

  Stream<AmbulanceRequestState> _mapAmbulanceRequestCancelToState(AmbulanceRequestCancel event) async*{
    await _repository.getDeleteAmbulancePickRequest(otherUID: event.otherUID);
  }
}
