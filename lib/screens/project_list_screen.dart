import 'package:flutter/material.dart';
import '../models/project.dart';
import '../helpers/storage_helper.dart';
import 'project_detail_screen.dart';
import 'package:uuid/uuid.dart';

/// The main screen that lists all projects and allows adding, viewing, deleting, or searching them.
class ProjectListScreen extends StatefulWidget {
  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Project> _projects = []; // All projects loaded from storage
  List<Project> _filteredProjects = []; // Projects filtered based on search input
  String _searchQuery = ''; // Current search query

  @override
  void initState() {
    super.initState();
    _loadProjects(); // Load projects from storage when screen initializes
  }

  /// Loads projects from persistent storage and updates the UI.
  void _loadProjects() async {
    final projects = await StorageHelper.loadProjects();
    setState(() {
      _projects = projects;
      _filteredProjects = _applySearchFilter(projects, _searchQuery);
    });
  }

  /// Applies search filter to the list of projects based on name or location.
  List<Project> _applySearchFilter(List<Project> projects, String query) {
    if (query.isEmpty) return projects;
    final lowerQuery = query.toLowerCase();
    return projects.where((p) =>
        p.name.toLowerCase().contains(lowerQuery) ||
        p.location.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Updates the filtered projects list based on search query.
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProjects = _applySearchFilter(_projects, query);
    });
  }

  /// Shows a dialog to add a new project with name and location fields.
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
            // Input for project name
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Project Name'),
            ),
            // Input for project location
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          // Cancel button closes the dialog
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          // Add button creates a new project if fields are not empty
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && locationController.text.isNotEmpty) {
                final newProject = Project(
                  id: Uuid().v4(), // Generate unique ID
                  name: nameController.text,
                  location: locationController.text,
                );
                setState(() {
                  _projects.add(newProject); // Add new project to the list
                  _filteredProjects = _applySearchFilter(_projects, _searchQuery); // Update filtered list
                });
                StorageHelper.saveProjects(_projects); // Save updated list to storage
                Navigator.pop(context); // Close dialog
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Deletes a project from the list and updates storage.
  void _deleteProject(Project project) {
    setState(() {
      _projects.remove(project); // Remove project from the list
      _filteredProjects = _applySearchFilter(_projects, _searchQuery); // Update filtered list
    });
    StorageHelper.saveProjects(_projects); // Save updated list to storage
  }

  /// Shows a confirmation dialog before deleting a project.
  void _confirmDeleteProject(Project project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Project'),
          content: Text('Are you sure you want to delete this project? This action cannot be undone.'),
          actions: [
            // Cancel button to close the dialog without deleting
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            // Delete button to confirm deletion
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _deleteProject(project);     // Proceed to delete
              },
              child: Text('Delete'),
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
        title: Text('My Projects'),
      ),
      body: Column(
        children: [
          // Search field at the top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name or location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _filteredProjects.isEmpty
                // Show a message if there are no projects
                ? Center(child: Text('No projects yet. Tap + to add.'))
                // Otherwise, show a scrollable list of filtered projects
                : ListView.builder(
                    itemCount: _filteredProjects.length,
                    itemBuilder: (context, index) {
                      final p = _filteredProjects[index];
                      return ListTile(
                        title: Text(p.name),         // Project name
                        subtitle: Text(p.location),  // Project location
                        // Tap on project opens detail screen
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(project: p),
                            ),
                          ).then((_) => _loadProjects()); // Reload projects on return
                        },
                        // Delete icon with confirmation dialog
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteProject(p),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Floating action button to add a new project
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: Icon(Icons.add),
      ),
    );
  }
}