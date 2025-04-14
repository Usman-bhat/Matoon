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
        return querySnapshot.docs.map((doc) => Poem.fromJson(doc.data(), doc.id)).toList();
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
  Future<DocumentSnapshot?> getDocument(String collection, String documentId) async {
    try {
      final DocumentSnapshot document = await _firestore.collection(collection).doc(documentId).get();
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

  // ----- Author Operations ----- //

  // 3. Fetch All Authors
  Future<List<Author>> getAuthors() async {
    try {
      final querySnapshot = await _firestore.collection('authors').get();
      return querySnapshot.docs.map((doc) => Author.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      print("[ERROR] Failed to get authors: \$e");
      return [];
    }
  }

  // 6. Fetch All Sciences
  Future<List<Science>> getSciences() async {
    try {
      final querySnapshot = await _firestore.collection('sciences').get();
      return querySnapshot.docs.map((doc) => Science.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      print("[ERROR] Failed to get sciences: \$e");
      return [];
    }
  }

  // ----- Madhab Operations ----- //

  // 4. Fetch All Madhabs
  Future<List<Madhab>> getMadhabs() async {
    try {
      final querySnapshot = await _firestore.collection('madhabs').get();
      return querySnapshot.docs.map((doc) => Madhab.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      print("[ERROR] Failed to get madhabs: \$e");
      return [];
    }
  }
}
