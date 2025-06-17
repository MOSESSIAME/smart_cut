import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/project_item.dart';
import '../helpers/storage_helper.dart';
import '../helpers/pdf_helper.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  ProjectDetailScreen({required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Project _currentProject;
  final List<String> _windowTypes = ['2-panel', '3-panel', 'casement'];

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;
  }

  void _save() async {
    final projects = await StorageHelper.loadProjects();
    final index = projects.indexWhere((p) => p.id == _currentProject.id);
    if (index != -1) {
      projects[index] = _currentProject;
      await StorageHelper.saveProjects(projects);
    }
  }

  void _editProjectDetails() {
    final nameController = TextEditingController(text: _currentProject.name);
    final locationController = TextEditingController(text: _currentProject.location);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Project Details'),
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

  void _addOrEditItem({ProjectItem? item}) {
    String selectedWindowType = item?.windowType ?? _windowTypes[0];
    final widthController = TextEditingController(text: item != null ? item.width.toString() : '');
    final heightController = TextEditingController(text: item != null ? item.height.toString() : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Add Item' : 'Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
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
              TextField(
                controller: widthController,
                decoration: InputDecoration(labelText: 'Width'),
                keyboardType: TextInputType.number,
              ),
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
                final cuttingResult = _generateCuttingResult(selectedWindowType, width, height);

                if (item == null) {
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

  void _deleteItem(ProjectItem item) {
    setState(() {
      _currentProject.items.removeWhere((i) => i.id == item.id);
    });
    _save();
  }

  List<Map<String, dynamic>> _generateCuttingResult(String type, double width, double height) {
    if (type == '2-panel') {
      return [
        { 'section': 'Top', 'qty': 1, 'size': (width - 60).round() },
        { 'section': 'Bottom', 'qty': 1, 'size': (width - 20).round() },
        { 'section': 'Jamb', 'qty': 2, 'size': height.round() },
        { 'section': 'Lockstyle', 'qty': 2, 'size': (height - 30).round() },
        { 'section': 'Interlock', 'qty': 2, 'size': (height - 30).round() },
        { 'section': 'Wheelsash', 'qty': 4, 'size': ((width - 170) / 2).round() },
        { 'section': 'Glass', 'qty': 2, 'size': '${(((width - 170) / 2) + 15).round()} x ${((height - 30) - 85).round()}' },
        { 'section': 'Fly Screen', 'qty': 1, 'size': '${(((width - 170) / 2) + 90).round()} x ${(height - 18).round()}' }
      ];
    } else if (type == '3-panel') {
      return [
        { 'section': 'Top', 'qty': 1, 'size': (width - 60).round() },
        { 'section': 'Bottom', 'qty': 1, 'size': (width - 20).round() },
        { 'section': 'Jamb', 'qty': 2, 'size': height.round() },
        { 'section': 'Lockstyle', 'qty': 2, 'size': (height - 30).round() },
        { 'section': 'Interlock', 'qty': 4, 'size': (height - 30).round() },
        { 'section': 'Wheelsash', 'qty': 6, 'size': ((width - 200) / 3).round() },
        { 'section': 'Glass', 'qty': 3, 'size': '${(((width - 200) / 3) + 15).round()} x ${(height - 30 - 85).round()}' },
        { 'section': 'Fly Screen', 'qty': 2, 'size': '${(((width - 200) / 3) + 90).round()} x ${(height - 18).round()}' }
      ];
    } else if (type == 'casement') {
      return [
        { 'section': 'Outer', 'qty': 4, 'size': (width).round() },
        { 'section': 'Inner', 'qty': 4, 'size': (width - 45).round() },
        { 'section': 'Glass', 'qty': 1, 'size': '${(((width - 45)-68)).round()} x ${(((width - 45)-68)).round()}' }
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
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              PdfHelper.generateAndPrint(_currentProject);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProjectDetails,
          ),
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
                        Text(
                          '${item.windowType.toUpperCase()} | Width: ${item.width} | Height: ${item.height}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        DataTable(
                          columns: [
                            DataColumn(label: Text('Section')),
                            DataColumn(label: Text('Qty')),
                            DataColumn(label: Text('Size')),
                          ],
                          rows: item.cuttingResult.map((part) {
                            return DataRow(cells: [
                              DataCell(Text(part['section'].toString())),
                              DataCell(Text(part['qty'].toString())),
                              DataCell(Text(part['size'].toString())),
                            ]);
                          }).toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _addOrEditItem(item: item),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(item),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditItem(),
        child: Icon(Icons.add),
      ),
    );
  }
}
