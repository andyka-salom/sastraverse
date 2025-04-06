import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Novel Model Class
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
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return Novel(
      id: doc.id,
      title: data['title'] as String? ?? 'No Title',
      author: data['author'] as String? ?? 'Unknown Author',
      categoryId: data['categoryId'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String? ?? '',
      description: data['description'] as String? ?? 'No description available.',
    );
  }
}

// --- Search Page Widget ---
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  Stream<QuerySnapshot>? _initialNovelStream;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initialNovelStream = FirebaseFirestore.instance
        .collection('novels')
        .orderBy('title')
        .snapshots();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
     final newSearchTerm = _searchController.text.trim();
     if (_searchTerm != newSearchTerm) {
       setState(() { _searchTerm = newSearchTerm; });
     }
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final Color cardColor = Theme.of(context).cardColor;
    final Color subtleTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7);
    final Color hintColor = Theme.of(context).hintColor;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color searchFieldBgColor = isDarkMode ? Colors.grey[850]! : Colors.grey[200]!;
    final Color scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildMaterialSearchField(hintColor, textColor, searchFieldBgColor),
        toolbarHeight: 65,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _initialNovelStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.exclamationmark_octagon, color: Colors.redAccent, size: 40),
                            const SizedBox(height: 10),
                            Text('Error: ${snapshot.error}', style: GoogleFonts.poppins(color: Colors.redAccent)),
                          ],
                        ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator(radius: 15));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                     return Center(
                       child: Text(
                         'No novels available in the library.',
                         textAlign: TextAlign.center,
                         style: GoogleFonts.poppins(color: subtleTextColor, fontSize: 15),
                       ),
                     );
                  }

                  // Client-Side Filtering
                  List<Novel> allNovels = snapshot.data!.docs
                      .map((doc) => Novel.fromDocument(doc))
                      .toList();

                  List<Novel> filteredNovels = allNovels;
                  if (_searchTerm.isNotEmpty) {
                    filteredNovels = allNovels.where((novel) {
                      final searchTermLower = _searchTerm.toLowerCase();
                      return novel.title.toLowerCase().contains(searchTermLower) ||
                             novel.author.toLowerCase().contains(searchTermLower) ||
                             novel.description.toLowerCase().contains(searchTermLower);
                    }).toList();
                  }

                  if (filteredNovels.isEmpty) {
                    return Center(
                      child: Text(
                        _searchTerm.isEmpty
                            ? 'Start typing to search for novels.'
                            : 'No results found for "$_searchTerm"',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: subtleTextColor, fontSize: 15),
                      ),
                    );
                  }

                  // Use Material ListView
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: filteredNovels.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final novel = filteredNovels[index];
                      return NovelSearchCard(
                        novel: novel,
                        textColor: textColor,
                        cardColor: cardColor,
                        subtleTextColor: subtleTextColor,
                        onTap: () {
                          print('Tapped on: ${novel.title} (ID: ${novel.id})');
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => NovelDetailScreen(novelId: novel.id)));
                          FocusScope.of(context).unfocus(); // Hide keyboard
                        },
                      );
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

  // --- Build Material TextField BUT with Forced Cupertino Icons ---
  Widget _buildMaterialSearchField(Color hintColor, Color? textColor, Color bgColor) {
    return SizedBox(
      height: 48,
      child: TextField( // Always use Material TextField
        controller: _searchController,
        style: GoogleFonts.poppins(color: textColor, fontSize: 15.5),
        decoration: InputDecoration(
          hintText: 'Search Novels, Authors...',
          hintStyle: GoogleFonts.poppins(color: hintColor, fontSize: 15.5),
          prefixIcon: Icon(CupertinoIcons.search, color: hintColor, size: 20),
          suffixIcon: _searchTerm.isNotEmpty
              ? IconButton(
                  icon: const Icon(CupertinoIcons.clear_thick_circled, size: 18),
                  color: hintColor,
                  splashRadius: 20,
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          filled: true,
          fillColor: bgColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.0),
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) {
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}

// --- Novel Search Card Widget (Forcing Cupertino Icons) ---
class NovelSearchCard extends StatelessWidget {
  final Novel novel;
  final Color? textColor;
  final Color cardColor;
  final Color subtleTextColor;
  final VoidCallback onTap;

  const NovelSearchCard({
    Key? key,
    required this.novel,
    required this.textColor,
    required this.cardColor,
    required this.subtleTextColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color placeholderBgColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;

    // Use Material Card
    return Card(
      elevation: 1.5,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Cover Image ---
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: 70,
                  height: 105,
                  child: novel.coverImageUrl.isNotEmpty
                      ? Image.network(
                          novel.coverImageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: placeholderBgColor,
                              child: const Center(child: CupertinoActivityIndicator(radius: 12)),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: placeholderBgColor,
                              child: Icon(
                                CupertinoIcons.book,
                                color: subtleTextColor, size: 35,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: placeholderBgColor,
                          child: Icon(
                            CupertinoIcons.book,
                            color: subtleTextColor, size: 35,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // --- Text Information ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novel.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${novel.author}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: subtleTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      novel.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: textColor?.withOpacity(0.8),
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}