import 'project_item.dart';

class Project {
  final String id;
  String name;
  String location;
  DateTime createdAt;
  List<ProjectItem> items;

  Project({
    required this.id,
    required this.name,
    required this.location,
    DateTime? createdAt,
    List<ProjectItem>? items,
  })  : createdAt = createdAt ?? DateTime.now(),
        items = items ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      createdAt: DateTime.parse(map['createdAt']),
      items: (map['items'] as List).map((e) => ProjectItem.fromMap(e)).toList(),
    );
  }
}
