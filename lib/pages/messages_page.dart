import 'dart:convert';

import 'package:chatter/Server/ServerConfig.dart';
import 'package:chatter/pages/chat/ChatProps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/User.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late List<User> _users;
  bool _loading = true;
  static const storage = FlutterSecureStorage();
  var me;
  var token;
  bool _meLoading = true;
  Future<void> giveMe() async {
    token = await storage.read(key: 'accessToken');
    var res = await http.get(Uri.parse('${ServerConfig.ip}/api/users/me'), // Используем await для ожидания выполнения запроса
        headers: <String, String>{
          'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
        }
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body); // Декодируем тело ответа в JSON
      me = User.fromJson(data); // Создаем экземпляр класса User из декодированных данных
      print(me.username);
      setState(() {
        _meLoading=false;
      });
    } else {
      throw Exception('Failed to get current user');
    }
  }

  Future<void> _getUsers() async {
    const storage = FlutterSecureStorage();

    try {
      final response = await http.get(Uri.parse('${ServerConfig.ip}/giveMeFriends'), headers: <String, String>{
        'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        _users = data.map((json) => User.fromJson(json)).toList();
        setState(() { // добавить await здесь
          _loading = false;
        });
      } else {
        throw Exception('Failed to get users');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to get users');
    }
  }


  @override
  void initState() {
    super.initState();
    _getUsers();
    giveMe();
  }
  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
      child: CircularProgressIndicator(),
    )
        : ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: GestureDetector(
            onTap: () {
              !_meLoading
                  ? _openNewPage(context, index)
                  : Center(
                child: CircularProgressIndicator(),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10), // Увеличение отступов контейнера
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    // Виджет круглого аватара
                    radius: 45,
                    backgroundImage: NetworkImage(user.profilePhoto),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        user.username,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  void _openNewPage(BuildContext context, int index) {
    if(token.toString().length > 3) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            // Создаем новую страницу с веб-браузером
            return MaterialApp(
                initialRoute: '/',
                home: ChatProps(context, me, _users[index], token)
            );
          },
        ),
      );
    }
  }
}
