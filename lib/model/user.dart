import 'package:ksars_smart/model/user_entity.dart';

class User {
  final String email;
  final String name;
  final String type;
  final String uid;
  final String phone;
  final String profile;

  User(
      {this.email = '',
      this.name = '',
      this.type = '',
      this.phone = '',
      this.uid = '',
      this.profile = ''});

  User copyWith({
    String email,
    String name,
    String type,
    String uid,
    String phone,
    String profile,
  }) {
    return User(
      email: email ?? this.email,
      name: name ?? this.name,
      type: type ?? this.type,
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      profile: profile ?? this.profile,
    );
  }

  @override
  int get hashCode =>
      email.hashCode ^
      name.hashCode ^
      type.hashCode ^
      uid.hashCode ^
      phone.hashCode ^
      profile.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          name == other.name &&
          type == other.type &&
          uid == other.uid &&
          phone == other.phone &&
          profile == other.profile;

  @override
  String toString() =>
      'User { email: $email, name: $name, uid: $uid profile $profile phone $phone type $type}';


  UserEntity toEntity(){
    return UserEntity(email,name,type,uid,phone,profile);
  }
  static User fromEntity(UserEntity entity){
    return User(
      email: entity.email,
      name: entity.name,
      type: entity.type,
      uid: entity.uid,
      phone: entity.phone,
      profile: entity.profile,
    );
  }
}
