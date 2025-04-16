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

  // Add new controllers for author management
  final _authorNameController = TextEditingController();
  final _authorBirthYearController = TextEditingController();
  final _authorDeathYearController = TextEditingController();
  final _authorBioController = TextEditingController();
  final _authorEraController = TextEditingController();
  final _authorOtherWorksController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAuthorsMadhabsAndSciences();
  }

  Future<void> _loadAuthorsMadhabsAndSciences() async {
    try {
      _authors = await _firebaseService.getAuthors();
      print("[DEBUG] Authors: \$_authors");
      _madhabs = await _firebaseService.getMadhabs();
      print("[DEBUG] Madhabs: \$_madhabs");
      _sciences = await _firebaseService.getSciences();
      print("[DEBUG] Sciences: \$_sciences");
    } catch (e) {
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

  Future<void> _addAuthor() async {
    // Validate inputs
    if (_authorNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter author name')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final newAuthor = Author(
        id: '', // Firestore will generate
        name: _authorNameController.text.trim(),
        dob: _authorBirthYearController.text.trim(),
        dod: _authorDeathYearController.text.trim(),
        bio: _authorBioController.text.trim(),
        era: _authorEraController.text.trim(),
        otherWorks: _authorOtherWorksController.text.trim(),
      );

      await _firebaseService.addAuthor(newAuthor);

      // Clear form
      _authorNameController.clear();
      _authorBirthYearController.clear();
      _authorDeathYearController.clear();
      _authorBioController.clear();
      _authorEraController.clear();
      _authorOtherWorksController.clear();

      await _loadAuthorsMadhabsAndSciences();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Author added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("[ERROR] Failed to add author: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Add Poem'),
              Tab(icon: Icon(Icons.person_add), text: 'Add Author'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAddPoemTab(),
            _buildAddAuthorTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPoemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Poem',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Text',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                maxLines: 5,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Science',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.science),
                      ),
                      value: _selectedScienceId,
                      items: _sciences.map((science) {
                        return DropdownMenuItem<String>(
                          value: science.id,
                          child: Text(science.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedScienceId = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Author',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      value: _selectedAuthorId,
                      items: _authors.map((author) {
                        return DropdownMenuItem<String>(
                          value: author.id,
                          child: Text(author.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedAuthorId = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _levelController,
                      decoration: const InputDecoration(
                        labelText: 'Lines Count',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Madhab',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      value: _selectedMadhabId,
                      items: _madhabs.map((madhab) {
                        return DropdownMenuItem<String>(
                          value: madhab.id,
                          child: Text(madhab.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedMadhabId = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Has Context'),
                value: _hasContext,
                onChanged: (value) =>
                    setState(() => _hasContext = value ?? false),
              ),
              if (_hasContext) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contextController,
                  decoration: const InputDecoration(
                    labelText: 'Context',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addPoem,
                icon: const Icon(Icons.add),
                label: const Text('Add Poem'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddAuthorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Author',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorNameController,
                decoration: const InputDecoration(
                  labelText: 'Author Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _authorBirthYearController,
                      decoration: const InputDecoration(
                        labelText: 'Birth Year',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _authorDeathYearController,
                      decoration: const InputDecoration(
                        labelText: 'Death Year',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorEraController,
                decoration: const InputDecoration(
                  labelText: 'Era',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.history),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorOtherWorksController,
                decoration: const InputDecoration(
                  labelText: 'Other Works',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.library_books),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorBioController,
                decoration: const InputDecoration(
                  labelText: 'Biography',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _addAuthor,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.person_add),
                label: Text(_isLoading ? 'Adding...' : 'Add Author'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _levelController.dispose();
    _contextController.dispose();
    _sourceController.dispose();
    _authorNameController.dispose();
    _authorBirthYearController.dispose();
    _authorDeathYearController.dispose();
    _authorBioController.dispose();
    _authorEraController.dispose();
    _authorOtherWorksController.dispose();
    super.dispose();
  }
}
