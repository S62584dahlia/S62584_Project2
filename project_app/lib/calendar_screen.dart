/*
Name:Nur Siti Dahlia S62584
Program: implementation of calendar hub screen
*/

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'projects_screen.dart';

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CalendarScreen extends StatefulWidget {
  final String username;

  const CalendarScreen({Key? key, required this.username}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  Map<DateTime, String> _events = {};
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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
        setState(() {
          _events = Map.fromIterable(
            data.keys.where((key) {
        
              return data[key]['event']['username'] == widget.username;
            }),
            key: (key) {
              final parts = data[key]['date'].split('-');
              return DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            },
            value: (key) => data[key]['event']['eventName'],
          );
        });
      }
    }
  } catch (error) {
    print('Error fetching events: $error');
  }
}

  void _saveEvents(DateTime date, String eventName) async {
    final url = Uri.https(
      'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
      'project-monitor-app/eventcalendar.json',
    );

    try {
      final Map<String, String> eventsStringMap = {
        'eventName': eventName,
        'username': widget.username,
      };

      final response = await http.post(
        url,
        body: json.encode({
          'date': "${date.day}-${date.month}-${date.year}",
          'event': eventsStringMap,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to save events. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error saving events: $error');
    }
  }

  void _removeEvent(DateTime date) async {
    setState(() {
      _events.remove(date);
    });

    final url = Uri.https(
      'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
      'project-monitor-app/eventcalendar.json',
    );

    try {
      final Map<String, dynamic>? data =
          await _fetchEventData();

      if (data != null) {
        final key = data.keys.firstWhere(
          (key) {
            final parts = data[key]['date'].split('-');
            final eventDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            return eventDate == date;
          },
        );

        final deleteUrl = Uri.https(
          'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
          'project-monitor-app/eventcalendar/$key.json',
        );

        final deleteResponse = await http.delete(deleteUrl);

        if (deleteResponse.statusCode != 200) {
          print(
              'Failed to delete event from Firebase. Status code: ${deleteResponse.statusCode}');
        }
      }
    } catch (error) {
      print('Error deleting event: $error');
    }
  }

  Future<Map<String, dynamic>?> _fetchEventData() async {
    final url = Uri.https(
      'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
      'project-monitor-app/eventcalendar.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            'Failed to fetch events from Firebase. Status code: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching events: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Hub'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Color.fromARGB(199, 1, 37, 138),
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          _buildCalendarBody(),
          _buildEvents(),
        ],
      ),
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
              Navigator.push(
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
              break;
          }
        },
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
                _fetchEvents();
              });
            },
            icon: Icon(Icons.chevron_left),
          ),
          Text(
            '${_selectedDate.year} - ${_selectedDate.month}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
                _fetchEvents(); 
              });
            },
            icon: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarBody() {
    return Container(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemBuilder: (context, index) {
          final cellDate = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            index + 1,
          );

          return Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: cellDate.month == _selectedDate.month
                  ? const Color.fromARGB(255, 73, 140, 255)
                  : Colors.grey.withOpacity(0.2),
            ),
            child: InkWell(
              onTap: () {
                _showEventDialog(cellDate);
              },
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        color: cellDate.month == _selectedDate.month
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  if (_events.containsKey(cellDate))
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CustomPaint(
                        painter: TrianglePainter(),
                        size: Size(10, 10),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        itemCount: DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          0,
        ).day,
      ),
    );
  }

  void _showEventDialog(DateTime date) {
    TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Event ${date.day}/${date.month}/${date.year}'),
          content: TextField(
            controller: eventController,
            decoration: InputDecoration(hintText: 'Event Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _events[date] = eventController.text;
                });

                _saveEvents(date, eventController.text);

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEvents() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agenda :',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _events.isEmpty
                  ? Center(
                      child: Text('No events added.'),
                    )
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final date = _events.keys.elementAt(index);
                        final event = _events[date];
                        return Card(
                          elevation: 9,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title:
                                Text('${date.day}-${date.month}-${date.year}'),
                            subtitle: Text(event!),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              color: Color.fromRGBO(189, 37, 27, 1),
                              onPressed: () {
                                _removeEvent(date);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
