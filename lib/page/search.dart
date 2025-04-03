import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _novelsStream;

  @override
  void initState() {
    super.initState();
    _novelsStream = _firestore.collection('novels').snapshots();
  }

  void _searchNovels(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Search Novels',
            style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium!.color)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for novels or authors...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: _searchNovels,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _novelsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium!.color)),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Novel> novels = snapshot.data!.docs.map((doc) => Novel.fromDocument(doc)).toList();

                  // Perform search filtering
                  if (_searchTerm.isNotEmpty) {
                    novels = novels.where((novel) =>
                    novel.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                        novel.author.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                        novel.description.toLowerCase().contains(_searchTerm.toLowerCase()) // Add description search
                    ).toList();
                  }

                  if (novels.isEmpty) {
                    return Center(
                      child: Text('No novels found',
                          style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium!.color)),
                    );
                  }

                  return ListView.builder(
                    itemCount: novels.length,
                    itemBuilder: (context, index) {
                      return _buildNovelCard(novels[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNovelCard(Novel novel) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                novel.coverImageUrl,
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error_outline, color: Colors.red));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    novel.title,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium!.color),
                  ),
                  Text(
                    novel.author,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color!
                            .withOpacity(0.7)),
                  ),
                  Text( // Show description
                      novel.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color!
                            .withOpacity(0.8),
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Novel {
  final String title;
  final String author;
  final String categoryId;
  final String coverImageUrl;
  final String description;
  final String id;

  Novel({
    required this.title,
    required this.author,
    required this.categoryId,
    required this.coverImageUrl,
    required this.description,
    required this.id,
  });

  factory Novel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Novel(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      categoryId: data['categoryId'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      description: data['description'] ?? '',  // Get Description
    );
  }
}