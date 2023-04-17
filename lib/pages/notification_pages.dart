import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../Server/ServerConfig.dart';

class NotificationsPage extends StatefulWidget {

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = true;

  var notes;
  FlutterSecureStorage storage = FlutterSecureStorage();
  Future<void> downloadNotes() async {
    setState(() {
      isLoading = true;
    });

    await http.get(
      Uri.parse('${ServerConfig.ip}/api/notification/giveNotifications'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}'
      },
    ).then((response) async {
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          notes = (jsonData as List<dynamic>)
              .map((item) => Note.fromJson(item))
              .toList();
          isLoading = false; // Устанавливаем состояние загрузки в false
        });
      } else {
        // Обработка ошибки, если требуется
      }
    });
  }
  
  Future<void> addFriend(Note note) async {
    await http.post(Uri.parse('${ServerConfig.ip}/api/notification/putNotification'), headers: <String, String>{
      'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}'
    }, body: note.toJson()).then((value) => downloadNotes());
  }
  Future<void> deleteNote(Note note) async {
    await http.post(Uri.parse('${ServerConfig.ip}/api/notification/putNotification'), headers: <String, String>{
      'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}'
    }, body: note.toJson()).then((value) =>  downloadNotes());
  }

  void initState(){
    super.initState();
    try {
      downloadNotes();
    } catch (error) {
      print('Ошибка при загрузке уведомлений: $error');
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Уведомления'),
        ),
        body: isLoading
            ? CircularProgressIndicator() // Индикатор загрузки
            : ListView.builder(
          itemCount: notes.length,
          itemBuilder: (BuildContext context, int index) {
            return
              GestureDetector(
                child: Card(
                  elevation: 4, // добавляем поднятие (эффект тени) для виджета Card
                  child: Padding(
                    padding: EdgeInsets.all(16.0), // добавляем отступы для внутреннего содержимого
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // выравниваем содержимое по левому краю
                      children: [
                        Text(
                          notes[index].type == 'FRIEND_OFFER' ? 'Заявка в добавление в друзья' : '',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8), // добавляем промежуток между виджетами
                        Text(
                          '${notes[index].fromCurrentUser} хочет вас добавить в друзья',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16), // добавляем больший промежуток между виджетами
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // выравниваем кнопки по краям
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                notes[index].message = 'YES';
                                addFriend(notes[index]);
                              },
                              icon: Icon(Icons.check),
                              label: Text("Добавить в друзья"),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                notes[index].message = 'NO';
                                deleteNote(notes[index]);
                              },
                              icon: Icon(Icons.clear),
                              label: Text("Отклонить"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );

          },
        )
    );
  }
}


class Note {
  String id;
  String type;
  String message;
  String fromCurrentUser;
  String fromOtherUser;

  Note(
      this.id, this.type, this.message, this.fromCurrentUser, this.fromOtherUser);
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      json['id'] as String,
      json['type'] as String,
      json['message'] != null ? json['message'] as String : '',
      json['fromCurrentUser'] as String,
      json['fromOtherUser'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'fromCurrentUser': fromCurrentUser,
      'fromOtherUser': fromOtherUser,
    };
  }
}

