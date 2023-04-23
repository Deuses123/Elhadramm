import 'Event.dart';

class WeekDay {
  List<Schedule> events = [];

  WeekDay({required this.events});

  // Map<String, dynamic> toJson() => {
  //   'subjects': subjects.map((subject) => subject.toJson()).toList(),
  // };
  // factory WeekDay.fromJson(Map<String, dynamic> json) {
  //   final List<dynamic> jsonSubjects = json['subjects'] ?? [];
  //   final List<ScheduleEvent> subjects = jsonSubjects.map((json) => ScheduleEvent.fromJson(json)).toList();
  //   return WeekDay(subjects: subjects);
  // }

}