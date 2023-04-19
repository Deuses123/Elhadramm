import 'package:flutter/material.dart';

class WeekPage extends StatefulWidget {
  const WeekPage({Key? key, required this.week}) : super(key: key);

  final String week;

  @override
  _WeekPageState createState() => _WeekPageState();
}

class _WeekPageState extends State<WeekPage> {
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
                Text('Тип урока: Лекция'),
                Text('Номер аудитории: 101'),
                Text('Кампус: А'),
                Text('Название предмета: Математика'),
                Text('Преподаватель: Иванов Иван Иванович'),
                Text('Начало урока: 09:00'),
                Text('Конец урока: 10:30'),
              ],
            ), ))],
        )

        ],
      ),
    );
  }
}
