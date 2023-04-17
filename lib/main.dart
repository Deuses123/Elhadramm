// импортируйте необходимые библиотеки
import 'package:chatter/Server/ServerConfig.dart';
import 'package:chatter/pages/Authority/LoginPage.dart';
import 'package:chatter/pages/Authority/RegisterPage.dart';
import 'package:chatter/pages/MainPage.dart';
import 'package:chatter/screens/home_screens.dart';
import 'package:chatter/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasAccessToken = false;
  ServerConfig serverConfig = ServerConfig();
  Future<void> checkToken() async {
    const storage = FlutterSecureStorage();
    final String? token = await storage.read(key: 'accessToken');

    final response = await http.get(
      Uri.parse('${ServerConfig.ip}/api/auth/check'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // если токен доступа есть, устанавливаем hasAccessToken в true
      setState(() {
        hasAccessToken = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // проверьте наличие токена доступа при запуске приложения
    checkToken();
  }

  Future<void> loginSuccess(var state) async {
    setState(() {
      hasAccessToken = state == 1 ? true : false;
    });

    runApp(MyApp());
  }

  @override
  Widget build(BuildContext context) {
    if (hasAccessToken) {
      // если у нас есть токен, открываем страницу Pages
      return MaterialApp(
        theme: AppTheme.dark(),
        title: 'Elhagram',
        themeMode: ThemeMode.dark,
        home: HomeScreen(
          loginSuccess: loginSuccess,
        ),
      );
    }


    else {
      // если у нас нет токена, открываем страницу входа
      return MaterialApp(
        title: 'Elhagram',
        theme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        routes: {
          '/Login': (context) => LoginPage(loginSuccess: loginSuccess),
          '/Register': (context) => RegisterPage(loginSuccess: loginSuccess),
        },
        home: const MainPage(),
      );
    }
  }
}
