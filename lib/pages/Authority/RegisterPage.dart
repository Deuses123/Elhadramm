import 'dart:convert';
import 'package:chatter/Server/ServerConfig.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  final Function(int) loginSuccess; // добавьте тип аргумента

  const RegisterPage({Key? key, required this.loginSuccess}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  Map<String, dynamic> res = Map();
  final storage = const FlutterSecureStorage();
  var body = "";
  bool vis = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<bool> postReg() async {
    final response = await http.post(
      Uri.parse('${ServerConfig.ip}/api/auth/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
      await storage.write(key: 'accessToken', value: res['accessToken']);
      widget.loginSuccess(1);

    } else {
      setState(() {
        body = "Ошибка при регистрации";
      });
    }
    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Зарегистрироваться'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  if (!value.contains('@')) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
              ),

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
                      icon: Icon(
                          !vis ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          vis = !vis;
                        });
                      }
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
              TextFormField(
                controller: _repeatPasswordController,
                decoration: InputDecoration(
                  labelText: 'Повторный пароль',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                      icon: Icon(
                          !vis ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          vis = !vis;
                        });
                      }
                  ),

                ),

                obscureText: vis,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Повторите пароль';
                  }
                  if (value != _passwordController.text) {
                    return 'Пароли не совпадают';
                  }
                  if (value.length < 6) {
                    return 'Пароль должен быть не менее 6 символов';
                  }
                  return null;
                },
              ),

              const SizedBox(
                height: 16.0,
              ),
              Text(body),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _repeatPasswordController.text ==
                          _passwordController.text) {
                    if (await postReg()) {
                      Navigator.of(context).pushNamed('/');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Регистрация выполнена')),
                      );
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Регистрация не выполнена')),
                      );
                    }
                  }
                },
                child: const Text('Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}