import 'package:flutter/material.dart';
import 'package:myapp/models/poem.dart';
import 'package:myapp/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Poem> _poems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPoems();
  }

  Future<void> _loadPoems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _poems = await _firebaseService.getPoems();
      print("[DEBUG] Poems loaded successfully: ${_poems.length} poems.");
    } catch (e) {
      print("[ERROR] Error loading poems: \$e");
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _poems.isEmpty
              ? const Center(child: Text('No poems found.'))
              : ListView.builder(
                  itemCount: _poems.length,
                  itemBuilder: (context, index) {
                    final poem = _poems[index];
                    return ListTile(
                      title: Text(poem.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Science: ${poem.scienceId}'),
                          Text('Author: ${poem.authorId}'),
                          Text('Madhab: ${poem.madhabId}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoemDetailScreen(poem: poem),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class PoemDetailScreen extends StatelessWidget {
  final Poem poem;

  const PoemDetailScreen({Key? key, required this.poem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(poem.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(poem.text, textAlign: TextAlign.right,),
      ),
    );
  }
}
