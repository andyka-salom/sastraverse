import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on the current theme for consistency
    final Color scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final Color cardColor = Theme.of(context).cardColor;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color subtleTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.65);
    final Color borderColor = Colors.grey[isDarkMode ? 700 : 300]!;
    final Color placeholderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'SastraVerse',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    FilterButton(
                      text: 'All',
                      isSelected: _selectedFilter == 'All',
                      onPressed: () => setState(() => _selectedFilter = 'All'),
                      textColor: textColor,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                      cardColor: cardColor,
                    ),
                    const SizedBox(width: 10),
                    FilterButton(
                      text: 'Genre',
                      icon: CupertinoIcons.tag, // Use Cupertino icon
                      isSelected: _selectedFilter == 'Genre',
                      onPressed: () => setState(() => _selectedFilter = 'Genre'),
                      textColor: textColor,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                      cardColor: cardColor,
                    ),
                    const SizedBox(width: 10),
                    FilterButton(
                      text: 'Suggestions',
                      icon: CupertinoIcons.lightbulb, // Use Cupertino icon
                      isSelected: _selectedFilter == 'Suggestions',
                      onPressed: () => setState(() => _selectedFilter = 'Suggestions'),
                      textColor: textColor,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                      cardColor: cardColor,
                    ),
                    const SizedBox(width: 10),
                    FilterButton(
                      text: 'Top Rated',
                      icon: CupertinoIcons.star, // Use Cupertino icon
                      isSelected: _selectedFilter == 'Top Rated',
                      onPressed: () => setState(() => _selectedFilter = 'Top Rated'),
                      textColor: textColor,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                      cardColor: cardColor,
                    ),
                  ],
                ),
              ),
            ),

            // --- Banner Image (Conditional) ---
            if (_selectedFilter == 'All' || _selectedFilter == 'Suggestions')
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0), // Adjust padding
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0), // Consistent rounding
                  child: Image.asset(
                    'assets/images/book_cover.png', // Ensure this path is correct in pubspec.yaml and project structure
                    height: MediaQuery.of(context).size.height * 0.22, // Slightly smaller banner
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Optional: Add error handling for asset image
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: MediaQuery.of(context).size.height * 0.22,
                      color: placeholderColor,
                      child: Center(child: Icon(CupertinoIcons.photo, color: subtleTextColor)),
                    ),
                  ),
                ),
              ),
            // Add spacing if banner is not shown
            if (_selectedFilter != 'All' && _selectedFilter != 'Suggestions')
              const SizedBox(height: 16),

            // --- Main Content Area ---
            Expanded(
              child: Builder(
                builder: (context) => _buildContent(
                    textColor, cardColor, subtleTextColor, primaryColor, placeholderColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color? textColor, Color cardColor, Color subtleTextColor, Color primaryColor, Color placeholderColor) {
    switch (_selectedFilter) {
      case 'All':
        return _buildAllNovels(textColor, cardColor, subtleTextColor, placeholderColor);
      case 'Genre':
        return _buildGenreCategories(textColor, cardColor, subtleTextColor, placeholderColor);
      case 'Suggestions':
        // Pass placeholderColor to the helper
        return _buildSuggestedNovels(textColor, cardColor, subtleTextColor, placeholderColor);
      case 'Top Rated':
        // Pass placeholderColor to the helper
        return _buildTopRatedNovels(textColor, cardColor, subtleTextColor, placeholderColor);
      default:
        return Center(child: Text('Invalid filter selected', style: TextStyle(color: textColor?.withOpacity(0.6))));
    }
  }

  Widget _buildAllNovels(Color? textColor, Color cardColor, Color subtleTextColor, Color placeholderColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('novels')
          .orderBy('title')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading novels: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => NovelCardPlaceholder(cardColor: cardColor, placeholderColor: placeholderColor),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No novels found.', style: TextStyle(color: textColor?.withOpacity(0.6))));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final novelId = snapshot.data!.docs[index].id;
            return NovelCard(
              novelId: novelId,
              title: data['title'] ?? 'No Title Provided',
              author: data['author'] ?? 'Unknown Author',
              coverImageUrl: data['coverImageUrl'] ?? '',
              description: data['description'] ?? 'No description available.',
              onTap: () {
                print('Navigate to details for novel ID: $novelId');
                // TODO: Implement navigation
                // Navigator.push(context, MaterialPageRoute(builder: (context) => NovelDetailScreen(novelId: novelId)));
              },
              textColor: textColor,
              cardColor: cardColor,
              subtleTextColor: subtleTextColor,
              placeholderColor: placeholderColor,
            );
          },
        );
      },
    );
  }

  Widget _buildGenreCategories(Color? textColor, Color cardColor, Color subtleTextColor, Color placeholderColor) {
     return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .orderBy('categories')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading categories: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a grid of placeholders
           final screenWidth = MediaQuery.of(context).size.width;
           final crossAxisCount = (screenWidth / 170).floor().clamp(2, 4);
           return GridView.builder(
             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
               crossAxisCount: crossAxisCount,
               crossAxisSpacing: 12,
               mainAxisSpacing: 12,
               childAspectRatio: 0.7,
             ),
             itemCount: 6,
             itemBuilder: (context, index) => CategoryCardPlaceholder(cardColor: cardColor, placeholderColor: placeholderColor),
           );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No categories found.', style: TextStyle(color: textColor?.withOpacity(0.6))));
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = (screenWidth / 170).floor().clamp(2, 4);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final categoryId = snapshot.data!.docs[index].id;
            return CategoryCard(
              categoryId: categoryId,
              title: data['categories'] ?? 'Unnamed Category',
              description: data['description'] ?? '',
              coverImageUrl: data['coverImageUrl'] ?? '',
              onTap: () {
                 print('Navigate to category: ${data['categories']} (ID: $categoryId)');
                 // TODO: Implement navigation
                // Navigator.push(context, MaterialPageRoute(builder: (context) => NovelsByCategoryScreen(categoryId: categoryId, categoryName: data['categories'])));
              },
               textColor: textColor,
              cardColor: cardColor,
              subtleTextColor: subtleTextColor,
              placeholderColor: placeholderColor, // Pass placeholder color
            );
          },
        );
      },
    );
  }

  // Helper to build NovelCard from a reference document (suggestion/rating)
  Widget _buildNovelFromReference(DocumentSnapshot refDoc, String collectionName, Color? textColor, Color cardColor, Color subtleTextColor, Color placeholderColor) {
    final data = refDoc.data() as Map<String, dynamic>?; // Make data nullable
    if (data == null) {
      // Handle case where document data is unexpectedly null
      return const SizedBox.shrink();
    }

    final novelId = data['novelId'] as String?;
    final ratingValue = (collectionName == 'rating' ? data['rating'] : null) as num?;

    if (novelId == null) {
      // Log or display an issue if novelId is missing
      print('Warning: Document ${refDoc.id} in $collectionName is missing novelId.');
      return const SizedBox.shrink();
      // Or return a specific error card:
      // return Card(color: cardColor, child: ListTile(title: Text('Invalid reference', style: TextStyle(color: Colors.orange))));
    }

    // Fetch the actual novel data using FutureBuilder
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('novels').doc(novelId).get(),
      builder: (context, novelSnapshot) {
        if (novelSnapshot.connectionState == ConnectionState.waiting) {
          // Show placeholder card while fetching novel details
          return NovelCardPlaceholder(cardColor: cardColor, placeholderColor: placeholderColor);
        }
        if (novelSnapshot.hasError) {
          return Card(color: cardColor, child: ListTile(title: Text('Error loading novel: $novelId', style: const TextStyle(color: Colors.redAccent))));
        }
        if (!novelSnapshot.hasData || !novelSnapshot.data!.exists) {
          return Card(color: cardColor, child: ListTile(title: Text('Novel (ID: $novelId) not found.', style: const TextStyle(color: Colors.orange))));
        }

        final novelData = novelSnapshot.data!.data() as Map<String, dynamic>;
        return NovelCard(
          novelId: novelId,
          title: novelData['title'] ?? 'No Title',
          author: novelData['author'] ?? 'Unknown Author',
          coverImageUrl: novelData['coverImageUrl'] ?? '',
          description: novelData['description'] ?? 'No description available.',
          rating: ratingValue?.toDouble(), // Pass rating if available
          onTap: () {
            print('Navigate to details for novel ID: $novelId');
             // TODO: Implement navigation
            // Navigator.push(context, MaterialPageRoute(builder: (context) => NovelDetailScreen(novelId: novelId)));
          },
          textColor: textColor,
          cardColor: cardColor,
          subtleTextColor: subtleTextColor,
          placeholderColor: placeholderColor, // Pass placeholder color
        );
      },
    );
  }

  Widget _buildSuggestedNovels(Color? textColor, Color cardColor, Color subtleTextColor, Color placeholderColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('suggestion')
          .limit(15)
          .snapshots(),
      builder: (context, snapshot) {
         if (snapshot.hasError) {
          return Center(child: Text('Error loading suggestions: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
           return ListView.separated(
             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
             itemCount: 5,
             separatorBuilder: (context, index) => const SizedBox(height: 12),
             itemBuilder: (context, index) => NovelCardPlaceholder(cardColor: cardColor, placeholderColor: placeholderColor),
           );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No suggestions available right now.', style: TextStyle(color: textColor?.withOpacity(0.6))));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final suggestionDoc = snapshot.data!.docs[index];
            return _buildNovelFromReference(suggestionDoc, 'suggestion', textColor, cardColor, subtleTextColor, placeholderColor);
          },
        );
      },
    );
  }

  Widget _buildTopRatedNovels(Color? textColor, Color cardColor, Color subtleTextColor, Color placeholderColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rating')
          .orderBy('rating', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading top rated novels: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
           return ListView.separated(
             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
             itemCount: 5,
             separatorBuilder: (context, index) => const SizedBox(height: 12),
             itemBuilder: (context, index) => NovelCardPlaceholder(cardColor: cardColor, placeholderColor: placeholderColor),
           );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No rated novels found yet.', style: TextStyle(color: textColor?.withOpacity(0.6))));
        }

        return ListView.separated(
           padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ratingDoc = snapshot.data!.docs[index];
            return _buildNovelFromReference(ratingDoc, 'rating', textColor, cardColor, subtleTextColor, placeholderColor);
          },
        );
      },
    );
  }
}

