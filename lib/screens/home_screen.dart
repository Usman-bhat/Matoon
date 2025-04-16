import 'package:flutter/material.dart';
import 'package:myapp/models/poem.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/screens/poem_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final String _favoritesKey = 'favorite_poems';
  List<Poem> _poems = [];
  Set<String> _favorites = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadPoems();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = Set<String>.from(prefs.getStringList(_favoritesKey) ?? []);
    });
  }

  Future<void> _toggleFavorite(String poemId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(poemId)) {
        _favorites.remove(poemId);
      } else {
        _favorites.add(poemId);
      }
    });
    await prefs.setStringList(_favoritesKey, _favorites.toList());
  }

  Future<void> _loadPoems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      _poems = await _firebaseService.getPoems();
      print("[DEBUG] Poems loaded successfully: ${_poems.length} poems.");
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load poems. Please try again.';
      });
      print("[ERROR] Error loading poems: $e");
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('متون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPoems,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPoems,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPoems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_poems.isEmpty) {
      return const Center(child: Text('No poems found.'));
    }

    return ListView.builder(
      itemCount: _poems.length,
      itemBuilder: (context, index) {
        final poem = _poems[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              poem.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: FutureBuilder(
              future: Future.wait([
                _firebaseService.getAuthorName(poem.authorId),
                _firebaseService.getScienceName(poem.scienceId),
              ]),
              builder: (context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Author: ${snapshot.data![0] ?? 'unkown'}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.school, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'science: ${snapshot.data![1] ?? 'جامع'}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      
                    ],
                  );
                }
                return const SizedBox(
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
            trailing: IconButton(
              icon: Icon(
                _favorites.contains(poem.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _favorites.contains(poem.id) ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(poem.id),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PoemDetailScreen(
                    poem: poem,
                    isFavorite: _favorites.contains(poem.id),
                    onToggleFavorite: () => _toggleFavorite(poem.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
