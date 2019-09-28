

import 'package:ksars_smart/model/user.dart';

abstract class RepoBase{
  Future<void> signUpWithEmailPassword({String email,String password});
  Future<void> signInWithEmailPassword({String email,String password});
  Future<bool> isSignIn();
  Future<String> getCurrentUID();
  Future<void> getInitializedCurrentUser();
  Future<void> onUpdateUserInfo({String name,String profile,String phoneNumber,});
  Stream<List<User>> users();
  Future<void> getCreateLocationChannel({String otherUID,Function onComplete(String locationChannelId)});
}