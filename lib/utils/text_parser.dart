import 'package:html/parser.dart' as html;

class TextParser {
  static List<List<String>> parsePages(String htmlText) {
    final document = html.parse(htmlText);
    final pages = <List<String>>[];
    List<String> currentPageLines = [];

    final paragraphs = document.getElementsByClassName('g-paragraph');

    for (var p in paragraphs) {
      if (p.classes.contains('g-ltr') &&
          p.getElementsByClassName('g-page-separator').isNotEmpty) {
        if (currentPageLines.isNotEmpty) {
          pages.add(currentPageLines);
          currentPageLines = [];
        }
        continue;
      }

      if (p.classes.contains('g-rtl')) {
        String lineText = '';

        // Handle basmala specially
        final basmala = p.getElementsByClassName('g-basmla');
        if (basmala.isNotEmpty) {
          lineText = basmala[0].text.trim();
          currentPageLines.add(lineText);
          lineText = '';
        }

        // Handle list markers as separate lines
        final listMarkers = p.getElementsByClassName('g-list');
        if (listMarkers.isNotEmpty) {
          String markerText = listMarkers[0].text.trim();
          if (markerText.isNotEmpty) {
            currentPageLines.add(markerText);
          }
        }

        // Handle remaining text
        final nodes = p.nodes.where((node) =>
            node.text!.trim().isNotEmpty &&
            !node.text!.contains('g-basmla') &&
            !node.text!.contains('g-list'));

        for (var node in nodes) {
          if (lineText.isNotEmpty) {
            lineText += ' ';
          }
          lineText += node.text!.trim();
        }

        if (lineText.isNotEmpty) {
          currentPageLines.add(lineText);
        }
      }
    }

    if (currentPageLines.isNotEmpty) {
      pages.add(currentPageLines);
    }

    return pages;
  }
}
