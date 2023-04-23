
class SignallingMessage {
  String type;
  String data;
  String senderName;

  SignallingMessage(this.type, this.data, this.senderName);

  Map<String, dynamic> toJson() => {
    'type': type,
    'data': data,
    'senderName': senderName,
  };
}