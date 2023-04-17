import 'dart:convert';
import 'package:chatter/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../Server/ServerConfig.dart';

void main() => runApp(ContactsPage());

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<User> users = [];
  final TextEditingController _textEditingController = TextEditingController();
  static const storage = FlutterSecureStorage();

  Future<void> getUsers() async {
    final response = await http.get(
      Uri.parse(
          '${ServerConfig.ip}/api/users/findFriendByName?name=${_textEditingController.text}'),
      headers: <String, String>{
        'Authorization':
        'Bearer ${await storage.read(key: 'accessToken')}',
      },
    );
    if (response.statusCode == 200) {
      if (response.body != 0) {
        final data = jsonDecode(response.body) as List;

        setState(() {
          users = data
              .map(
                (item) => User(
              username: item['username'] as String,
              profilePhoto: item['profilePhoto'] as String,
            ),
          )
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Поиск'),
        ),
        body: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'Введите текст для поиска',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  getUsers();
                },
                child: Text('Поиск'),
              ),
              SizedBox(height: 20.0),
              Text(
                'Результаты поиска:',
                style: TextStyle(fontSize: 18.0),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: GestureDetector(
                          child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30.0,
                                  backgroundImage: NetworkImage(users[index].profilePhoto!='' ? '${ServerConfig.ip}/getFile?path=${users[index].profilePhoto}' : "https://avatarfiles.alphacoders.com/146/146674.png"),
                                ),
                                SizedBox(width: 40,),
                                Text(users[index].username, style: TextStyle(fontSize: 12),)
                              ]
                          ),
                          onTap: () async {
                            http.get(Uri.parse("${ServerConfig.ip}/addFriend?username=${users[index].username}"), headers: <String, String> {'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}'})
                                .then((value) => {
                                  _showPopupMessage(context, value.body)
                                });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showPopupMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Статус'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }
}

