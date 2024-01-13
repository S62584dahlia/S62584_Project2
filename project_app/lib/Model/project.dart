/*
Name:Nur Siti Dahlia S62584
Program: project model
*/

class Project {
  String? key;
  final String name;
  final String clientName;
  final String description;
  final String startDate;
  final String endDate;

  Project({
    this.key,
    required this.name,
    required this.clientName,
    required this.description,
    required this.startDate,
    required this.endDate,
  });
}