import 'package:doctor_care/presentation/pages/mainscreen/healthpage.dart';
import 'package:doctor_care/presentation/pages/mainscreen/homepage.dart';
import 'package:doctor_care/presentation/pages/mainscreen/notificationpage.dart';
import 'package:doctor_care/presentation/pages/mainscreen/nutrition_meal/nutritionpage.dart';
import 'package:doctor_care/presentation/pages/mainscreen/profilepage.dart';
import 'package:flutter/material.dart';

class Navigationbar extends StatefulWidget {
  const Navigationbar({super.key});

  @override
  State<Navigationbar> createState() => _NavigationbarState();
}

class _NavigationbarState extends State<Navigationbar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _pages = [
    Homepage(),
    NutritionPage(),
    Healthpage(),
    Notificationpage(),
    Profilepage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _selectedIndex == 0
                ? [Colors.blue.shade400, Colors.blue.shade700]
                : [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _selectedIndex == 0
                  ? Colors.blue.withOpacity(0.4)
                  : Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightElevation: 0,
          onPressed: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
          child: Icon(
            Icons.home_outlined,
            color: _selectedIndex == 0
                ? Colors.white
                : Theme.of(context).unselectedWidgetColor,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 4,
        color: Colors.transparent,
        padding: EdgeInsets.zero,
        height: 65,
        child: Container(
          height: 65,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(
                        Icons.fastfood_outlined,
                        color: _selectedIndex == 1
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).unselectedWidgetColor,
                        size: 22,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Dinh dưỡng',
                        style: TextStyle(
                          fontSize: 11,
                          color: _selectedIndex == 1
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).unselectedWidgetColor,
                          fontWeight: _selectedIndex == 1
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border_outlined,
                        color: _selectedIndex == 2
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).unselectedWidgetColor,
                        size: 22,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sức khoẻ',
                        style: TextStyle(
                          fontSize: 11,
                          color: _selectedIndex == 2
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).unselectedWidgetColor,
                          fontWeight: _selectedIndex == 2
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Spacer for FloatingActionButton
              Spacer(),
              // Right item - Cá nhân
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                        color: _selectedIndex == 3
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).unselectedWidgetColor,
                        size: 22,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Thông báo',
                        style: TextStyle(
                          fontSize: 11,
                          color: _selectedIndex == 3
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).unselectedWidgetColor,
                          fontWeight: _selectedIndex == 3
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 4;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outlined,
                        color: _selectedIndex == 4
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).unselectedWidgetColor,
                        size: 22,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cá nhân',
                        style: TextStyle(
                          fontSize: 11,
                          color: _selectedIndex == 4
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).unselectedWidgetColor,
                          fontWeight: _selectedIndex == 4
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
