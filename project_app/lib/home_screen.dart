/*
Name:Nur Siti Dahlia S62584
Program: implementation of home screen
*/

import 'dart:ui';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import 'projects_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<DateTime, String> _events =
      {}; 
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchEvents(); 
  }

  void _fetchEvents() async {
    final url = Uri.https(
      'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
      'project-monitor-app/eventcalendar.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data != null) {
          Map<DateTime, String> fetchedEvents = {};

          data.forEach((key, value) {
            try {
          
              final parts = value['date'].split('-');
              DateTime dateTime = DateTime(int.parse(parts[2]),
                  int.parse(parts[1]), int.parse(parts[0]));

              String? username = value['event']['username'];

              if (username == widget.username) {
                fetchedEvents[dateTime] = value['event']['eventName'];
              }
            } catch (e) {
              print('Error parsing date: ${value['date']}');
            }
          });

          setState(() {
            _events = fetchedEvents;
          });
        }
      }
    } catch (error) {
      print('Error fetching events: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NovaPlan'),
        backgroundColor: Color.fromARGB(199, 1, 37, 138),
        centerTitle: true,
      ),
      body: Column(
        children: [
        
          Expanded(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Greetings,',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.username}!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
         
          Container(
            height: 600.0,
            decoration: BoxDecoration(
              color: Color.fromRGBO(185, 221, 255, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Reminder',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                   
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final date = _events.keys.elementAt(index);
                          final event = _events[date];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Colors.grey),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${date.day}/${date.month}/${date.year}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      SizedBox(height: 1),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            event!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.bookmark_sharp,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: SizedBox(
        width: 200, 
        child: Drawer(
          child: Container(
            color: Color.fromARGB(199, 1, 37, 138),
            child: ListView(
              children: [
                Container(
                  height: 100, 
                  child: DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'See you again, ${widget.username}!',
                          style: TextStyle(
                            color: Color.fromARGB(199, 1, 37, 138),
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                ListTile(
                  tileColor: Colors.white,
                  leading: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  onTap: () {
                    _logout(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      // ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        items: [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.work, size: 30, color: Colors.white),
          Icon(Icons.calendar_today, size: 30, color: Colors.white),
        ],
        color: Color.fromARGB(199, 1, 37, 138),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Color.fromARGB(199, 1, 37, 138),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
     
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(username: widget.username),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProjectsScreen(username: widget.username),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CalendarScreen(username: widget.username),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
