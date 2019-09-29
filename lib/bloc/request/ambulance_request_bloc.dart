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

  StreamSubscription _streamSubscription;


  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  AmbulanceRequestState get initialState => AmbulanceRequestLoading();

  @override
  Stream<AmbulanceRequestState> mapEventToState(
    AmbulanceRequestEvent event,
  ) async* {
    if (event is AmbulanceRequest){
     yield* _mapAmbulanceRequestToState(event);
    }else if(event is AmbulanceRequestCancel){
      yield* _mapAmbulanceRequestCancelToState(event);
    }else if (event is AmbulanceRequestLoad){
      yield* _mapAmbulanceRequestLoadToState(event);
    }else if(event is AmbulanceRequestUpdated){
      yield* _mapAmbulanceRequestUpdatedToState(event);
    }
  }

 Stream<AmbulanceRequestState> _mapAmbulanceRequestToState(AmbulanceRequest event) async*{
    await _repository.getAmbulancePickRequest(otherUID: event.otherUID,patient: event.patient);
 }

  Stream<AmbulanceRequestState> _mapAmbulanceRequestCancelToState(AmbulanceRequestCancel event) async*{
    await _repository.getDeleteAmbulancePickRequest(otherUID: event.otherUID);
  }

  Stream<AmbulanceRequestState> _mapAmbulanceRequestLoadToState(AmbulanceRequestLoad event) async*{
    print("testCurrentUid ${event.currentUID}");
    _streamSubscription?.cancel();
    _streamSubscription=_repository.patientList(event.currentUID).listen((patient){
      dispatch(AmbulanceRequestUpdated(patient: patient));
    });
  }

  Stream<AmbulanceRequestState> _mapAmbulanceRequestUpdatedToState(AmbulanceRequestUpdated event) async*{
    yield AmbulanceRequestLoaded(event.patient);
  }





}
