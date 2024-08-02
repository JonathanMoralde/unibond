class GroupCallModel {
  String? id;
  String channel;
  String caller;
  String callerName;
  String groupName;
  String? groupPic;
  bool? active;
  List<String> members;
  List<String> joined;
  List<String> rejected;
  bool isVideoCall;
  GroupCallModel({
    required this.id,
    required this.channel,
    required this.caller,
    required this.callerName,
    required this.groupName,
    this.groupPic,
    required this.active,
    required this.members,
    required this.joined,
    required this.rejected,
    required this.isVideoCall,
  });
}
