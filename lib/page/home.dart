import 'dart:io' show Platform; // Import untuk Platform check

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import untuk widget Cupertino (jika diperlukan secara eksplisit)
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appearance/appearance.dart'; // Pastikan package ini terpasang dan diinisialisasi di main.dart jika diperlukan

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Memanggil Appearance.of(context) mungkin untuk mendeteksi tema sistem (light/dark)
    // Pastikan AppearanceProvider sudah di-setup di atas MaterialApp/CupertinoApp
    Appearance.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final Color cardColor = Theme.of(context).cardColor; // Menggunakan Theme.of(context).cardColor
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color subtleTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7);
    final Color borderColor = Colors.grey[isDarkMode ? 700 : 300]!;


    // Menggunakan Scaffold sebagai root layout utama
    // Untuk tampilan yang lebih mirip iOS, bisa menggunakan CupertinoPageScaffold
    // Tapi Scaffold lebih umum untuk cross-platform dengan elemen adaptif
    return Scaffold(
      appBar: AppBar(
        // Gunakan AppBar untuk Material look, atau CupertinoNavigationBar untuk iOS look
        // AppBar lebih fleksibel untuk dicustom lintas platform
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        automaticallyImplyLeading: false
      ),
      body: SafeArea( // SafeArea penting untuk menghindari notch/area sistem
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align filter ke kiri
          children: [
            Padding(
              // Tambahkan padding agar tidak terlalu mepet tepi
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    const SizedBox(width: 8),
                    FilterButton(
                      text: 'Genre',
                      icon: Icons.category_outlined, // Icon outline
                      isSelected: _selectedFilter == 'Genre',
                      onPressed: () => setState(() => _selectedFilter = 'Genre'),
                      textColor: textColor,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                      cardColor: cardColor,
                    ),
                    const SizedBox(width: 8),
                    FilterButton(
                      text: 'Suggestions',
                      icon: Icons.lightbulb_outline,
                      isSelected: _selectedFilter == 'Suggestions',
                      onPressed: () => setState(() => _selectedFilter = 'Suggestions'),
                      textColor: textColor,
                      borderColor: borderColor,
                      primaryColor: primaryColor,
                      cardColor: cardColor,
                    ),
                    const SizedBox(width: 8),
                    FilterButton(
                      text: 'Top Rated',
                      icon: Icons.star_outline, // Icon outline
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

            // Banner Image - Mungkin tidak perlu di semua filter?
            // Kita bisa menampilkannya hanya saat 'All' atau 'Suggestions'
            if (_selectedFilter == 'All' || _selectedFilter == 'Suggestions')
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0), // Sesuaikan padding
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.asset(
                    'assets/images/book_cover.png', // Pastikan path ini benar
                    // Tinggi bisa dibuat lebih adaptif jika perlu
                    height: MediaQuery.of(context).size.height * 0.25, // Contoh: 25% tinggi layar
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (_selectedFilter != 'All' && _selectedFilter != 'Suggestions')
              const SizedBox(height: 16),

            Expanded(
              child: _buildContent(textColor, cardColor, subtleTextColor),
            ),
          ],
        ),
      ),
    );
  }

  // Method untuk membangun konten utama berdasarkan filter
  Widget _buildContent(Color? textColor, Color cardColor, Color subtleTextColor) {
    switch (_selectedFilter) {
      case 'All':
        return _buildAllNovels(textColor, cardColor, subtleTextColor);
      case 'Genre':
        return _buildGenreCategories(textColor, cardColor, subtleTextColor);
      case 'Suggestions':
        return _buildSuggestedNovels(textColor, cardColor, subtleTextColor);
      case 'Top Rated':
        return _buildTopRatedNovels(textColor, cardColor, subtleTextColor);
      default:
        return const Center(child: Text('Invalid filter'));
    }
  }

  // --- Builder Methods untuk setiap Filter ---

  Widget _buildAllNovels(Color? textColor, Color cardColor, Color subtleTextColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('novels').orderBy('title').snapshots(), // Urutkan berdasarkan judul
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Gunakan indicator adaptif
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No novels found.', style: TextStyle(color: textColor?.withOpacity(0.6))));
        }

        // Gunakan ListView.separated untuk memberi jarak antar item
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12), // Jarak antar kartu
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final novelId = snapshot.data!.docs[index].id; // Dapatkan ID dokumen
            return NovelCard(
              novelId: novelId, // Kirim ID ke NovelCard jika perlu
              title: data['title'] ?? 'No Title',
              author: data['author'] ?? 'No Author',
              coverImageUrl: data['coverImageUrl'] ?? '', // Handle jika URL kosong/null
              description: data['description'] ?? 'No description available.',
              onTap: () {
                // Navigasi ke Detail Screen dengan novelId
                print('Navigate to details for novel ID: $novelId');
                // Navigator.push(context, MaterialPageRoute(builder: (context) => NovelDetailScreen(novelId: novelId)));
              },
              textColor: textColor,
              cardColor: cardColor,
              subtleTextColor: subtleTextColor,
            );
          },
        );
      },
    );
  }

  Widget _buildGenreCategories(Color? textColor, Color cardColor, Color subtleTextColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').orderBy('categories').snapshots(), // Urutkan berdasarkan nama kategori
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No categories found.', style: TextStyle(color: textColor?.withOpacity(0.6))));
        }

        // --- Responsiveness untuk Grid ---
        final screenWidth = MediaQuery.of(context).size.width;
        // Tentukan jumlah kolom berdasarkan lebar layar
        final crossAxisCount = (screenWidth / 180).floor().clamp(2, 5); // Target lebar item ~180px, min 2 kolom, max 5

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount, // Jumlah kolom dinamis
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, // Sesuaikan rasio aspek kartu kategori
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final categoryId = snapshot.data!.docs[index].id;
            return CategoryCard(
              categoryId: categoryId,
              title: data['categories'] ?? 'Unnamed Category',
              // Deskripsi mungkin tidak ada, beri nilai default
              description: data['description'] ?? '',
              coverImageUrl: data['coverImageUrl'] ?? '',
              onTap: () {
                // Navigasi ke layar yang menampilkan novel berdasarkan kategori
                print('Navigate to category: ${data['categories']} (ID: $categoryId)');
                // Navigator.push(context, MaterialPageRoute(builder: (context) => NovelsByCategoryScreen(category: data['categories'])));
              },
               textColor: textColor,
              cardColor: cardColor,
              subtleTextColor: subtleTextColor,
            );
          },
        );
      },
    );
  }

  // Helper widget untuk menampilkan novel dari data suggestion/rating
  Widget _buildNovelFromReference(DocumentSnapshot refDoc, String collectionName, Color? textColor, Color cardColor, Color subtleTextColor) {
    final data = refDoc.data() as Map<String, dynamic>;
    final novelId = data['novelId'] as String?;
    final ratingValue = (collectionName == 'rating' ? data['rating'] : null) as num?; // Ambil rating jika dari collection 'rating'

    if (novelId == null) {
      // Jika tidak ada novelId, tampilkan pesan atau widget kosong
      return const SizedBox.shrink(); // Widget kosong
       // Atau: return ListTile(title: Text('Missing novel reference', style: TextStyle(color: Colors.orange)));
    }

    // Ambil detail novel berdasarkan novelId
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('novels').doc(novelId).get(),
      builder: (context, novelSnapshot) {
        if (novelSnapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan shimmer/placeholder card selagi loading
          return NovelCardPlaceholder(cardColor: cardColor);
        }
        if (novelSnapshot.hasError) {
          return ListTile(title: Text('Error loading novel: $novelId', style: TextStyle(color: Colors.red)));
        }
        if (!novelSnapshot.hasData || !novelSnapshot.data!.exists) {
          return ListTile(title: Text('Novel (ID: $novelId) not found.', style: TextStyle(color: Colors.orange)));
        }

        final novelData = novelSnapshot.data!.data() as Map<String, dynamic>;
        return NovelCard(
          novelId: novelId,
          title: novelData['title'] ?? 'No Title',
          author: novelData['author'] ?? 'No Author',
          coverImageUrl: novelData['coverImageUrl'] ?? '',
          description: novelData['description'] ?? 'No description available.',
          rating: ratingValue?.toDouble(), // Tampilkan rating jika ada
          onTap: () {
            print('Navigate to details for novel ID: $novelId');
            // Navigator.push(context, MaterialPageRoute(builder: (context) => NovelDetailScreen(novelId: novelId)));
          },
          textColor: textColor,
          cardColor: cardColor,
          subtleTextColor: subtleTextColor,
        );
      },
    );
  }


  Widget _buildSuggestedNovels(Color? textColor, Color cardColor, Color subtleTextColor) {
    return StreamBuilder<QuerySnapshot>(
      // Ambil data dari collection 'suggestion'
      // Mungkin perlu diurutkan berdasarkan kriteria tertentu, misal timestamp
      stream: FirebaseFirestore.instance.collection('suggestion').limit(10).snapshots(), // Batasi jumlah suggestion
      builder: (context, snapshot) {
         if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No suggestions available right now.', style: TextStyle(color: textColor?.withOpacity(0.6))));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
           separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final suggestionDoc = snapshot.data!.docs[index];
            // Gunakan helper untuk membangun kartu novel
            return _buildNovelFromReference(suggestionDoc, 'suggestion', textColor, cardColor, subtleTextColor);
          },
        );
      },
    );
  }

  Widget _buildTopRatedNovels(Color? textColor, Color cardColor, Color subtleTextColor) {
    return StreamBuilder<QuerySnapshot>(
      // Ambil data dari collection 'rating', urutkan berdasarkan rating descending
      stream: FirebaseFirestore.instance.collection('rating').orderBy('rating', descending: true).limit(20).snapshots(), // Batasi jumlah top rated
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No rated novels found yet.', style: TextStyle(color: textColor?.withOpacity(0.6))));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ratingDoc = snapshot.data!.docs[index];
            return _buildNovelFromReference(ratingDoc, 'rating', textColor, cardColor, subtleTextColor);
          },
        );
      },
    );
  }
}

