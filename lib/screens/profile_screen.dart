import 'package:flutter/material.dart';
import 'package:myapp/models/author.dart';
import 'package:myapp/models/madhab.dart';
import 'package:myapp/models/poem.dart';
import 'package:myapp/models/science.dart';
import 'package:myapp/services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  // Form controllers
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  final _levelController = TextEditingController();
  final _contextController = TextEditingController();
  final _sourceController = TextEditingController();

  String? _selectedScienceId;
  String? _selectedAuthorId;
  String? _selectedMadhabId;
  bool _hasContext = false;

  List<Author> _authors = [];
  List<Madhab> _madhabs = [];
  List<Science> _sciences = [];

  @override
  void initState() {
    super.initState();
    _loadAuthorsMadhabsAndSciences();
  }

  Future<void> _loadAuthorsMadhabsAndSciences() async {
    try{
        _authors = await _firebaseService.getAuthors();
        print("[DEBUG] Authors: \$_authors");
        _madhabs = await _firebaseService.getMadhabs();
        print("[DEBUG] Madhabs: \$_madhabs");
        _sciences = await _firebaseService.getSciences();
        print("[DEBUG] Sciences: \$_sciences");
    }catch(e){
      print("[ERROR] Failed to load AuthorsMadhabsAndSciences: $e");
    }

    setState(() {}); // Trigger UI update
  }

  Future<void> _addPoem() async {
    final newPoem = Poem(
      id: '', // Firestore will generate the ID
      title: _titleController.text,
      text: _textController.text,
      linesCount: int.tryParse(_levelController.text) ?? 0,
      scienceId: _selectedScienceId ?? '',
      madhabId: _selectedMadhabId ?? '',
      level: _levelController.text,
      hasContext: _hasContext,
      context: _contextController.text,
      source: _sourceController.text,
      authorId: _selectedAuthorId ?? '',
    );

    await _firebaseService.addPoem(newPoem);

    // Clear the form
    _titleController.clear();
    _textController.clear();
    _levelController.clear();
    _contextController.clear();
    _sourceController.clear();
    _selectedScienceId = null;
    _selectedAuthorId = null;
    _selectedMadhabId = null;
    _hasContext = false;

    setState(() {}); // Update UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Poem', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Text'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(labelText: 'Level (Lines Count)'),
                keyboardType: TextInputType.number,
              ),
                DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Science'),
                value: _selectedScienceId,
                items: _sciences.map((science) {
                  return DropdownMenuItem<String>(
                    value: science.id,
                    child: Text(science.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedScienceId = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Author'),
                value: _selectedAuthorId,
                items: _authors.map((author) {
                  return DropdownMenuItem<String>(
                    value: author.id,
                    child: Text(author.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAuthorId = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Madhab'),
                value: _selectedMadhabId,
                items: _madhabs.map((madhab) {
                  return DropdownMenuItem<String>(
                    value: madhab.id,
                    child: Text(madhab.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMadhabId = value;
                  });
                },
              ),
              Row(
                children: [
                  const Text('Has Context?'),
                  Checkbox(
                    value: _hasContext,
                    onChanged: (value) {
                      setState(() {
                        _hasContext = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              TextFormField(
                controller: _contextController,
                decoration: const InputDecoration(labelText: 'Context'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(labelText: 'Source'),
              ),
              ElevatedButton(
                onPressed: _addPoem,
                child: const Text('Add Poem'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
