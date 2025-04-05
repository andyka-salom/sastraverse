import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      id: doc.id, // Selalu ada ID
      title: data['title'] as String? ?? 'No Title', // Default value jika null
      author: data['author'] as String? ?? 'Unknown Author', // Default value
      categoryId: data['categoryId'] as String? ?? '', // Default value
      coverImageUrl: data['coverImageUrl'] as String? ?? '', // Default value (handle di UI jika kosong)
      description: data['description'] as String? ?? 'No description available.', // Default value
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  Stream<QuerySnapshot>? _searchStream;

  @override
  void initState() {
    super.initState();
    _searchStream = FirebaseFirestore.instance.collection('novels').orderBy('title').snapshots();
     _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
   if (_searchTerm != _searchController.text.trim()) {
      setState(() {
        _searchTerm = _searchController.text.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil warna tema
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final Color cardColor = Theme.of(context).cardColor;
    final Color subtleTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7);
    final Color hintColor = Theme.of(context).hintColor;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color searchFieldBgColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildSearchField(hintColor, textColor, searchFieldBgColor),
      ),
      body: SafeArea( 
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _searchStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: GoogleFonts.poppins(color: Colors.red)),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator.adaptive());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No novels available.',
                          style: GoogleFonts.poppins(color: subtleTextColor)),
                    );
                  }

                  // Parse data ke List<Novel>
                  List<Novel> allNovels = snapshot.data!.docs
                      .map((doc) => Novel.fromDocument(doc))
                      .toList();

                  // Lakukan filtering di client-side berdasarkan _searchTerm
                  List<Novel> filteredNovels = allNovels;
                  if (_searchTerm.isNotEmpty) {
                    filteredNovels = allNovels.where((novel) {
                      final searchTermLower = _searchTerm.toLowerCase();
                      return novel.title.toLowerCase().contains(searchTermLower) ||
                             novel.author.toLowerCase().contains(searchTermLower) ||
                             novel.description.toLowerCase().contains(searchTermLower);
                    }).toList();
                  }

                  // Tampilkan pesan jika hasil filter kosong
                  if (filteredNovels.isEmpty && _searchTerm.isNotEmpty) {
                    return Center(
                      child: Text('No results found for "$_searchTerm"',
                          style: GoogleFonts.poppins(color: subtleTextColor)),
                    );
                  }
                  // Tampilkan pesan jika stream awal kosong (sebelum search)
                  if (filteredNovels.isEmpty && _searchTerm.isEmpty) {
                    return Center(
                      child: Text('Start typing to search for novels.',
                          style: GoogleFonts.poppins(color: subtleTextColor)),
                    );
                  }


                  // Gunakan ListView.separated untuk jarak
                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0), // Padding untuk list
                    itemCount: filteredNovels.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      // Kirim data novel dan warna tema ke NovelSearchCard
                      return NovelSearchCard(
                        novel: filteredNovels[index],
                        textColor: textColor,
                        cardColor: cardColor,
                        subtleTextColor: subtleTextColor,
                        onTap: () {
                          // Aksi ketika card di-tap (misal, navigasi ke detail)
                          print('Tapped on: ${filteredNovels[index].title}');
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => NovelDetailScreen(novelId: filteredNovels[index].id)));
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

  // Widget untuk field pencarian (adaptif)
  Widget _buildSearchField(Color hintColor, Color? textColor, Color bgColor) {
    if (Platform.isIOS) {
      // Gunakan CupertinoSearchTextField untuk iOS
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Padding agar tidak terlalu mepet
        child: CupertinoSearchTextField(
          controller: _searchController,
          placeholder: 'Search Novels or Authors...',
          placeholderStyle: GoogleFonts.poppins(color: hintColor),
          style: GoogleFonts.poppins(color: textColor),
          backgroundColor: bgColor,
          // onChanged: (value) => _onSearchChanged(), // Dihandle oleh listener controller
        ),
      );
    } else {
      // Gunakan TextField dengan InputDecoration Material untuk Android/lainnya
      // Buat agar tingginya tidak terlalu besar di AppBar
      return SizedBox(
        height: 48, // Atur tinggi field
        child: TextField(
          controller: _searchController,
          // onChanged: (value) => _onSearchChanged(), // Dihandle oleh listener controller
          style: GoogleFonts.poppins(color: textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search Novels or Authors...',
            hintStyle: GoogleFonts.poppins(color: hintColor, fontSize: 15),
            prefixIcon: Icon(Icons.search, color: hintColor, size: 20),
            // Tambahkan tombol clear (X) jika ada teks
            suffixIcon: _searchTerm.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    color: hintColor,
                    onPressed: () {
                      _searchController.clear();
                       // _onSearchChanged(); // Dihandle oleh listener
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10), // Adjust padding
            filled: true,
            fillColor: bgColor, // Warna background field
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0), // Border radius
              borderSide: BorderSide.none, // Tanpa border luar
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none, // Atau beri border saat fokus jika diinginkan
            ),
          ),
        ),
      );
    }
  }
}

// Widget terpisah untuk menampilkan kartu hasil pencarian Novel
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

    return Card(
      elevation: 1.5, // Sedikit elevasi
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias, // Penting untuk clipping gambar
      child: InkWell( // Tambahkan InkWell untuk efek tap
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items ke atas
            children: [
              // Gambar Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: 70, // Lebar gambar sedikit lebih besar
                  height: 105, // Tinggi gambar proporsional
                  child: novel.coverImageUrl.isNotEmpty
                      ? Image.network(
                          novel.coverImageUrl,
                          fit: BoxFit.cover,
                          // Loading builder adaptif
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                              child: Center(
                                child: Platform.isIOS
                                    ? const CupertinoActivityIndicator(radius: 10)
                                    : SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                            );
                          },
                          // Error builder adaptif
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                              child: Icon(
                                Platform.isIOS ? CupertinoIcons.photo : Icons.broken_image_outlined,
                                color: subtleTextColor, size: 30,
                              ),
                            );
                          },
                        )
                      // Placeholder jika URL gambar kosong
                                            // Placeholder jika URL gambar kosong
                      : Container(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          child: Icon(
                            // GANTI MENJADI INI:
                            Platform.isIOS ? CupertinoIcons.book : Icons.book_outlined, 
                             color: subtleTextColor, size: 30,
                             ),
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
                      novel.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16, // Ukuran judul
                        fontWeight: FontWeight.w600, // Bold
                        color: textColor,
                      ),
                      maxLines: 2, // Maksimal 2 baris untuk judul
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
                    // Deskripsi ditampilkan di sini
                    Text(
                      novel.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textColor?.withOpacity(0.85), // Sedikit transparan
                        height: 1.4, // Jarak antar baris
                      ),
                      maxLines: 3, // Batasi deskripsi hingga 3 baris
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