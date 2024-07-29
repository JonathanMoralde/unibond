class CallModel {
  String? id;
  String channel;
  String caller;
  String callerName;
  String? callerPic;
  String called;
  bool? active;
  bool? accepted;
  bool? rejected;
  bool? connected;
  bool isVideoCall;
  CallModel({
    required this.id,
    required this.channel,
    required this.caller,
    required this.callerName,
    this.callerPic,
    required this.called,
    required this.active,
    required this.accepted,
    required this.rejected,
    required this.connected,
    required this.isVideoCall,
  });
}
