import 'dart:convert';

import 'package:chatter/pages/SU/Event.dart';
import 'package:chatter/pages/SU/WeekDay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Authority/SUAuthorityPage.dart';

class SuPage extends StatefulWidget {
  @override
  _SuPageState createState() => _SuPageState();
}

class _SuPageState extends State<SuPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  List<Schedule> schedules = [];


  @override
  void initState() {
    super.initState();
    reloadSubjects();
    _tabController = TabController(length: 6, vsync: this);
  }

  int dateTimeToUnix(DateTime dateTime) {
    return dateTime.toUtc().millisecondsSinceEpoch ~/ 1000;
  }

  var storage = FlutterSecureStorage();
  DateTime getLastMonday(DateTime dateTime) {
    final difference = dateTime.weekday - DateTime.monday;
    return dateTime.subtract(Duration(days: difference));
  }


  void reloadSubjects() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? preJson = prefs.getString('week_days');
    if(preJson == null) {
      var token = await storage.read(key: 'su_token');
      if(token != null){
        var begin = getLastMonday(getLastMonday(DateTime.now()));
        var UnixBegin = dateTimeToUnix(begin);

        DateTime end = DateTime(begin.year, begin.month, begin.day+6);
        var UnixEnd = dateTimeToUnix(end);


        var res = await http.get(
            Uri.parse('https://api.satbayev.hero.study/v1/schedule/list?beginTime=$UnixBegin&endTime=$UnixEnd&lang=ru546644'),
            headers: <String, String> {
              'Authorization': 'Bearer $token'
            }
        );

        if (res.statusCode == 200) {


          List<dynamic> scheduleJson = jsonDecode(res.body);

          for (var scheduleData in scheduleJson) {
            Schedule schedule = Schedule.fromJson(scheduleData);
            schedules.add(schedule);
          }


        } else {
          throw Exception('Failed to fetch schedules');
        }

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('week_days', res.body);
        setState(() {

        });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Вы не авторизованы в портале'),
            action: SnackBarAction(
              label: 'Авторизоваться',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SUAuthorityPage()),
                );
              },
            ),
          ),
        );
      }
    }
    else {
      List<dynamic> scheduleJson = jsonDecode(preJson);
      for (var scheduleData in scheduleJson) {
        Schedule schedule = Schedule.fromJson(scheduleData);
        schedules.add(schedule);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    schedules = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расписание'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Понедельник'),
            Tab(text: 'Вторник'),
            Tab(text: 'Среда'),
            Tab(text: 'Четверг'),
            Tab(text: 'Пятница'),
            Tab(text: 'Суббота'),
          ],
        ),
      ),
      body: schedules.length != 0 ? Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              schedules.length > 0 ? buildListView(0) : Container(),
              schedules.length > 1 ? buildListView(1) : Container(),
              schedules.length > 2 ? buildListView(2) : Container(),
              schedules.length > 3 ? buildListView(3) : Container(),
              schedules.length > 4 ? buildListView(4) : Container(),
              schedules.length > 5 ? buildListView(5) : Container(),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                reloadSubjects();
              },
              child: Icon(Icons.refresh),
              backgroundColor: Color(0x234952FF), // Цвет фона кнопки
            ),
          ),
        ],
      ) : FloatingActionButton(
        onPressed: () {
          reloadSubjects();
        },
        child: Icon(Icons.refresh),
        backgroundColor: Colors.white12, // Цвет фона кнопки
      ),
    );
  }

  Widget buildListView(int mainIndex) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: schedules[mainIndex].events.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 20,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "${DateTime.fromMillisecondsSinceEpoch(int.parse(schedules[mainIndex].events[index].beginTime) * 1000).toString().substring(11, 16)} - ${DateTime.fromMillisecondsSinceEpoch(int.parse(schedules[mainIndex].events[index].endTime) * 1000).toString().substring(11, 16)}",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                schedules[mainIndex].events[index].subject.name.toUpperCase(),
                style: TextStyle(
                  color: Color(0xFF234952),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "Тип занятия: ",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${schedules[mainIndex].events[index].subjectType.name}",
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                  children: [
                    Text(
                      "Аудитория: ",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${schedules[mainIndex].events[index].auditorium.audNum}',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.teal
                      ),
                    ),
                  ]
              ),
              Text(
                '${schedules[mainIndex].events[index].auditorium.campus.name}',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.pinkAccent
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Преподаватель:  ${schedules[mainIndex].events[index].employee.person.surNameRu} ${schedules[mainIndex].events[index].employee.person.lastNameRu} ${schedules[mainIndex].events[index].employee.person.firstNameRu}",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
