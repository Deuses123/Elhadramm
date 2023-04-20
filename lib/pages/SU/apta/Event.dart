import 'package:chatter/pages/SU/SheduleEvent.dart';
import 'package:flutter/material.dart';

class Event extends StatefulWidget {
  const Event({Key? key, required this.subject}) : super(key: key);
  final ScheduleEvent subject;


  @override
  _EventState createState() => _EventState();
}

class _EventState extends State<Event> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [Row(
          children: [Expanded(child: Container(
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
                Text('Тип урока: ${widget.subject.subjectType}'),
                Text('Номер аудитории: ${widget.subject.auditorium.audNum}'),
                Text('Кампус: ${widget.subject.campus.num}'),
                Text('Название предмета: ${widget.subject.subjectName}'),
                Text('Преподаватель: ${widget.subject.employeeName}'),
                Text('Начало урока: ${widget.subject.beginTime}'),
                Text('Конец урока: ${widget.subject.endTime}'),
              ],
            ), ))],
        )

        ],
      ),
    );
  }
}
