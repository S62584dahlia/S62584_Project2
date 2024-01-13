import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'status_chart.dart';
import 'Model/activity.dart';
import 'dart:core';


class ActivityScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  final ValueChanged<bool> onActivityStatusChange;
  final String username;

  const ActivityScreen({
    Key? key,
    required this.project,
    required this.onActivityStatusChange,
    required this.username,
  }) : super(key: key);


  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class ActivityState {
  List<Activity> activities = [];
}

class GlobalStateManager {
  static final GlobalStateManager _instance = GlobalStateManager._internal();

  factory GlobalStateManager() {
    return _instance;
  }

  GlobalStateManager._internal();

  ActivityState activityState = ActivityState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> activities = [];
  DateTime? selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  void _fetchActivities() async {
    final projectName = widget.project['name'];
    final username = widget.username;

    final activitiesUrl = Uri.https(
      'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
      'project-monitor-app/projects/activities.json',
    );

    final statusesUrl = Uri.https(
      'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
      'project-monitor-app/projects/activities/status.json',
    );

    try {
      final activitiesResponse = await http.get(activitiesUrl);
      final statusesResponse = await http.get(statusesUrl);

      if (activitiesResponse.statusCode == 200 &&
          statusesResponse.statusCode == 200) {
        final activitiesData =
            json.decode(activitiesResponse.body) as Map<String, dynamic>;
        final statusesData =
            json.decode(statusesResponse.body) as Map<String, dynamic>;

        if (activitiesData != null && statusesData != null) {
          List<Activity> fetchedActivities = [];

          activitiesData.forEach((key, value) {
            if (value != null && value is Map<String, dynamic>) {
              if (value['username'] == username &&
                  value['project'] == projectName) {
                final activityId =
                    getActivityIdForUpdate(Activity.fromMap(value));
                final status = statusesData[activityId] != null
                    ? statusesData[activityId]['status'] ?? '--'
                    : '--';

                fetchedActivities.add(Activity(
                  name: value['name'] ?? '',
                  status: status,
                  selectedStatus: value['selectedStatus'] ?? '',
                  description: value['description'] ?? '',
                  startDate: DateTime.parse(value['startDate'] ?? ''),
                  endDate: DateTime.parse(value['endDate'] ?? ''),
                  leader: value['assigned to'] ?? '',
                  username: value['username'] ?? '',
                  project: value['project'] ?? '',
                ));
              }
            }
          });

          setState(() {
            activities =
                fetchedActivities; 
          });
        }
      } else {
        print('Failed to fetch activities or statuses from Firebase.');
        print('Activities status code: ${activitiesResponse.statusCode}');
        print('Statuses status code: ${statusesResponse.statusCode}');
      }
    } catch (error) {
      print('Error fetching activities or statuses from Firebase: $error');
    }
  }

