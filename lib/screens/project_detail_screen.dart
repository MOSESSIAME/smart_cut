import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/project_item.dart';
import '../helpers/storage_helper.dart';
import '../cutting_sheet_pdf_preview.dart'; // << Add this import

/// This screen displays project details, allows editing, adding items,
/// generates PDFs via preview screen, and saves project changes.
class ProjectDetailScreen extends StatefulWidget {
  final Project project; // The project being displayed/edited

  ProjectDetailScreen({required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Project _currentProject; // Holds the current working project
  final List<String> _windowTypes = [
    '2-panel',
    '3-panel',
    'casement',
  ]; // Window types available

  @override
  void initState() {
    super.initState();
    _currentProject =
        widget.project; // Initialize the current project from the passed data
  }

  /// Saves the current project to storage (SharedPreferences or file)
  void _save() async {
    final projects = await StorageHelper.loadProjects(); // Load saved projects
    final index = projects.indexWhere(
      (p) => p.id == _currentProject.id,
    ); // Find current project
    if (index != -1) {
      projects[index] = _currentProject; // Update the project in list
      await StorageHelper.saveProjects(projects); // Save updated list
    }
  }

  /// Opens a dialog to edit project name and location
  void _editProjectDetails() {
    final nameController = TextEditingController(text: _currentProject.name);
    final locationController = TextEditingController(
      text: _currentProject.location,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Project Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Project name input
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Project Name'),
            ),
            // Location input
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          // Save button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentProject.name = nameController.text.trim();
                _currentProject.location = locationController.text.trim();
              });
              _save();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Opens a dialog to add or edit a project item (window/door)
  void _addOrEditItem({ProjectItem? item}) {
    String selectedWindowType = item?.windowType ?? _windowTypes[0];
    final widthController = TextEditingController(
      text: item != null ? item.width.toString() : '',
    );
    final heightController = TextEditingController(
      text: item != null ? item.height.toString() : '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Add Item' : 'Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Dropdown for window type
              DropdownButtonFormField<String>(
                value: selectedWindowType,
                items: _windowTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedWindowType = value;
                  }
                },
                decoration: InputDecoration(labelText: 'Window Type'),
              ),
              // Width input
              TextField(
                controller: widthController,
                decoration: InputDecoration(labelText: 'Width'),
                keyboardType: TextInputType.number,
              ),
              // Height input
              TextField(
                controller: heightController,
                decoration: InputDecoration(labelText: 'Height'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final width = double.tryParse(widthController.text) ?? 0;
              final height = double.tryParse(heightController.text) ?? 0;

              if (width > 0 && height > 0) {
                // Generate cutting sheet result
                final cuttingResult = _generateCuttingResult(
                  selectedWindowType,
                  width,
                  height,
                );

                if (item == null) {
                  // Add new item
                  final newItem = ProjectItem(
                    id: Uuid().v4(),
                    windowType: selectedWindowType,
                    width: width,
                    height: height,
                    cuttingResult: cuttingResult,
                  );
                  setState(() {
                    _currentProject.items.add(newItem);
                  });
                } else {
                  // Edit existing item
                  setState(() {
                    item.windowType = selectedWindowType;
                    item.width = width;
                    item.height = height;
                    item.cuttingResult = cuttingResult;
                  });
                }

                _save();
                Navigator.pop(context);
              }
            },
            child: Text(item == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  /// Deletes an item from the project
  void _deleteItem(ProjectItem item) {
    setState(() {
      _currentProject.items.removeWhere((i) => i.id == item.id);
    });
    _save();
  }

  /// Generates cutting sheet data based on window type and size
  List<Map<String, dynamic>> _generateCuttingResult(
    String type,
    double width,
    double height,
  ) {
    if (type == '2-panel') {
      return [
        {'section': 'Top', 'qty': 1, 'size': (width - 60).round()},
        {'section': 'Bottom', 'qty': 1, 'size': (width - 20).round()},
        {'section': 'Jamb', 'qty': 2, 'size': height.round()},
        {'section': 'Lockstyle', 'qty': 2, 'size': (height - 30).round()},
        {'section': 'Interlock', 'qty': 2, 'size': (height - 30).round()},
        {'section': 'Wheelsash', 'qty': 4, 'size': ((width - 170) / 2).round()},
        {
          'section': 'Glass',
          'qty': 2,
          'size':
              '${(((width - 170) / 2) + 15).round()} x ${((height - 30) - 85).round()}',
        },
        {
          'section': 'Fly Screen',
          'qty': 1,
          'size':
              '${(((width - 170) / 2) + 90).round()} x ${(height - 18).round()}',
        },
      ];
    } else if (type == '3-panel') {
      return [
        {'section': 'Top', 'qty': 1, 'size': (width - 60).round()},
        {'section': 'Bottom', 'qty': 1, 'size': (width - 20).round()},
        {'section': 'Jamb', 'qty': 2, 'size': height.round()},
        {'section': 'Lockstyle', 'qty': 2, 'size': (height - 30).round()},
        {'section': 'Interlock', 'qty': 4, 'size': (height - 30).round()},
        {'section': 'Wheelsash', 'qty': 6, 'size': ((width - 200) / 3).round()},
        {
          'section': 'Glass',
          'qty': 3,
          'size':
              '${(((width - 200) / 3) + 15).round()} x ${(height - 30 - 85).round()}',
        },
        {
          'section': 'Fly Screen',
          'qty': 2,
          'size':
              '${(((width - 200) / 3) + 90).round()} x ${(height - 18).round()}',
        },
      ];
    } else if (type == 'casement') {
      return [
        {'section': 'Outer-Width', 'qty': 2, 'size': (width).round()},
        {'section': 'Outer-Height', 'qty': 2, 'size': (height).round()},
        {'section': 'Inner-Width', 'qty': 2, 'size': (width - 45).round()},
        {'section': 'Inner-Height', 'qty': 2, 'size': (height - 45).round()},
        {
          'section': 'Glass',
          'qty': 1,
          'size':
              '${(((width - 45) - 68)).round()} x ${(((height - 45) - 68)).round()}',
        },
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProject.name),
        actions: [
          // PDF preview/print/share button
          IconButton(
            icon: Icon(Icons.print),
            tooltip: "Print / Share PDF",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CuttingSheetPdfPreview(project: _currentProject),
                ),
              );
            },
          ),
          // Edit project details button
          IconButton(icon: Icon(Icons.edit), onPressed: _editProjectDetails),
        ],
      ),
      body: _currentProject.items.isEmpty
          ? Center(child: Text('No items yet. Tap + to add.'))
          : ListView.builder(
              itemCount: _currentProject.items.length,
              itemBuilder: (context, index) {
                final item = _currentProject.items[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item summary
                        Text(
                          '${item.windowType.toUpperCase()} | Width: ${item.width} | Height: ${item.height}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        // Cutting result table
                        DataTable(
                          columns: [
                            DataColumn(label: Text('Section')),
                            DataColumn(label: Text('Qty')),
                            DataColumn(label: Text('Size')),
                          ],
                          rows: item.cuttingResult.map((part) {
                            return DataRow(
                              cells: [
                                DataCell(Text(part['section'].toString())),
                                DataCell(Text(part['qty'].toString())),
                                DataCell(Text(part['size'].toString())),
                              ],
                            );
                          }).toList(),
                        ),
                        // Edit / Delete buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _addOrEditItem(item: item),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Delete Item'),
                                      content: Text(
                                        'Are you sure you want to delete this item? This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pop(); // Close dialog
                                            _deleteItem(
                                              item,
                                            ); // Proceed to delete
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      // Floating button to add new item
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditItem(),
        child: Icon(Icons.add),
      ),
    );
  }
}
