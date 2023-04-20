import 'dart:convert';

import 'package:chatter/pages/SU/SheduleEvent.dart';
import 'package:chatter/pages/SU/WeekDay.dart';
import 'package:chatter/pages/SU/apta/Event.dart';
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
  List<WeekDay> days = [];
  @override
  void initState() {
    super.initState();
    checkSubjects();
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
      print('reload');
      var events = await jsonDecode(res.body);
      var size = events.length;

      for(int i = 0; i < size; i++) {
        var eventSize = await events[i]['events'].length;
        var day = WeekDay(subjects: []);
        for (int j = 0; j < eventSize; j++) {
          if(events[i]['events'].length>0) {
            day.subjects.add(ScheduleEvent.fromJson(events[i]['events'][j]));
          }
        }
        days.add(day);
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

  Future<void> checkSubjects() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('week_days');
    print('check');
    print(jsonString);
    List<WeekDay> tempDays = [];

    if(jsonString != null) {
      var events = await jsonDecode(jsonString);
      var size = events.length;
      print('size: $size');

      for(int i = 0; i < size; i++) {
        var eventSize = await events[i]['events'].length;
        var day = WeekDay(subjects: []);
        for (int j = 0; j < eventSize; j++) {
          if(events[i]['events'].length>0) {
            day.subjects.add(ScheduleEvent.fromJson(events[i]['events'][j]));
          }
        }
        tempDays.add(day);
      }
      setState(() {
        days = tempDays;
      });

    }
    else {
      setState(() {
        reloadSubjects();
      });
    }

  }


  @override
  void dispose() {
    _tabController.dispose();
    // checkSubjects();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return days.length != 0 ? Scaffold(

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
        body: days.length != 0 ? Stack(
            children: [

              TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: days[0].subjects.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [Row(
                          children: [
                            Expanded(child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Тип урока: ${days[0].subjects[index].subjectType.name}', style: TextStyle(color: Colors.black54)),
                                  Text('Номер аудитории: ${days[0].subjects[index].auditorium.audNum}', style: TextStyle(color: Colors.black54)),
                                  Text('Кампус: ${days[0].subjects[index].campus.num}', style: TextStyle(color: Colors.black54)),
                                  Text('Название предмета: ${days[0].subjects[index].subjectName}', style: TextStyle(color: Colors.black54),),
                                  Text('Преподаватель: ${days[0].subjects[index].employeeName}', style: TextStyle(color: Colors.black54),),
                                  Text('Начало урока: ${days[0].subjects[index].beginTime.hour}:${days[0].subjects[index].beginTime.minute}' ,style: TextStyle(color: Colors.black54),),
                                  Text('Конец урока: ${days[0].subjects[index].endTime.hour}:${days[0].subjects[index].endTime.minute}', style: TextStyle(color: Colors.black54)),
                                ],
                              ), )),

                          ],
                        ),
                          SizedBox(height: 30,),
                        ],
                      );
                    },
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: days[1].subjects.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [Row(
                          children: [
                            Expanded(child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Тип урока: ${days[1].subjects[index].subjectType.name}', style: TextStyle(color: Colors.black54)),
                                  Text('Номер аудитории: ${days[1].subjects[index].auditorium.audNum}', style: TextStyle(color: Colors.black54)),
                                  Text('Кампус: ${days[1].subjects[index].campus.num}', style: TextStyle(color: Colors.black54)),
                                  Text('Название предмета: ${days[1].subjects[index].subjectName}', style: TextStyle(color: Colors.black54),),
                                  Text('Преподаватель: ${days[1].subjects[index].employeeName}', style: TextStyle(color: Colors.black54),),
                                  Text('Начало урока: ${days[1].subjects[index].beginTime.hour}:${days[1].subjects[index].beginTime.minute}' ,style: TextStyle(color: Colors.black54),),
                                  Text('Конец урока: ${days[1].subjects[index].endTime.hour}:${days[1].subjects[index].endTime.minute}', style: TextStyle(color: Colors.black54)),
                                ],
                              ), )),

                          ],
                        ),
                          SizedBox(height: 30,),
                        ],
                      );
                    },
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: days[2].subjects.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [Row(
                          children: [
                            Expanded(child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Тип урока: ${days[2].subjects[index].subjectType.name}', style: TextStyle(color: Colors.black54)),
                                  Text('Номер аудитории: ${days[2].subjects[index].auditorium.audNum}', style: TextStyle(color: Colors.black54)),
                                  Text('Кампус: ${days[2].subjects[index].campus.num}', style: TextStyle(color: Colors.black54)),
                                  Text('Название предмета: ${days[2].subjects[index].subjectName}', style: TextStyle(color: Colors.black54),),
                                  Text('Преподаватель: ${days[2].subjects[index].employeeName}', style: TextStyle(color: Colors.black54),),
                                  Text('Начало урока: ${days[2].subjects[index].beginTime.hour}:${days[2].subjects[index].beginTime.minute}' ,style: TextStyle(color: Colors.black54),),
                                  Text('Конец урока: ${days[2].subjects[index].endTime.hour}:${days[2].subjects[index].endTime.minute}', style: TextStyle(color: Colors.black54)),
                                ],
                              ), )),

                          ],
                        ),
                          SizedBox(height: 30,),
                        ],
                      );
                    },
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: days[3].subjects.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [Row(
                          children: [
                            Expanded(child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Тип урока: ${days[3].subjects[index].subjectType.name}', style: TextStyle(color: Colors.black54)),
                                  Text('Номер аудитории: ${days[3].subjects[index].auditorium.audNum}', style: TextStyle(color: Colors.black54)),
                                  Text('Кампус: ${days[3].subjects[index].campus.num}', style: TextStyle(color: Colors.black54)),
                                  Text('Название предмета: ${days[3].subjects[index].subjectName}', style: TextStyle(color: Colors.black54),),
                                  Text('Преподаватель: ${days[3].subjects[index].employeeName}', style: TextStyle(color: Colors.black54),),
                                  Text('Начало урока: ${days[3].subjects[index].beginTime.hour}:${days[3].subjects[index].beginTime.minute}' ,style: TextStyle(color: Colors.black54),),
                                  Text('Конец урока: ${days[3].subjects[index].endTime.hour}:${days[3].subjects[index].endTime.minute}', style: TextStyle(color: Colors.black54)),
                                ],
                              ), )),

                          ],
                        ),
                          SizedBox(height: 30,),
                        ],
                      );
                    },
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: days[4].subjects.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [Row(
                          children: [
                            Expanded(child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Тип урока: ${days[4].subjects[index].subjectType.name}', style: TextStyle(color: Colors.black54)),
                                  Text('Номер аудитории: ${days[4].subjects[index].auditorium.audNum}', style: TextStyle(color: Colors.black54)),
                                  Text('Кампус: ${days[4].subjects[index].campus.num}', style: TextStyle(color: Colors.black54)),
                                  Text('Название предмета: ${days[4].subjects[index].subjectName}', style: TextStyle(color: Colors.black54),),
                                  Text('Преподаватель: ${days[4].subjects[index].employeeName}', style: TextStyle(color: Colors.black54),),
                                  Text('Начало урока: ${days[4].subjects[index].beginTime.hour}:${days[4].subjects[index].beginTime.minute}' ,style: TextStyle(color: Colors.black54),),
                                  Text('Конец урока: ${days[4].subjects[index].endTime.hour}:${days[4].subjects[index].endTime.minute}', style: TextStyle(color: Colors.black54)),
                                ],
                              ), )),

                          ],
                        ),
                          SizedBox(height: 30,),
                        ],
                      );
                    },
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: days[5].subjects.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [Row(
                          children: [
                            Expanded(child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Тип урока: ${days[5].subjects[index].subjectType.name}', style: TextStyle(color: Colors.black54)),
                                  Text('Номер аудитории: ${days[5].subjects[index].auditorium.audNum}', style: TextStyle(color: Colors.black54)),
                                  Text('Кампус: ${days[5].subjects[index].campus.num}', style: TextStyle(color: Colors.black54)),
                                  Text('Название предмета: ${days[5].subjects[index].subjectName}', style: TextStyle(color: Colors.black54),),
                                  Text('Преподаватель: ${days[5].subjects[index].employeeName}', style: TextStyle(color: Colors.black54),),
                                  Text('Начало урока: ${days[5].subjects[index].beginTime.hour}:${days[5].subjects[index].beginTime.minute}' ,style: TextStyle(color: Colors.black54),),
                                  Text('Конец урока: ${days[5].subjects[index].endTime.hour}:${days[5].subjects[index].endTime.minute}', style: TextStyle(color: Colors.black54)),
                                ],
                              ), )),

                          ],
                        ),
                          SizedBox(height: 30,),
                        ],
                      );

                    },
                  )
                ],
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: FloatingActionButton(
                  onPressed: () {
                    checkSubjects();
                  },
                  child: Icon(Icons.refresh),
                  backgroundColor: Color(0x234952FF), // Цвет фона кнопки
                ),
              ),
            ]
        ) :  FloatingActionButton(
          onPressed: () {
            checkSubjects();
          },
          child: Icon(Icons.refresh),
          backgroundColor: Colors.white12, // Цвет фона кнопки
        )
    ) : Container();
  }
}

// class _DayOfWeekButton extends StatelessWidget {
//   final String dayOfWeek;
//
//   const _DayOfWeekButton({Key? key, required this.dayOfWeek}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => Event(week: dayOfWeek, subject: days[0][0],),
//           ),
//         );
//       },
//       child: Text(
//         dayOfWeek,
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }
