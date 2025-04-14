class Madhab {
  final String id;
  final String name;
  final String description;

  Madhab({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Madhab.fromJson(Map<String, dynamic> json, String id) {
    return Madhab(
      id: id,
      name: json['name']?.toString() ?? '',
      description: json['desc']?.toString() ?? '', // "description" is now "desc"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': description, // "description" is now "desc"
    };
  }
}
