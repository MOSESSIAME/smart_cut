import 'package:flutter/material.dart';
import '../models/project.dart';
import '../helpers/storage_helper.dart';
import 'project_detail_screen.dart';
import 'package:uuid/uuid.dart';

class ProjectListScreen extends StatefulWidget {
  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() async {
    final projects = await StorageHelper.loadProjects();
    setState(() {
      _projects = projects;
    });
  }

  void _addProject() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Project Name'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && locationController.text.isNotEmpty) {
                final newProject = Project(
                  id: Uuid().v4(),
                  name: nameController.text,
                  location: locationController.text,
                );
                setState(() {
                  _projects.add(newProject);
                });
                StorageHelper.saveProjects(_projects);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteProject(Project project) {
    setState(() {
      _projects.remove(project);
    });
    StorageHelper.saveProjects(_projects);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Projects'),
      ),
      body: _projects.isEmpty
          ? Center(child: Text('No projects yet. Tap + to add.'))
          : ListView.builder(
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final p = _projects[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(p.location),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(project: p),
                      ),
                    ).then((_) => _loadProjects());
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProject(p),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: Icon(Icons.add),
      ),
    );
  }
}
