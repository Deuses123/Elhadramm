import 'dart:convert';

class Schedule {
  final String day;
  final List<String> type;
  final List<Event> events;

  Schedule({required this.day, required this.type, required this.events});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    List<Event> events = [];
    for (var event in json['events']) {
      events.add(Event.fromJson(event));
    }
    return Schedule(
      day: json['day'],
      type: List<String>.from(json['type']),
      events: events,
    );
  }
}

class Event {
  final String beginTime;
  final String endTime;
  final String createdAt;
  final String updatedAt;
  final SubjectType subjectType;
  final Auditorium auditorium;
  final Subject subject;
  final Employee employee;
  final String schedulesType;

  Event({
    required this.beginTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
    required this.subjectType,
    required this.auditorium,
    required this.subject,
    required this.employee,
    required this.schedulesType,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    if(json.isEmpty) {
      return Event(beginTime: '', endTime: '', createdAt: '', updatedAt: '', subjectType: SubjectType(name: ''), auditorium: Auditorium(audNum: '', campus: Campus(name: '')), subject: Subject(name: ''),
          employee: Employee(person: Person(firstNameRu: '', lastNameRu: '', surNameRu: '')), schedulesType: 'schedulesType');
    }
    return Event(
      beginTime: json['begin_time'],
      endTime: json['end_time'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      subjectType: SubjectType.fromJson(json['subjectType']),
      auditorium: json['auditorium'] != '' ? Auditorium.fromJson(json['auditorium'])  : Auditorium(audNum: '', campus: Campus(name: '')),
      subject: Subject.fromJson(json['subject']),
      employee: Employee.fromJson(json['employee']),
      schedulesType: json['schedulesType'],
    );
  }
}

class SubjectType {
  final String name;

  SubjectType({required this.name});

  factory SubjectType.fromJson(Map<String, dynamic> json) {
    return SubjectType(
      name: json['name'],
    );
  }
}

class Auditorium {
  final String audNum;
  final Campus campus;

  Auditorium({required this.audNum, required this.campus});

  factory Auditorium.fromJson(Map<String, dynamic> json) {
    if (json['campus'] == null || json['campus']['name'] == null) {
      return Auditorium(audNum: 'Online', campus: Campus(name: 'Online'));
    }
    return Auditorium(
      audNum: json['aud_num'] ?? '',
      campus: Campus.fromJson(json['campus']),
    );
  }

}

class Campus {
  final String name;

  Campus({required this.name});

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      name: json['name'],
    );
  }
}

class Subject {
  final String name;

  Subject({required this.name});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
    );
  }
}

class Employee {
  final Person person;

  Employee({required this.person});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      person: Person.fromJson(json['person']),
    );
  }
}

class Person {
  final String firstNameRu;
  final String lastNameRu;
  final String surNameRu;

  Person({
    required this.firstNameRu,
    required this.lastNameRu,
    required this.surNameRu,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      firstNameRu: json['first_name_ru'],
      lastNameRu: json['last_name_ru'],
      surNameRu: json['sur_name_ru'],
    );
  }
}