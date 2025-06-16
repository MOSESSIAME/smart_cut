class ProjectItem {
  final String id;
  String windowType;
  double width;
  double height;
  List<Map<String, dynamic>> cuttingResult;

  ProjectItem({
    required this.id,
    required this.windowType,
    required this.width,
    required this.height,
    required this.cuttingResult,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'windowType': windowType,
      'width': width,
      'height': height,
      'cuttingResult': cuttingResult.map((e) => Map<String, dynamic>.from(e)).toList(),
    };
  }

  factory ProjectItem.fromMap(Map<String, dynamic> map) {
    return ProjectItem(
      id: map['id'] as String,
      windowType: map['windowType'] as String,
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      cuttingResult: (map['cuttingResult'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }
}