// --- Custom Widgets (FilterButton, CategoryCard, NovelCard) ---

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
    // Gunakan Material (atau CupertinoButton jika ingin gaya iOS)
    // Di sini kita custom tampilan mirip chip
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer( // Animasi halus saat state berubah
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // Gunakan warna dari theme
          color: isSelected ? primaryColor.withOpacity(0.12) : cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? [
             BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              )
          ] : [], // Beri sedikit shadow jika terpilih
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 18, // Ukuran ikon sedikit lebih besar
                color: isSelected ? primaryColor : textColor?.withOpacity(0.8),
              ),
            if (icon != null) const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primaryColor : textColor,
                fontSize: 13, // Sedikit lebih kecil agar muat banyak
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Sedikit elevasi
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Radius lebih kecil
      ),
      clipBehavior: Clip.antiAlias, // Pastikan gambar ter-clip dengan benar
      child: InkWell( // Beri efek ripple saat di-tap
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3, // Beri porsi lebih banyak untuk gambar
              child: coverImageUrl.isNotEmpty
                  ? Image.network(
                      coverImageUrl,
                      fit: BoxFit.cover,
                       // Placeholder saat loading
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator.adaptive(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      // Tampilan jika error loading gambar
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                           color: Colors.grey[300],
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey[600], size: 40),
                        );
                      },
                    )
                  : Container( // Placeholder jika tidak ada URL gambar
                     color: Colors.grey[300],
                      child: Icon(Icons.category_outlined, color: Colors.grey[600], size: 40),
                    ),
            ),
            Expanded(
              flex: 2, // Porsi untuk teks
              child: Padding(
                padding: const EdgeInsets.all(10.0), // Padding lebih kecil
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, // Teks di tengah vertikal
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15, // Ukuran font title
                        fontWeight: FontWeight.w600, // Lebih tebal
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                     // Tampilkan deskripsi hanya jika tidak kosong
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 11, // Ukuran font deskripsi
                          color: subtleTextColor,
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
  final double? rating; // Rating bisa null
  final Color? textColor;
  final Color cardColor;
  final Color subtleTextColor;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Padding konsisten
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Radius gambar
                child: SizedBox(
                  width: 80, // Lebar gambar tetap
                  height: 120, // Tinggi gambar tetap
                  child: coverImageUrl.isNotEmpty
                      ? Image.network(
                          coverImageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                                color: Colors.grey[isDarkMode(context) ? 700 : 300],
                                child: Center(child: CupertinoActivityIndicator()) // Gunakan Cupertino indicator kecil
                                );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[isDarkMode(context) ? 700 : 300],
                              child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[isDarkMode(context) ? 500: 500]),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[isDarkMode(context) ? 700 : 300],
                          child: Icon(Icons.book_outlined, color: Colors.grey[isDarkMode(context) ? 500: 500]),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Informasi Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 17, // Ukuran judul
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by $author', // Tambahkan 'by'
                      style: GoogleFonts.poppins(
                        fontSize: 13, // Ukuran author
                        color: subtleTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12, // Ukuran deskripsi
                        color: textColor?.withOpacity(0.85),
                        height: 1.4, // Jarak antar baris
                      ),
                      maxLines: 3, // Batasi deskripsi
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Tampilkan Rating jika ada (lebih besar dari 0)
                    if (rating != null && rating! > 0)
                      Row(
                        children: [
                          Icon(Platform.isIOS ? CupertinoIcons.star_fill : Icons.star, color: Colors.amber, size: 18), // Icon adaptif
                          const SizedBox(width: 4),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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

// Helper untuk cek dark mode (opsional, bisa langsung pakai Theme.of(context).brightness)
bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

// Widget Placeholder untuk Novel Card (saat loading FutureBuilder)
class NovelCardPlaceholder extends StatelessWidget {
  final Color cardColor;
  const NovelCardPlaceholder({Key? key, required this.cardColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     final bool dark = isDarkMode(context);
     final Color shimmerBase = dark ? Colors.grey[800]! : Colors.grey[300]!;

    return _buildPlaceholderContent(cardColor, shimmerBase);
  }

    Widget _buildPlaceholderContent(Color cardColor, Color placeholderColor) {
    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder Gambar
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                 color: placeholderColor,
                 borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            const SizedBox(width: 16),
            // Placeholder Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(width: double.infinity, height: 20, color: placeholderColor),
                   const SizedBox(height: 8),
                   Container(width: double.infinity * 0.6, height: 16, color: placeholderColor),
                   const SizedBox(height: 12),
                   Container(width: double.infinity, height: 14, color: placeholderColor),
                   const SizedBox(height: 6),
                   Container(width: double.infinity, height: 14, color: placeholderColor),
                    const SizedBox(height: 6),
                   Container(width: double.infinity * 0.8, height: 14, color: placeholderColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}