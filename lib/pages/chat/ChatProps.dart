import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chatter/Server/ServerConfig.dart';
import 'package:chatter/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../theme.dart';


class Message{
  String from;
  String text;
  DateTime dateSend;
  Message({required this.from, required this.text, required this.dateSend});
  Map<String, dynamic> toJson() => {
    'text': text,
    'from': from,
  };
}

class SendMessage{
  String from;
  String text;
  String? roomId;
  SendMessage({required this.from, required this.text, required this.roomId});
  Map<String, dynamic> toJson() => {
    'text': text,
    'from': from,
    'roomId': roomId,
  };

}

class ChatProps extends StatefulWidget {
  var buildContext ;
  User me;
  var token;
  User friend;
  ChatProps(this.buildContext, this.me, this.friend, this.token);

  @override
  _ChatPropsState createState() => _ChatPropsState();
}

class _ChatPropsState extends State<ChatProps> {

  final TextEditingController _textEditingController = TextEditingController();
  final List<Message> _messages = [];
  static const storage = FlutterSecureStorage();
  Future<void> getMessages() async {
    final response = await http.get(
      Uri.parse(
          '${ServerConfig.ip}/api/rooms/getMessages/${widget.me.rooms?[widget.friend.username]}'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      setState(() {
        // Используем map() для извлечения поля "text" из каждого объекта
        final messages = data.map((item) => Message(
          from: item['from'] as String,
          text: item['text'] as String,
          dateSend: DateTime.parse(item['dateSend']),
        )).toList();
        _messages.addAll(messages);
      });
    }
  }

  void _sendMessage() {
    if (client.connected) {
      print('connect');
      try {
        client.send(
          destination: '/app/chat',
          headers: <String, String>{
            'roomId': '${widget.me.rooms![widget.friend.username]}',
          },
          body: json.encode(SendMessage(
              from: widget.me.username,
              text: _textEditingController.text,
              roomId: widget.me.rooms![widget.friend.username])
              .toJson()),
        );
        setState(() {
          _messages.add(Message(
              from: widget.me.username,
              text: _textEditingController.text,
              dateSend: DateTime.now())
          );
          _textEditingController.text = "";
        });

      }
      catch (e) {
        print(e);
      }
    }
    else {
      print('not connected');
    }
  }
  late StompClient client;

  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  Future<void> ifElkhan() async {
    if(widget.friend.username == 'kilagorilla'){
      audioPlayer.open(Audio('assets/elkhan.mp3'));
    }
  }

  void onConnected(StompFrame frame){
    client.subscribe(
      destination: '/room/${widget.me.rooms![widget.friend.username]}', // Подписка на конкретное место назначения (destination)
      callback: (StompFrame frame) {
        var data = json.decode(frame.body!);
        Message message = Message(from: data['from'], text: data['text'], dateSend: DateTime.parse(data['dateSend']));
        setState(() {
          message.from != widget.me.username ? _messages.add(message) : '';
        });
      },
    );
  }
  @override
  void initState()  {
    super.initState();
    ifElkhan();
    client = StompClient(
        config: StompConfig(
          onConnect: onConnected,

          url: '${ServerConfig.wsIp}/ws?access_token=${widget.token}',
          onWebSocketError: (dynamic error) => print(error.toString()),
          stompConnectHeaders: {
            'login': 'someuserlogin',
            'passcode': 'somepassword'
          },
        ));
    client.activate();



    getMessages();
  }


  @override
  void dispose() {
    // _channel.sink.close();
    audioPlayer.stop();
    client.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.friend.profilePhoto),
              ),
              SizedBox(width: 8.0),
              Text(widget.friend.username),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(widget.buildContext);
            },
          ),
        ),
        resizeToAvoidBottomInset: true,
        body:
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.friend.username == 'kilagorilla' ? 'assets/elkhan.jpg' : 'assets/chat_background.jpg'),
              fit: BoxFit.fitHeight,
            ),
          ),
          child: Column(
            children: [

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child:ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      bool isMe = _messages[index].from == widget.me.username;

                      return Container(
                        margin: EdgeInsets.only(bottom: 3),
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Stack(
                          children: [
                            IntrinsicWidth(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isMe ? Colors.blueGrey : Colors.deepPurple[700],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                margin: !isMe ? EdgeInsets.only(left: 10) : EdgeInsets.only(right:10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                                      child: Container(
                                        constraints: BoxConstraints(maxWidth: 160),
                                        child:
                                        Text(
                                          _messages[index].text,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 0.5), // Отступ между текстами
                                    Align(
                                      alignment: Alignment.bottomRight, // Выравнивание текста справа внизу
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 3.0, bottom: 3.0), // Отступы справа и снизу
                                        child: Text(
                                          DateFormat.Hm().format(_messages[index].dateSend),
                                          style: TextStyle(
                                              fontSize: 10
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),


                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _sendMessage();
                      },
                      child: Icon(Icons.send),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                        fixedSize: MaterialStateProperty.all<Size>(Size(50, 40)), // Установите нужные значения ширины и высоты
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

}
