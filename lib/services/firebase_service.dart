import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/poem.dart';
import '../models/author.dart';
import '../models/madhab.dart';
import '../models/science.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ----- Poem Operations ----- //

  // 1.   Poem Fetching
  Future<List<Poem>> getPoems() async {
    try {
      final querySnapshot = await _firestore.collection('poems').get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs
            .map((doc) => Poem.fromJson(doc.data(), doc.id))
            .toList();
      } else {
        print("[DEBUG] No documents found in 'poems' collection.");
        return [];
      }
    } catch (e) {
      print("[ERROR] Failed to get poems: \$e");
      return [];
    }
  }

  // 5. Get Document By Id
  Future<DocumentSnapshot?> getDocument(
      String collection, String documentId) async {
    try {
      final DocumentSnapshot document =
          await _firestore.collection(collection).doc(documentId).get();
      return document;
    } catch (e) {
      print("[ERROR] Failed to get document: \$e");
      return null;
    }
  }

  // 2. Add Poem
  Future<void> addPoem(Poem poem) async {
    try {
      await _firestore.collection('poems').add(poem.toJson());
      print("[DEBUG] Poem added successfully.");
    } catch (e) {
      print("[ERROR] Failed to add poem: \$e");
      // Consider rethrowing the exception for the UI to handle
    }
  }

  Future<String> getFullPoemText(String poemId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('poems')
          .doc(poemId)
          .get();

      if (!doc.exists) {
        print("[ERROR] Poem document not found: $poemId");
        return '';
      }

      // Try to get the full text first
      final text = doc.data()?['fullText'] as String?;
      if (text == null || text.isEmpty) {
        // Fallback to regular text if full text is not available
        final fallbackText = doc.data()?['text'] as String?;
        if (fallbackText == null || fallbackText.isEmpty) {
          print("[WARNING] No text found for poem: $poemId");
          return '';
        }
        return fallbackText;
      }

      return text;
    } catch (e) {
      print("[ERROR] Failed to load poem text: $e");
      throw Exception('Failed to load poem text. Please try again.');
    }
  }

  // ----- Author Operations ----- //

  // 3. Fetch All Authors
  Future<List<Author>> getAuthors() async {
    try {
      final querySnapshot = await _firestore.collection('authors').get();
      return querySnapshot.docs
          .map((doc) => Author.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("[ERROR] Failed to get authors: \$e");
      return [];
    }
  }

  Future<String> getAuthorName(String authorId) async {
    final doc = await FirebaseFirestore.instance
        .collection('authors')
        .doc(authorId)
        .get();
    return doc.data()?['name'] ?? 'Unknown Author';
  }

  Future<void> addAuthor(Author author) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('authors')
          .add(author.toJson());
      print("[DEBUG] Author added with ID: ${docRef.id}");
    } catch (e) {
      print("[ERROR] Failed to add author: $e");
      throw Exception('Failed to add author');
    }
  }

  Future<Author> getAuthorById(String authorId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('authors')
          .doc(authorId)
          .get();

      if (!doc.exists) {
        throw Exception('Author not found');
      }

      return Author.fromJson(doc.data()!, doc.id);
    } catch (e) {
      print("[ERROR] Failed to get author details: $e");
      throw Exception('Failed to load author details');
    }
  }

  // ----- Science Operations ----- //

  // 6. Fetch All Sciences
  Future<List<Science>> getSciences() async {
    try {
      final querySnapshot = await _firestore.collection('sciences').get();
      return querySnapshot.docs
          .map((doc) => Science.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("[ERROR] Failed to get sciences: \$e");
      return [];
    }
  }

  Future<String> getScienceName(String scienceId) async {
    final doc = await FirebaseFirestore.instance
        .collection('sciences')
        .doc(scienceId)
        .get();
    return doc.data()?['name'] ?? 'Unknown Science';
  }

  // ----- Madhab Operations ----- //

  // 4. Fetch All Madhabs
  Future<List<Madhab>> getMadhabs() async {
    try {
      final querySnapshot = await _firestore.collection('madhab').get();
      return querySnapshot.docs
          .map((doc) => Madhab.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("[ERROR] Failed to get madhabs: \$e");
      return [];
    }
  }

  Future<String> getMadhabName(String madhabId) async {
    final doc = await FirebaseFirestore.instance
        .collection('madhab')
        .doc(madhabId)
        .get();
    return doc.data()?['name'] ?? 'Unknown Madhab';
  }
}
