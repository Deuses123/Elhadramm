import 'dart:convert';

import 'package:chatter/models/User.dart';
import 'package:chatter/pages/SU/Event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../Server/ServerConfig.dart';
import '../models/SignallingMessage.dart';
import 'package:http/http.dart' as http;
class CallPage extends StatefulWidget {
  final String token;
  final User me;
  final User friend;
  const CallPage({required this.token, required this.me, required this.friend});

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  late StompClient client;
  List<User> users = [];
  var friendName = TextEditingController();
  RTCPeerConnection? _peerConnection;

  void _sendMessage(RTCSessionDescription offer) async {
    _peerConnection?.setLocalDescription(offer);
    print(offer.type);
    if (_peerConnection != null) {
      if (client.connected) {
        try {
          client.send(
            destination: '/app/createOffer',
            headers: <String, String>{
              'roomId': 'sdp:${widget.me.rooms![widget.friend.username]}',
            },
            body: json.encode(SignallingMessage('offer', offer.sdp!, widget.me.username)),
          );
          setState(() {});
        } catch (e) {
          print(e);
        }
      } else {
        print('not connected');
      }
    } else {
      print('_peerConnection is not initialized');
    }
  }


  void onConnected(StompFrame frame){
    print(widget.me.rooms![widget.friend.username]);
    client.subscribe(
      destination: '/room/sdp:${widget.me.rooms![widget.friend.username]}',
      callback: (StompFrame frame) {
        var date = jsonDecode(frame.body!);
        if(date['senderName'] != widget.me.username) {
          print(date);
          RTCSessionDescription offer = RTCSessionDescription(
              date['data'], date['type']);
          _createAnswer(offer);
        }
      },
    );
  }

  Future<void> _createAnswer(RTCSessionDescription offer) async {
    if(offer.type == 'offer') {
      try {
        await _peerConnection?.setRemoteDescription(offer);
        final answer = await _peerConnection?.createAnswer();

        await _peerConnection?.setLocalDescription(answer!);
        if (answer?.sdp != null && answer != null) {
          final jsonMessage = jsonEncode(<String, dynamic>{'type': 'answer',
            'data': answer.sdp, 'senderName': widget.me.username});

          client.send(
            destination: '/app/createOffer',
            headers: <String, String>{
              'roomId': 'sdp:${widget.me.rooms![widget.friend.username]}',
            },
            body: jsonMessage,
          );
        }
      } catch (error) {
        print('Error creating answer: $error');
      }
    }
    else if(offer.type == 'answer'){
      setState(() async {
        await _peerConnection?.setRemoteDescription(offer);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initLocalCamera();
    _initRenderers();
    _createPeerConnection();
    client = StompClient(
        config: StompConfig(
            onConnect: onConnected,
            url: '${ServerConfig.wsIp}/ws?access_token=${widget.token}',
            onWebSocketError: (dynamic error) => print(error.toString())));
    client.activate();
  }
  Future<void> _initLocalCamera() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': false,
        'video': {
          'facingMode': 'user',
        },
      };

      MediaStream stream =
      await navigator.mediaDevices.getUserMedia(mediaConstraints);

      _localRenderer.srcObject = stream;
    } catch (e) {
      print('Error occurred while accessing media devices: $e');
    }
  }

  void _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();


  }

  Future<void> _createPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'}
      ]
    };

    _peerConnection = await createPeerConnection(configuration, {});

    _peerConnection?.onIceCandidate = (candidate) {
      print('onIceCandidate: $candidate');
    };

    _peerConnection?.onIceConnectionState = (state) {
      print('onIceConnectionState: $state');
    };

    _peerConnection?.onTrack = (event) {
      print('onTrack: ${event.streams}');
      _remoteRenderer.srcObject = event.streams[0];
      setState(() {

      });
    };

    try {
      MediaStream stream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
        },
      });

      stream.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, stream);
      });
      setState(() {
        _localRenderer.srcObject = stream;
      });
    } catch (e) {
      print('Error occurred while accessing media devices: $e');
    }


  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    client.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RTCVideoView(!_remoteRenderer.renderVideo ? _localRenderer : _remoteRenderer),
        ),
        Positioned(
          bottom: 88,
          right: 18,
          child: Container(
            width: 130,
            height: 230,
            child: RTCVideoView(_localRenderer),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 35,
          child: GestureDetector(
            onTap: () async {
              var offer = await _peerConnection?.createOffer({});
              _sendMessage(offer!);
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.black12
              ),
              child: Icon(Icons.phone_outlined, size: 50,color: Colors.white70,),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 140,
          child: GestureDetector(
            onTap: () async {
             _peerConnection?.close();
             _localRenderer.dispose();
             _remoteRenderer.dispose();
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.black12
              ),
              child: Icon(Icons.call_end_rounded, size: 50,color: Colors.white70,),
            ),
          ),
        ),
      ],
    );

  }
}









// ElevatedButton(
//   onPressed: () async {
//     final offer = await _peerConnection.createOffer({});
//     await _peerConnection.setLocalDescription(offer);
//     // Send offer to remote peer and wait for answer
//   },
//   child: const Text('Call'),
// ),