import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:ksars_smart/repository/firebase_repository.dart';
import './bloc.dart';
import 'package:meta/meta.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  FirebaseRepository _repository;

  LoginBloc({@required FirebaseRepository repository})
      : assert(repository != null),
        _repository = repository;

  @override
  LoginState get initialState => InitialState();

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is Submitted){
      yield* _mapSubmittedToState(event);
    }
  }

  Stream<LoginState> _mapSubmittedToState(Submitted event)async*{
    yield LoadingState();

    try{
      await _repository.signInWithEmailPassword(email: event.email,password: event.password);
      yield SuccessState();
    }catch(e){
      yield FailureState();
    }
  }
}