// --- Custom Widgets ---

class FilterButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color? textColor;
  final Color borderColor;
  final Color primaryColor;
  final Color cardColor;

  const FilterButton({
    Key? key,
    required this.text,
    this.icon,
    required this.isSelected,
    required this.onPressed,
    required this.textColor,
    required this.borderColor,
    required this.primaryColor,
    required this.cardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveTextColor = isSelected ? primaryColor : (textColor ?? (isDark ? Colors.white : Colors.black));
    final Color effectiveIconColor = isSelected ? primaryColor : (textColor?.withOpacity(0.7) ?? (isDark ? Colors.white70 : Colors.black54));
    final Color effectiveBackgroundColor = isSelected ? primaryColor.withOpacity(0.12) : cardColor;
    final Color effectiveBorderColor = isSelected ? primaryColor : borderColor;

    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: RawMaterialButton(
        onPressed: onPressed,
        elevation: isSelected ? 1.0 : 0.0,
        fillColor: effectiveBackgroundColor,
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(
            color: effectiveBorderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        constraints: const BoxConstraints(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 18,
                color: effectiveIconColor,
              ),
            if (icon != null) const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: effectiveTextColor,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CategoryCard extends StatelessWidget {
  final String categoryId;
  final String title;
  final String description;
  final String coverImageUrl;
  final VoidCallback onTap;
  final Color? textColor;
  final Color cardColor;
  final Color subtleTextColor;
  final Color placeholderColor;

  const CategoryCard({
    Key? key,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.onTap,
    required this.textColor,
    required this.cardColor,
    required this.subtleTextColor,
    required this.placeholderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: coverImageUrl.isNotEmpty
                  ? Image.network(
                      coverImageUrl,
                      fit: BoxFit.cover,
                      // Loading Indicator
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: placeholderColor.withOpacity(0.5),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                                 strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: placeholderColor,
                          child: Center(child: Icon(CupertinoIcons.photo, color: subtleTextColor, size: 40)),
                        );
                      },
                    )
                  : Container(
                      color: placeholderColor,
                      child: Center(child: Icon(CupertinoIcons.collections, color: subtleTextColor, size: 40)),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: subtleTextColor,
                           height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class NovelCard extends StatelessWidget {
  final String novelId;
  final String title;
  final String author;
  final String coverImageUrl;
  final String description;
  final VoidCallback onTap;
  final double? rating;
  final Color? textColor;
  final Color cardColor;
  final Color subtleTextColor;
  final Color placeholderColor;

  const NovelCard({
    Key? key,
    required this.novelId,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.description,
    required this.onTap,
    this.rating,
    required this.textColor,
    required this.cardColor,
    required this.subtleTextColor,
    required this.placeholderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  width: 85,
                  height: 125,
                  child: coverImageUrl.isNotEmpty
                      ? Image.network(
                          coverImageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                                color: placeholderColor.withOpacity(0.5),
                                child: Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: placeholderColor,
                              child: Center(child: Icon(CupertinoIcons.book, color: subtleTextColor)),
                            );
                          },
                        )
                      : Container( // Placeholder if no URL
                          color: placeholderColor,
                           child: Center(child: Icon(CupertinoIcons.book, color: subtleTextColor)),
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
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by $author',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: subtleTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: textColor?.withOpacity(0.8),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // --- Rating Display ---
                    if (rating != null && rating! > 0)
                      Row(
                        children: [
                          Icon(CupertinoIcons.star_fill, color: Colors.amber, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
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


// --- Placeholder Widgets ---

class NovelCardPlaceholder extends StatelessWidget {
  final Color cardColor;
  final Color placeholderColor;

  const NovelCardPlaceholder({Key? key, required this.cardColor, required this.placeholderColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholderContent(cardColor, placeholderColor);
  }


  Widget _buildPlaceholderContent(Color cardColor, Color contentPlaceholderColor) {
    return Card(
      elevation: 1.5,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 85,
              height: 125,
              decoration: BoxDecoration(
                 color: contentPlaceholderColor,
                 borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(width: double.infinity, height: 20, color: contentPlaceholderColor, margin: const EdgeInsets.only(bottom: 8)),
                   Container(width: double.infinity * 0.6, height: 16, color: contentPlaceholderColor, margin: const EdgeInsets.only(bottom: 12)),
                   Container(width: double.infinity, height: 14, color: contentPlaceholderColor, margin: const EdgeInsets.only(bottom: 6)),
                   Container(width: double.infinity, height: 14, color: contentPlaceholderColor, margin: const EdgeInsets.only(bottom: 6)),
                   Container(width: double.infinity * 0.8, height: 14, color: contentPlaceholderColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Placeholder for Category Card
class CategoryCardPlaceholder extends StatelessWidget {
 final Color cardColor;
 final Color placeholderColor;

 const CategoryCardPlaceholder({Key? key, required this.cardColor, required this.placeholderColor}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return _buildPlaceholderContent(cardColor, placeholderColor);
 }

 Widget _buildPlaceholderContent(Color cardColor, Color contentPlaceholderColor) {
   return Card(
     elevation: 1.5,
     color: cardColor,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(12.0),
     ),
     clipBehavior: Clip.antiAlias,
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
       children: [
         // Placeholder Image Area
         Expanded(
           flex: 3,
           child: Container(color: contentPlaceholderColor),
         ),
         // Placeholder Text Area
         Expanded(
           flex: 2,
           child: Padding(
             padding: const EdgeInsets.all(10.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Container(width: double.infinity * 0.8, height: 18, color: contentPlaceholderColor, margin: const EdgeInsets.only(bottom: 6)),
                 Container(width: double.infinity * 0.5, height: 14, color: contentPlaceholderColor),
               ],
             ),
           ),
         ),
       ],
     ),
   );
 }
}