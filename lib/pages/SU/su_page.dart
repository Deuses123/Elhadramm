import 'package:chatter/pages/SU/apta/WeekPage.dart';
import 'package:flutter/material.dart';

class SuPage extends StatefulWidget {
  @override
  _SuPageState createState() => _SuPageState();
}

class _SuPageState extends State<SuPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          WeekPage(week: 'Понедельник'),
          WeekPage(week: 'Вторник'),
          WeekPage(week: 'Среда'),
          WeekPage(week: 'Четверг'),
          WeekPage(week: 'Пятница'),
          WeekPage(week: 'Суббота'),
        ],
      ),
    );
  }
}

class _DayOfWeekButton extends StatelessWidget {
  final String dayOfWeek;

  const _DayOfWeekButton({Key? key, required this.dayOfWeek}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WeekPage(week: dayOfWeek),
          ),
        );
      },
      child: Text(
        dayOfWeek,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
