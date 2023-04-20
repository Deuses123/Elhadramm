// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'dart:core';
// import 'dart:math';
//
// class Event {
//   String subjectType;
//   String auditoriumNumber;
//   String campusNumber;
//   String subjectName;
//   String employeeSurname;
//   String employeeFirstNameInitial;
//   String employeeLastNameInitial;
//   String beginTime;
//   String endTime;
//
//   Event({
//     required this.subjectType,
//     required this.auditoriumNumber,
//     required this.campusNumber,
//     required this.subjectName,
//     required this.employeeSurname,
//     required this.employeeFirstNameInitial,
//     required this.employeeLastNameInitial,
//     required this.beginTime,
//     required this.endTime,
//   });
//
//   factory Event.fromJson(Map<String, dynamic> json) {
//     return Event(
//       subjectType: json['subjectType']['name'],
//       auditoriumNumber: json['auditorium']['aud_num'],
//       campusNumber: json['auditorium']['campus']['num'],
//       subjectName: json['subject']['name'],
//       employeeSurname: json['employee']['person']['sur_name_ru'],
//       employeeFirstNameInitial: json['employee']['person']['first_name_ru'][0],
//       employeeLastNameInitial: json['employee']['person']['last_name_ru'][0],
//       beginTime: json['begin_time'].toString(),
//       endTime: json['end_time'].toString(),
//     );
//   }
// }
//
// Future<List<Event>> fetchSchedules() async {
//   // Здесь указываем URL-адрес, откуда получаем данные
//   String url = 'https://api.satbayev.hero.study/v1/schedule/list?beginTime=1681754400&endTime=1681840800&lang=ru';
//   // Здесь добавляем токен доступа в заголовки HTTP-запроса
//   Map<String, String> headers = {
//     'Authorization':
//     'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozMDIxMCwiaWF0IjoxNjgxMzIyMzYwLCJleHAiOjE2ODkwOTgzNjB9.rVnTvajovKflLbJowlpnva13CdoOPQt49WBREKcb_BI',
//     'Content-Type': 'application/json' // Указываем тип контента
//   };
//   var response = await http.get(Uri.parse(url), headers: headers);
//
//   if (response.statusCode == 200) {
//     List<dynamic> jsonList = json.decode(response.body);
//     List<Event> events = [];
//     for (var eventJson in jsonList) {
//       Event event = Event.fromJson(eventJson);
//       events.add(event);
//     }
//     return events;
//   } else {
//     throw Exception('Failed to fetch schedules');
//   }
// }
//
// String translate(int dt) {
//   DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
//   String formattedTime = dateTime.toString();
//   return formattedTime;
// }
//
// Future<void> main() async {
//   List<Event> events = await fetchSchedules();
//   Event schedule = events[0];
//
//   print(schedule.subjectType);
//   print(schedule.auditoriumNumber);
//   print(schedule.campusNumber);
//   print(schedule.subjectName);
//   print(schedule.employeeSurname + '.');
//   print(schedule.employeeFirstNameInitial + '.');
//   print(schedule.employeeLastNameInitial);
//   print(translate(int.parse(schedule.beginTime)));
//   print(translate(int.parse(schedule.endTime)));
// }
