class Author {
  final String id;
  final String name;
  final String bio;
  final String dob;
  final String dod;
  final String era;
  final String otherWorks;

  Author({
    required this.id,
    required this.name,
    required this.bio,
    required this.dob,
    required this.dod,
    required this.era,
    required this.otherWorks,
  });

  factory Author.fromJson(Map<String, dynamic> json, String id) {
    return Author(
      id: id,
      name: json['name']?.toString() ?? '',
      bio: json['details']?.toString() ?? '', // "details" is now "bio"
      dob: json['dob']?.toString() ?? '',
      dod: json['dod']?.toString() ?? '',
      era: json['era']?.toString() ?? '',
      otherWorks: json['other_works']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'details': bio, // "bio" is now "details"
      'dob': dob,
      'dod': dod,
      'era': era,
      'other_works': otherWorks,
    };
  }
}
