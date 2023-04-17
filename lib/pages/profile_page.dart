import 'dart:convert';
import 'dart:io';
import 'package:chatter/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../Server/ServerConfig.dart';

class ProfilePage extends StatefulWidget {
  final Function(int) loginSuccess;

  ProfilePage({required this.loginSuccess});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();
  String photoUrl = '';
  String name = '';
  String lastName = '';
  bool isEditing = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  late User user = User(username: '', profilePhoto: '');
  var data;
  Future<void> init() async {
    var response = await http.get(Uri.parse("${ServerConfig.ip}/api/users/me"), headers: <String, String> {
      'Authorization': 'Bearer ${await storage.read(key: 'accessToken')}'
    });
    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
        user = User(
          username: data['username'],
          profilePhoto: data['profilePhoto'],
        );
        print(user.profilePhoto);
        photoUrl = user.profilePhoto;
      });
    } else {
      print('Failed to get user data. Error: ${response.reasonPhrase}');
    }
  }
  @override
  void initState() {
    init();
    super.initState();
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  name = nameController.text;
                  lastName = lastNameController.text;
                  isEditing = false;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _changeAvatar() async {
    final picker = ImagePicker();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Choose Image Source"),
        content: Column(
          children: [
            TextButton(
              child: Text("Camera"),
              onPressed: () async {
                Navigator.pop(context);
                final pickedFile = await picker.getImage(source: ImageSource.camera);

                var file;
                if(pickedFile!=null){
                  file = File(pickedFile.path);
                }
                final url = Uri.parse('${ServerConfig.ip}/api/users/addProfilePhoto');
                final request = http.MultipartRequest('POST', url);
                request.headers['Authorization'] = 'Bearer ${await storage.read(key: 'accessToken')}';

                request.files.add(
                    await http.MultipartFile.fromPath('file', file.path));
                final response = await request.send();

                setState(() {
                  init();
                });

              },
            ),
            TextButton(
              child: Text("Gallery"),
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                final pickedFile = await picker.getImage(source: ImageSource.gallery);
                var file;
                if(pickedFile!=null) {
                  file = File(pickedFile.path);
                }
                final url = Uri.parse('${ServerConfig.ip}/api/users/addProfilePhoto');
                final request = http.MultipartRequest('POST', url);
                request.headers['Authorization'] = 'Bearer ${await storage.read(key: 'accessToken')}';
                request.files.add(await http.MultipartFile.fromPath('file', file.path));
                final response = await request.send();
                setState(() {
                  init();
                });

              },
            ),
          ],
        ),
      ),
    );
  }









  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Фоновое изображение
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/chat_background.jpg'), // Здесь указывается путь к вашему изображению
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Контент профильной страницы
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    photoUrl.isNotEmpty ?
                    "${ServerConfig.ip}/flutter/getFileForProfile?path=$photoUrl" : 'https://meshok-monet.net/image/catalog/avatars/avatar.jpg', // Здесь может быть ваше изображение профиля
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '$name $lastName',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    _showEditDialog();
                  },
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // Цвет
                    onPrimary: Colors.white, // Цвет текста
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _changeAvatar();
                  },
                  child: Text(
                    'Change Avatar',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // Цвет кнопки
                    onPrimary: Colors.white, // Цвет текста
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      storage.write(key: 'accessToken', value: '');
                      widget.loginSuccess(0);
                    });
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
