import 'dart:convert';

import 'package:chatter/Server/ServerConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  final Function(int) loginSuccess; // добавьте тип аргумента

  const LoginPage({Key? key, required this.loginSuccess}) : super(key: key);



  @override
  _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  Map<String, dynamic> res = {};
  final storage = const FlutterSecureStorage();
  var body = "";
  bool vis = true;

  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
  dynamic returnLoginSuccess (){
    return widget.loginSuccess;
  }
  Future<bool> postReg() async {
    print('${ServerConfig.ip}/api/auth/login');
    final response = await http.post(

      Uri.parse('${ServerConfig.ip}/api/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
      await storage.write(key: 'accessToken', value: res['accessToken']);
      widget.loginSuccess(1);

    } else {
      setState(() {
        body = "Ошибка при авторизации";
      });
    }
    return response.statusCode == 200;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Авторизоваться'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Имя пользователя',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите имя пользователя';
                  }
                  if (value.length < 6) {
                    return 'Имя пользователя должен быть не менее 6 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(!vis ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        vis = !vis;
                      });
                    },
                  ),
                ),
                obscureText: vis,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 6) {
                    return 'Пароль должен быть не менее 6 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Text(body),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if(await postReg()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Авторизация выполнена')),
                      );
                      Navigator.of(context).pushNamed('/');

                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Логин или пароль неправильный'))
                      );
                    }
                  }
                },
                child: const Text('Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}