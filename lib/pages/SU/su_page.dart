import 'package:flutter/material.dart';

class SuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ваш код для получения расписания из JSON-данных или другого источника данных

    // Пример данных расписания
    List<Lesson> lessons = [
      Lesson(
        dayOfWeek: "Понедельник",
        time: "09:00 - 10:30",
        subject: "Математика",
        auditorium: "101",
      ),
      Lesson(
        dayOfWeek: "Понедельник",
        time: "10:45 - 12:15",
        subject: "История",
        auditorium: "201",
      ),
      // Добавьте остальные уроки для остальных дней недели
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Расписание на неделю'),
      ),
      body: Container(
        color: Colors.black, // Задаем цвет фона
        child: ListView.builder(
          itemCount: lessons.length,
          itemBuilder: (BuildContext context, int index) {
            Lesson lesson = lessons[index];
            return Card(
              color: Colors.grey[900], // Задаем цвет карточки
              elevation: 3.0, // Задаем поднятие карточки
              margin: EdgeInsets.all(8.0), // Задаем отступы карточки
              child: ListTile(
                title: Text(
                  lesson.dayOfWeek,
                  style: TextStyle(
                    color: Colors.white, // Задаем цвет текста
                    fontSize: 18.0, // Задаем размер текста
                    fontWeight: FontWeight.bold, // Задаем жирность текста
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.time,
                      style: TextStyle(
                        color: Colors.white70, // Задаем цвет текста
                        fontSize: 16.0, // Задаем размер текста
                      ),
                    ),
                    Text(
                      lesson.subject,
                      style: TextStyle(
                        color: Colors.white70, // Задаем цвет текста
                        fontSize: 16.0, // Задаем размер текста
                      ),
                    ),
                    Text(
                      lesson.auditorium,
                      style: TextStyle(
                        color: Colors.white70, // Задаем цвет текста
                        fontSize: 16.0, // Задаем размер текста
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Lesson {
  final String dayOfWeek;
  final String time;
  final String subject;
  final String auditorium;

  Lesson({
    required this.dayOfWeek,
    required this.time,
    required this.subject,
    required this.auditorium,
  });
}
