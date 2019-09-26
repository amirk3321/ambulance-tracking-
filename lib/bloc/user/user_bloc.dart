import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:ksars_smart/repository/firebase_repository.dart';
import './bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseRepository _repository;

  UserBloc({FirebaseRepository repository})
      : assert(repository != null),
        _repository = repository;

  StreamSubscription _streamSubscription;

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
  @override
  UserState get initialState => UsersLoading();

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is LoadUser) {
      yield* _mapLoadUserToState();
    }else if (event is UsersUpdated) {
      yield* _mapUsersUpdatedToState(event);
    } else if (event is UpdateUser) {
      yield* _mapUpdateUserToState(event);
    }
  }
  Stream<UserState> _mapLoadUserToState() async* {
    _streamSubscription?.cancel();
    _streamSubscription = _repository.users().listen((user) {
      dispatch(UsersUpdated(user: user));
    });
  }
  Stream<UserState> _mapUsersUpdatedToState(UsersUpdated event) async* {
    yield UsersLoaded(event.user);
  }
  Stream<UserState> _mapUpdateUserToState(UpdateUser event) async* {
    await _repository.onUpdateUserInfo(
      profile: event.user.profile,
      phoneNumber: event.user.phone,
      name: event.user.name,
      uid: event.user.uid,
      point: event.point
    );
  }
}
