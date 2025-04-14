class Science {
  final String id;
  final String name;
  final String description;
  final String subCat;

  Science({
    required this.id,
    required this.name,
    required this.description,
    required this.subCat,
  });

  factory Science.fromJson(Map<String, dynamic> json, String id) {
    return Science(
      id: id,
      name: json['name']?.toString() ?? '',
      description: json['desc']?.toString() ?? '', // "description" is now "desc"
      subCat: json['sub_cat']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': description, // "description" is now "desc"
      'sub_cat': subCat,
    };
  }
}
