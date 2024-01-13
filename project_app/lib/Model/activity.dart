/*
Name:Nur Siti Dahlia S62584
Program: activity model
*/


class Activity {
  String name;
  String status;
  String description;
  DateTime startDate;
  DateTime endDate;
  String leader;
  String username;
  String project;
  String? selectedStatus;

  Activity({
    required this.name,
    required this.status,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.leader,
    required this.username,
    required this.project,
    required this.selectedStatus,
  });

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      description: map['description'] ?? '',
      startDate: DateTime.parse(map['startDate'] ?? ''),
      endDate: DateTime.parse(map['endDate'] ?? ''),
      leader: map['assigned to'] ?? '',
      username: map['username'] ?? '',
      project: map['project'] ?? '',
      selectedStatus: map['selectedStatus'] ?? '',
    );
  }
}