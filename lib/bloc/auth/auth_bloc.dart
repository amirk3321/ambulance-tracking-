import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:ksars_smart/repository/firebase_repository.dart';
import './bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseRepository _repository;

  AuthBloc({FirebaseRepository repository})
      : assert(repository != null),
        _repository = repository;

  @override
  AuthState get initialState => UninitializedAuth();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AppStartedEvent) {
      yield* _mapAppStartedEventToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthState> _mapAppStartedEventToState() async* {
    try {
      var isSignIn = await _repository.isSignIn();
      if (isSignIn) {
        String uid = await _repository.getCurrentUID();
        yield AuthenticatedAuth(uid: uid);
      } else {
        yield UnAuthenticatedAuth();
      }
    } catch (_) {
      yield UnAuthenticatedAuth();
    }
  }

  Stream<AuthState> _mapLoggedInToState() async* {
    String uid = await _repository.getCurrentUID();
    yield AuthenticatedAuth(uid: uid);
  }

  Stream<AuthState> _mapLoggedOutToState() async* {
    yield UnAuthenticatedAuth();
  }
}
