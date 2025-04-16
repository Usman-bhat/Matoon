import 'package:flutter/material.dart';
import 'package:myapp/models/poem.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:myapp/utils/text_parser.dart';

class PoemDetailScreen extends StatefulWidget {
  final Poem poem;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const PoemDetailScreen({
    Key? key,
    required this.poem,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<PoemDetailScreen> createState() => _PoemDetailScreenState();
}

class _PoemDetailScreenState extends State<PoemDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  String? _authorName;
  String? _scienceName;
  String? _madhabName;
  String? _fullText;
  String _errorMessage = '';
  List<List<String>> _pages = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadFullPoemData();
  }

  Future<void> _loadFullPoemData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load metadata
      final metadataFutures = await Future.wait([
        _firebaseService.getAuthorName(widget.poem.authorId),
        _firebaseService.getScienceName(widget.poem.scienceId),
        _firebaseService.getMadhabName(widget.poem.madhabId),
      ]);

      if (!mounted) return;

      setState(() {
        _authorName = metadataFutures[0];
        _scienceName = metadataFutures[1];
        _madhabName = metadataFutures[2];
      });

      // Load full text
      final poemText = await _firebaseService.getFullPoemText(widget.poem.id);

      if (!mounted) return;

      if (poemText.isEmpty) {
        throw Exception('No poem text available');
      }

      // Parse the text into pages
      final parsedPages = TextParser.parsePages(poemText);

      setState(() {
        _fullText = poemText;
        _pages = parsedPages;
        _isLoading = false;
      });

      print("[DEBUG] Loaded ${_pages.length} pages");
      print(
          "[DEBUG] First page content: ${_pages.isNotEmpty ? _pages[0] : 'empty'}");
    } catch (e) {
      if (!mounted) return;

      print("[ERROR] Failed to load poem details: $e");
      setState(() {
        _errorMessage = 'Failed to load poem content';
        _isLoading = false;
        _pages = [];
      });
    }
  }

  Widget _buildPoemContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFullPoemData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_pages.isEmpty || _currentPage >= _pages.length) {
      return const Center(
        child: Text(
          'No content available',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4E5),
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(
            image: AssetImage('assets/images/paper_bg.png'),
            repeat: ImageRepeat.repeat,
            opacity: 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _pages[_currentPage].length,
                itemBuilder: (context, index) {
                  final line = _pages[_currentPage][index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SelectableText(
                      line,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            height: 1.8,
                            fontFamily: 'Amiri',
                            color: const Color(0xFF2C1810),
                          ),
                    ),
                  );
                },
              ),
            ),
            if (_pages.length > 1)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: _currentPage > 0
                          ? () => setState(() => _currentPage--)
                          : null,
                    ),
                    Text(
                      '${_currentPage + 1}/${_pages.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: _currentPage < _pages.length - 1
                          ? () => setState(() => _currentPage++)
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poem.title),
        actions: [
          IconButton(
            icon: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? Colors.red : null,
            ),
            onPressed: widget.onToggleFavorite,
          ),
        ],
      ),
      body: Column(
        children: [
          // Metadata Card
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Author: ${_authorName ?? 'Loading...'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.school, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Science: ${_scienceName ?? 'Loading...'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.menu_book, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Madhab: ${_madhabName ?? 'Loading...'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Poem Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadFullPoemData,
              child: _buildPoemContent(),
            ),
          ),
        ],
      ),
    );
  }
}
