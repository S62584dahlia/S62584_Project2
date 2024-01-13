/*
Name:Nur Siti Dahlia S62584
Program: implementation of project screen
*/

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'activity_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Model/project.dart';
import 'calendar_screen.dart';
import 'home_screen.dart';


class ProjectsScreen extends StatefulWidget {
  final String username;

  const ProjectsScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}


class _ProjectsScreenState extends State<ProjectsScreen> {
  int _currentIndex = 1;
  List<Map<String, dynamic>> projects = [];
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProjects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  void _fetchProjects() async {
    final url = Uri.https(
      'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
      'project-monitor-app/projects.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data != null) {
          List<Map<String, dynamic>> fetchedProjects = [];
          data.forEach((key, value) {
            if (value['username'] == widget.username) {
              fetchedProjects.add({
                'key': key, 
                'name': value['name'],
                'clientName': value['clientName'],
                'description': value['description'],
                'startDate': value['startDate'],
                'endDate': value['endDate'],
                'username': value['username'],
              });
            }
          });

          setState(() {
            projects = fetchedProjects;
          });
        }
      } else {
        print(
            'Failed to fetch projects from Firebase. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching projects from Firebase: $error');
    }
  }

  void _addProject() async {
    Map<String, dynamic>? projectDetails =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController startDateController = TextEditingController();
        TextEditingController endDateController = TextEditingController();
        TextEditingController clientNameController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();
        String _errorMessage = '';

        return Form(
          key: _formKey,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Project',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Project Name',
                      prefixIcon: Icon(Icons.event),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project name.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: clientNameController,
                    decoration: InputDecoration(
                      labelText: 'Client Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a client name.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project description.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: startDateController,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );

                      if (pickedDate != null && pickedDate != DateTime.now()) {
                        startDateController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a start date.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: endDateController,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );

                      if (pickedDate != null && pickedDate != DateTime.now()) {
                        endDateController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an end date.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 16),
                  Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    ElevatedButton(
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
        if (_formKey.currentState?.validate() ?? false) {
          Navigator.pop(
            context,
            {
              'name': nameController.text,
              'clientName': clientNameController.text,
              'description': descriptionController.text,
              'startDate': startDateController.text,
              'endDate': endDateController.text,
            },
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

    if (projectDetails != null &&
        projectDetails['name'].isNotEmpty &&
        projectDetails['clientName'].isNotEmpty &&
        projectDetails['description'].isNotEmpty &&
        projectDetails['startDate'].isNotEmpty &&
        projectDetails['endDate'].isNotEmpty) {
      projectDetails['username'] = widget.username;

      final newProjectDetails = {
        'name': projectDetails['name'],
        'clientName': projectDetails['clientName'],
        'description': projectDetails['description'],
        'startDate': projectDetails['startDate'],
        'endDate': projectDetails['endDate'],
        'username': widget.username,
      };

      setState(() {
        projects.add(newProjectDetails);
      });

      final url = Uri.https(
        'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
        'project-monitor-app/projects.json',
      );

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(newProjectDetails),
        );

        if (response.statusCode == 200) {
          print('Project details added to Firebase successfully.');
        } else {
          print(
              'Failed to add project details to Firebase. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error adding project details to Firebase: $error');
      }
    }
  }

  void _deleteProject(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Project'),
          content: Text('Are you sure you want to delete this project?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String projectKey = projects[index]['key']; 
                final url = Uri.https(
                  'project-monitor-app-default-rtdb.asia-southeast1.firebasedatabase.app',
                  'project-monitor-app/projects/$projectKey.json', 
                );

                try {
                  final response = await http.delete(url);

                  if (response.statusCode == 200) {
                    print('Project deleted from Firebase successfully.');
                  } else {
                    print(
                        'Failed to delete project from Firebase. Status code: ${response.statusCode}');
                  }
                } catch (error) {
                  print('Error deleting project from Firebase: $error');
                }

                setState(() {
                  projects.removeAt(index);
                });

                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToActivityScreen(Map<String, dynamic> project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityScreen(
          project: project,
          onActivityStatusChange: (bool isComplete) {},
          username: widget.username,
        ),
      ),
    );
  }

  void _onOptionsExpanded(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 196, 44,
                      33), 
                ),
                title: Text('Delete Project'),
                onTap: () {
                  Navigator.pop(context); 
                  _deleteProject(index);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.view_list_rounded,
                  color: Color.fromARGB(255, 8, 86, 122),
                ),
                title: Text('View Activities'),
                onTap: () {
                  Navigator.pop(context); 
                  _navigateToActivityScreen(projects[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _filterProjects(String query) {
    setState(() {
      _filteredProjects = projects
          .where((project) =>
              project['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Color.fromARGB(199, 1, 37, 138),
      ),
      body: Column(children: [
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white10,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (query) {
              _filterProjects(query);
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.black45),
              hintText: 'Search projects..',
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'images/bg2.png',
                  fit: BoxFit.cover,
                ),
              ),
              projects.isEmpty
                  ? Center(child: Text('No project added yet.'))
                  : Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: ListView.builder(
                        itemCount: _searchController.text.isEmpty
                            ? projects.length
                            : _filteredProjects.length,
                        itemBuilder: (context, index) {
                          DateTime startDate = DateTime.parse(
                              _searchController.text.isEmpty
                                  ? projects[index]['startDate']
                                  : _filteredProjects[index]['startDate']);
                          DateTime endDate = DateTime.parse(
                              _searchController.text.isEmpty
                                  ? projects[index]['endDate']
                                  : _filteredProjects[index]['endDate']);
                          Duration duration = endDate.difference(startDate);

                          return Column(
                            children: [
                              SizedBox(
                                  height: 7),
                              Row(children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(9.0),
                                    ),
                                    child: Card(
                                      child: ListTile(
                                        title: Text(
                                          _searchController.text.isEmpty
                                              ? projects[index]['name']
                                              : _filteredProjects[index]
                                                  ['name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.person, size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                    'Client: ${projects[index]['clientName']}'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.description,
                                                    size: 16),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                      'Description: ${projects[index]['description']}'),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.date_range,
                                                    size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                    'Start Date: ${projects[index]['startDate']}'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.date_range,
                                                    size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                    'End Date: ${projects[index]['endDate']}'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.timer, size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                    'Duration: ${duration.inDays} days'),
                                              ],
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          _onOptionsExpanded(index);
                                        },
                                        trailing: Icon(
                                          Icons.expand_more,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ],
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ]),
      floatingActionButton: TextButton(
        onPressed: () {
          _formKey.currentState?.reset();
          _addProject();
        },
        child: Text(
          '+ Register Project',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: TextButton.styleFrom(
            backgroundColor: Color.fromARGB(228, 1, 37, 138),
            primary: Colors.white),
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
}
