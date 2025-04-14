
class Poem {
  final String id;
  final String title;
  final String text;
  final int linesCount;
  final String scienceId;
  final String madhabId;
  final String level;
  final bool hasContext;
  final String context;
  final String source;
  final String authorId;

  Poem({
    required this.id,
    required this.title,
    required this.text,
    required this.linesCount,
    required this.scienceId,
    required this.madhabId,
    required this.level,
    required this.hasContext,
    required this.context,
    required this.source,
    required this.authorId,
  });


  factory Poem.fromJson(Map<String, dynamic> json, String id) {
    // Helper function to safely parse the lines_count
    int parseLinesCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0; // Try parsing String
      if (value is double) return value.toInt(); // Handle potential doubles
      print("[WARNING] Unexpected type for lines_count: ${value.runtimeType}");
      return 0; // Default fallback
    }

    // Helper function to safely parse has_context
    bool parseHasContext(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) {
        // Handle string representations of boolean
        return value.toLowerCase() == 'true';
      }
      if (value is int) {
        // Handle integer representations (e.g., 1 for true, 0 for false)
        return value == 1;
      }
      print("[WARNING] Unexpected type for has_context: ${value.runtimeType}");
      return false; // Default fallback
    }

    return Poem(
      id: id,
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      linesCount: parseLinesCount(json['lines_count']),
      scienceId: json['sci_id']?.toString() ?? '',
      madhabId: json['madh_id']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      hasContext: parseHasContext(json['has_context']),
      context: json['context']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'text': text,
      'lines_count': linesCount.toString(), // Store as string
      'sci_id': scienceId,
      'madh_id': madhabId,
      'level': level,
      'has_context': hasContext.toString(), // Store as string
      'context': context,
      'source': source,
      'author_id': authorId,
    };
  }
}