  void _addActivity() async {
    Activity? newActivity = await _showAddActivityDialog();

    if (newActivity != null) {
      final url = Uri.https(
        'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
        'project-monitor-app/projects/activities.json',
      );

      try {
        final response = await http.post(
          url,
          body: json.encode({
            'name': newActivity.name,
            'status': newActivity.status,
            'selectedStatus': newActivity.selectedStatus,
            'description': newActivity.description,
            'startDate': newActivity.startDate.toIso8601String(),
            'endDate': newActivity.endDate.toIso8601String(),
            'assigned to': newActivity.leader,
            'username': newActivity.username,
            'project': newActivity.project,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            activities.add(newActivity);
          });
        } else {
          print('Failed to add activity. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error adding activity: $error');
      }
    }
  }

  Future<Activity?> _showAddActivityDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    TextEditingController leaderController = TextEditingController();

    return showDialog<Activity>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Register Activity',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildTextFieldWithIcon(
                    controller: nameController,
                    hintText: 'Activity Name',
                    icon: Icons.edit,
                  ),
                  _buildTextFieldWithIcon(
                    controller: descriptionController,
                    hintText: 'Description',
                    icon: Icons.description,
                  ),
                  _buildDateTimePickerWithIcon(
                    hintText: 'Start Date',
                    icon: Icons.date_range,
                    onDateTimeSelected: (DateTime selectedDate) {
                      setState(() {
                        startDate = selectedDate;
                      });
                    },
                    selectedDate: startDate,
                  ),
                  _buildDateTimePickerWithIcon(
                    hintText: 'End Date',
                    icon: Icons.date_range,
                    onDateTimeSelected: (DateTime selectedDate) {
                      setState(() {
                        endDate = selectedDate;
                      });
                    },
                    selectedDate: endDate,
                  ),
                  _buildTextFieldWithIcon(
                    controller: leaderController,
                    hintText: 'Assigned To',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, null);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 190, 34, 23),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (startDate != null && endDate != null) {
                            Activity newActivity = Activity(
                              name: nameController.text,
                              status: '--',
                              selectedStatus: '--',
                              description: descriptionController.text,
                              startDate: startDate!,
                              endDate: endDate!,
                              leader: leaderController.text,
                              username: widget.username,
                              project: widget.project['name'],
                            );
                            Navigator.pop(context, newActivity);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Please select start and end dates.'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(199, 1, 37, 138),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hintText,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildDateTimePickerWithIcon({
    required String hintText,
    required IconData icon,
    required ValueChanged<DateTime> onDateTimeSelected,
    required DateTime? selectedDate,
  }) {
    TextEditingController controller = TextEditingController(
      text: _formattedDate(selectedDate),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );

          if (picked != null) {
            setState(() {
              onDateTimeSelected(picked);
              controller.text = _formattedDate(picked);
            });
          }
        },
        child: AbsorbPointer(
          child: _buildTextFieldWithIcon(
            controller: controller,
            hintText: hintText,
            icon: icon,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(Activity activity) {
    Color progressBarColor;

    switch (activity.status) {
      case 'Complete':
        progressBarColor = Colors.green;
        break;
      case 'Not Started':
        progressBarColor = Colors.red;
        break;
      case 'In Progress':
        progressBarColor = Colors.orange;
        break;
      case 'Cancel/Removed':
        progressBarColor = Colors.black;
        break;
      default:
        progressBarColor = Colors.grey;
        break;
    }

    final Duration duration = activity.endDate.difference(activity.startDate);
    final String durationText = '${duration.inDays} days';

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: activity.status == 'Complete' ? 1.0 : 1.0,
            valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
            backgroundColor: Colors.grey[300],
          ),
          ListTile(
            title: Text(
              activity.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${activity.status}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text('Description: ${activity.description}'),
                Text('Start Date: ${_formattedDate(activity.startDate)}'),
                Text('End Date: ${_formattedDate(activity.endDate)}'),
                Text('Duration: $durationText'), 
                Text('Assigned To: ${activity.leader}'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                _showStatusDialog(activity);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formattedDate(DateTime? dateTime) {
    return dateTime != null
        ? '${dateTime.day}/${dateTime.month}/${dateTime.year}'
        : ''; 
  }

  void _showStatusDialog(Activity activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatusDialog(initialStatus: activity.status);
      },
    ).then((selectedStatus) async {
      if (selectedStatus != null) {
        try {
          final activityId = getActivityIdForUpdate(activity);
          final url = Uri.https(
            'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
            'project-monitor-app/projects/activities/status/$activityId.json',
          );

          final response = await http.patch(
            url,
            body: json.encode({'status': selectedStatus}),
          );

          if (response.statusCode == 200) {
            setState(() {
              activity.status = selectedStatus;
            });

            widget.onActivityStatusChange(selectedStatus == 'Complete');
          } else {
            print(
                'Failed to update activity status. Status code: ${response.statusCode}');
          }
        } catch (error) {
          print('Error updating activity status: $error');
        }
      }
    });
  }

  String getActivityIdForUpdate(Activity activity) {
    return '${activity.username}_${activity.project}_${activity.name}';
  }

  void _showStatusChartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Progress Overview'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: StatusChart(activities: activities),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 136, 13, 13),
                primary: Colors.white, // Change the text color here
              ),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project['name']),
        centerTitle: true,
        backgroundColor: Color.fromARGB(199, 1, 37, 138),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'images/bg2.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Project Milestones',
                      style: TextStyle(fontSize: 23),
                    ),
                    ElevatedButton(
                      onPressed: _addActivity,
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(199, 1, 37, 138),
                      ),
                      child: Text('+ Tasks'),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                if (activities.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'images/empty.png',
                          width: 150,
                          height: 150,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No activities.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        return _buildActivityTile(activities[index]);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showStatusChartDialog(context);
        },
        backgroundColor: Colors.indigo[800],
        child: Icon(Icons.show_chart),
      ),
    );
  }
}

class StatusDialog extends StatefulWidget {
  final String initialStatus;

  StatusDialog({required this.initialStatus});

  @override
  _StatusDialogState createState() => _StatusDialogState();
}

class _StatusDialogState extends State<StatusDialog> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Status of Task'),
      content: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            _buildStatusOption('In Progress', Colors.orange),
            _buildStatusOption('Complete', Colors.green),
            _buildStatusOption('Not Started', Colors.red),
            _buildStatusOption('Cancel/Removed', Colors.black),
          ],
        ),
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
            Navigator.pop(context,
                selectedStatus); 
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.teal, 
          ),
          child: Text('Save'),
        ),
      ],
    );
  }

  Widget _buildStatusOption(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            margin: EdgeInsets.only(right: 10),
          ),
          Radio(
            value: label,
            groupValue: selectedStatus,
            onChanged: (String? value) {
              setState(() {
                selectedStatus = value!;
              });
            },
            activeColor: color,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
