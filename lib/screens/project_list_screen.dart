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
  List<Project> _filteredProjects = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() async {
    final projects = await StorageHelper.loadProjects();
    setState(() {
      _projects = projects;
      _filteredProjects = _applySearchFilter(projects, _searchQuery);
    });
  }

  List<Project> _applySearchFilter(List<Project> projects, String query) {
    if (query.isEmpty) return projects;
    final lowerQuery = query.toLowerCase();
    return projects
        .where(
          (p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              p.location.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProjects = _applySearchFilter(_projects, query);
    });
  }

  void _addProject() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  locationController.text.isNotEmpty) {
                final newProject = Project(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  location: locationController.text,
                );
                setState(() {
                  _projects.add(newProject);
                  _filteredProjects = _applySearchFilter(
                    _projects,
                    _searchQuery,
                  );
                });
                StorageHelper.saveProjects(_projects);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteProject(Project project) {
    setState(() {
      _projects.remove(project);
      _filteredProjects = _applySearchFilter(_projects, _searchQuery);
    });
    StorageHelper.saveProjects(_projects);
  }

  void _confirmDeleteProject(Project project) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteProject(project);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),

      // 🌈 Gradient AppBar
      appBar: AppBar(
        title: const Text('My Projects'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by project or location',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          Expanded(
            child: _filteredProjects.isEmpty
                ? const Center(
                    child: Text(
                      'No projects yet.\nTap + to add a project.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filteredProjects.length,
                    itemBuilder: (context, index) {
                      final p = _filteredProjects[index];

                      // 🧱 Project Card
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF0D47A1),
                            child: const Icon(
                              Icons.folder,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
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
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteProject(p),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ➕ Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 97, 153, 237),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
        onPressed: _addProject,
      ),
    );
  }
}
