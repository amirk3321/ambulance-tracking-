
class CommunicationChannel{
  final List<String> userIds;

  CommunicationChannel({this.userIds=const <String>[]});

  Map<String,Object> toDocument() =>{
    'userIds' : userIds
  };
}