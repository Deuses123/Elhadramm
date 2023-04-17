import 'package:chatter/Server/ServerConfig.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главное'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: controller, decoration: InputDecoration(labelText: 'Server IP'),),
            ElevatedButton(onPressed: (){

              ServerConfig.ip = 'http://${controller.text}:9999';
              ServerConfig.wsIp = 'ws://${controller.text}:9999';
              print(ServerConfig.ip);

            }, child: Text('Задать значение сервера')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/Login');
              },
              child: const Text("Авторизация"),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/Register');
              },
              child: const Text("Регистрация"),
            ),
          ],
        ),
      ),
    );
  }
}
