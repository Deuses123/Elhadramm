import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SUAuthorityPage extends StatefulWidget {
  @override
  _SUAuthorityPageState createState() => _SUAuthorityPageState();
}

class _SUAuthorityPageState extends State<SUAuthorityPage> {
  var storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;

  Future<void> authority() async {
    print(_email);
    print(_password);
    try {
      var res = await http.post(
        Uri.parse('https://api.satbayev.hero.study/v1/users/login?lang=ru'),
        body: <String, String>{
          'email': _email,
          'pass': _password,
       },
      );
      if (res.statusCode == 200) {
          var pay = jsonDecode(res.body);
          print(pay['token']);
          var cookie = jsonEncode(pay['identityCookie']);
          storage.write(key: 'su_token', value: pay['token']);
          storage.write(key: 'cookie', value: cookie);

      } else {
        print(res.statusCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('E-mail или пароль не правильный'),
          ),
        );
        throw Exception('Ошибка запроса: ${res.statusCode}');
      }
    } catch (e) {
      print('Ошибка: $e');
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Авторизация'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Введите ваш email',
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Введите email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Введите пароль',
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Введите пароль';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    authority();
                  }
                },
                child: Text('Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
