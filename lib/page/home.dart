import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appearance/appearance.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    Appearance.of(context);

    return Scaffold( // Removed background color in favour of main layout
      appBar: AppBar(  // Removed Switch, Remove back since its not needed
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'SastraVerse',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  FilterButton(
                    text: 'All',
                    isSelected: _selectedFilter == 'All',
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    text: 'Genre',
                    icon: Icons.category,
                    isSelected: _selectedFilter == 'Genre',
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'Genre';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    text: 'Suggestions',
                    icon: Icons.lightbulb_outline,
                    isSelected: _selectedFilter == 'Suggestions',
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'Suggestions';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    text: 'Top Rated',
                    icon: Icons.star,
                    isSelected: _selectedFilter == 'Top Rated',
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'Top Rated';
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/images/book_cover.png',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedFilter) {
      case 'All':
        return _buildAllNovels();
      case 'Genre':
        return _buildGenreCategories();
      case 'Suggestions':
        return _buildSuggestedNovels();
      case 'Top Rated':
        return _buildTopRatedNovels();
      default:
        return const Center(child: Text('Invalid filter'));
    }
  }

  Widget _buildAllNovels() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('novels').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No novels found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return NovelCard(
              title: data['title'] ?? '',
              author: data['author'] ?? '',
              coverImageUrl: data['coverImageUrl'] ?? '',
              description: data['description'] ?? '',
              onTap: () {
                // Navigate to Novel Details Screen
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGenreCategories() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return CategoryCard(
              title: data['categories'],
              description: data['description'],
              coverImageUrl: data['coverImageUrl'] ?? '',
              onTap: () {
                // Navigate to novels by category
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSuggestedNovels() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('suggestion').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No suggestions found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final novelId = data['novelId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('novels').doc(novelId).get(),
              builder: (context, novelSnapshot) {
                if (novelSnapshot.hasError) {
                  return ListTile(title: Text('Error loading novel'));
                }

                if (novelSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(title: Text('Loading novel...'));
                }

                if (!novelSnapshot.hasData || !novelSnapshot.data!.exists) {
                  return const ListTile(title: Text('Novel not found'));
                }

                final novelData = novelSnapshot.data!.data() as Map<String, dynamic>;
                return NovelCard(
                  title: novelData['title'] ?? 'No Title',
                  author: novelData['author'] ?? 'No Author',
                  coverImageUrl: novelData['coverImageUrl'] ?? '',
                  description: novelData['description'] ?? '',
                  onTap: () {
                    // Navigate to Novel Details Screen
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTopRatedNovels() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rating').orderBy('rating', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No ratings found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final ratingData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final novelId = ratingData['novelId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('novels').doc(novelId).get(),
              builder: (context, novelSnapshot) {
                if (novelSnapshot.hasError) {
                  return ListTile(title: Text('Error loading novel'));
                }

                if (novelSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(title: Text('Loading novel...'));
                }

                if (!novelSnapshot.hasData || !novelSnapshot.data!.exists) {
                  return const ListTile(title: Text('Novel not found'));
                }

                final novelData = novelSnapshot.data!.data() as Map<String, dynamic>;
                return NovelCard(
                  title: novelData['title'] ?? 'No Title',
                  author: novelData['author'] ?? '',
                  coverImageUrl: novelData['coverImageUrl'] ?? '',
                  description: novelData['description'] ?? '',
                  rating: ratingData['rating'] ?? 0,
                  onTap: () {
                    // Navigate to Novel Details Screen
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    Key? key,
    required this.text,
    this.icon,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.15) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            if (icon != null) Icon(icon, size: 16, color: theme.textTheme.bodyMedium!.color),
            if (icon != null) const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String coverImageUrl;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.error_outline, color: Colors.red));
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class NovelCard extends StatelessWidget {
  final String title;
  final String author;
  final String coverImageUrl;
  final String description;
  final VoidCallback onTap;
  final int rating;

  const NovelCard({
    Key? key,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.description,
    required this.onTap,
    this.rating = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  coverImageUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      author,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (rating > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            rating.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.bodyMedium!.color,
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