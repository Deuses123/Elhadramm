import 'SheduleEvent.dart';

class WeekDay {
  List<ScheduleEvent> subjects = [];

  WeekDay({required this.subjects});

  Map<String, dynamic> toJson() => {
    'subjects': subjects.map((subject) => subject.toJson()).toList(),
  };
  factory WeekDay.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonSubjects = json['subjects'] ?? [];
    final List<ScheduleEvent> subjects = jsonSubjects.map((json) => ScheduleEvent.fromJson(json)).toList();
    return WeekDay(subjects: subjects);
  }

}