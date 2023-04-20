import 'dart:convert';

class ScheduleEvent {
  final SubjectType subjectType;
  final Auditorium auditorium;
  final Campus campus;
  final String subjectName;
  final String employeeName;
  final DateTime beginTime;
  final DateTime endTime;

  ScheduleEvent({
    required this.subjectType,
    required this.auditorium,
    required this.campus,
    required this.subjectName,
    required this.employeeName,
    required this.beginTime,
    required this.endTime,
  });

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> subject = json['subject'];
    return ScheduleEvent(
      subjectType: SubjectType.fromJson(json['subjectType']),
      auditorium: json['auditorium'] is Map ? Auditorium.fromJson(json['auditorium']) : Auditorium(audNum: 'Null'),
      campus: json['auditorium'] != '' ? Campus.fromJson(json['auditorium']['campus']) : Campus(num: 'Online'),
      subjectName: subject['name'],
      employeeName:
      '${json['employee']['person']['sur_name_ru']}. ${json['employee']['person']['first_name_ru']}. ${json['employee']['person']['last_name_ru']}',
      beginTime: unixTimeToDateTime(int.parse(json['begin_time'])),
      endTime: unixTimeToDateTime(int.parse(json['end_time'])),
    );
  }
}
DateTime unixTimeToDateTime(int unixTime) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
  return dateTime;
}

class SubjectType {
  final String name;

  SubjectType({required this.name});

  factory SubjectType.fromJson(Map<String, dynamic> json) {
    return SubjectType(name: json['name']);
  }
}

class Auditorium {
  final String audNum;

  Auditorium({required this.audNum});

  factory Auditorium.fromJson(Map<String, dynamic> json) {
    return Auditorium(audNum: json['aud_num']);
  }
}

class Campus {
  final String num;

  Campus({required this.num});

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(num: json['num']);
  }
}
