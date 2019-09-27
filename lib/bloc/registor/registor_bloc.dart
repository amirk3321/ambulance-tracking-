import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:ksars_smart/repository/firebase_repository.dart';
import './bloc.dart';
import 'package:meta/meta.dart';

class RegistorBloc extends Bloc<RegistorEvent, RegistorState> {

  FirebaseRepository _repository;


  RegistorBloc({@required FirebaseRepository repository})
      : assert(repository != null),
        _repository = repository;

  @override
  RegistorState get initialState => InitialState();

  @override
  Stream<RegistorState> mapEventToState(
    RegistorEvent event,
  ) async* {
    if (event is Submitted) {
      yield* _mapSubmittedToState(event);
    }
  }
  Stream<RegistorState> _mapSubmittedToState(Submitted event) async* {
    yield LoadingState();

    try {
      await _repository
          .signUpWithEmailPassword(email: event.email,password: event.password);
      await _repository.getInitializedCurrentUser(
        email: event.email,
        name: event.name,
        type: event.type,
        phone: event.phoneNumber,
        profile: event.profile,
        point: event.point
      );
      yield SuccessState();
    } catch (_) {
      yield FailureState();
    }
  }
}
