import 'package:chatter/helpers.dart';
import 'package:chatter/pages/SU/su_page.dart';
import 'package:chatter/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../pages/profile_page.dart';
import '../widgets/avatar.dart';
import '/pages/calls_page.dart';
import '/pages/contacts.dart';
import '/pages/messages_page.dart';
import '/pages/notification_pages.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({
    Key? key, required this.loginSuccess
  }
      ) : super(key: key);
  final Function(int) loginSuccess;
  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier("Messages");

  late final pages = [
    MessagesPage(),
    NotificationsPage(),
    // CallPage(),
    ContactsPage(),
    ProfilePage(loginSuccess: loginSuccess),
    SuPage(),
  ];

  final pageTitle = const [
    'MessagesPage',
    'NotificationPage',
    // 'CallsPage',
    'ContactsPage',
    'Profile',
    'SU'
  ];

  void _onNavigationItemSelected(index) {
    title.value = pageTitle[index];
    pageIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ValueListenableBuilder(
          valueListenable: title,
          builder: (BuildContext context, String value, _) {
            return Center(
                child: Text(
              title.value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ));
          },
        ),
         actions: [Avatar.small(url: Helpers.randomPictureUrl())],
      ),
      body: ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (BuildContext context, int value, _) {
          return pages[value];
        },
      ),
      bottomNavigationBar: _BottomNavigationBar(
        onTItemSelected: _onNavigationItemSelected,
      ),
    );
  }
}

class _BottomNavigationBar extends StatefulWidget {
  const _BottomNavigationBar({
    Key? key,
    required this.onTItemSelected,
  }) : super(key: key);
  final ValueChanged<int> onTItemSelected;

  @override
  _BottomNavigationBarState createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<_BottomNavigationBar> {
  var selectedIndex = 0;

  void handleItemSelected(index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onTItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavigationBarItem(
            index: 0,
            label: 'Messages',
            icon: CupertinoIcons.bubble_left_bubble_right_fill,
            isSelected: (selectedIndex == 0),
            onTap: handleItemSelected,
          ),
          _NavigationBarItem(
            index: 1,
            label: 'Notifications',
            icon: CupertinoIcons.bell_solid,
            isSelected: (selectedIndex == 1),
            onTap: handleItemSelected,
          ),
          // _NavigationBarItem(
          //   index: 2,
          //   label: 'Calls',
          //   icon: CupertinoIcons.phone_fill,
          //   isSelected: (selectedIndex == 2),
          //   onTap: handleItemSelected,
          // ),
          _NavigationBarItem(
            index: 2,
            label: 'Contacts',
            icon: CupertinoIcons.person_2_alt,
            isSelected: (selectedIndex == 2),
            onTap: handleItemSelected,
          ),
          _NavigationBarItem(
            index: 3,
            label: 'Profile',
            icon: CupertinoIcons.profile_circled,
            isSelected: (selectedIndex == 3),
            onTap: handleItemSelected,
          ),

          _NavigationBarItem(
            index: 4,
            label: '    SU     ',
            icon: MyCustomIcons.ussr,
            isSelected: (selectedIndex == 4),
            onTap: handleItemSelected,
          ),
        ],
      ),
    );
  }
} 

class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem(
      {Key? key,
      required this.label,
      required this.icon,
      required this.index,
      this.isSelected = false,
      required this.onTap})
      : super(key: key);
  final int index;
  final String label;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onTap(index);
        },
        child: SizedBox(
            height: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.secondary : null,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  label,
                  style: isSelected
                      ? const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary)
                      : const TextStyle(fontSize: 11),
                ),
              ],
            )
        )
    );
  }
}

class MyCustomIcons {
  static const IconData ussr = IconData(
    0x262D,
    fontFamily: 'MaterialIcons',
  );
}
