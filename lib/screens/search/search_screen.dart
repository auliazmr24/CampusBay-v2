import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart'; // Gunakan API Service
import '../../widgets/product_card.dart'; // Gunakan Widget ProductCard yang sudah jadi

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _foundProducts = [];

  // Riwayat pencarian (disimpan lokal di memori sementara)
  final List<String> _searchHistory = ["Macbook", "Kalkulus", "Meja Lipat"];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi Mencari ke Server
  Future<void> _runSearch(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _foundProducts = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil API dengan parameter search
      final products = await ApiService.getProducts(search: keyword);

      setState(() {
        _foundProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      print("Error searching: $e");
      setState(() {
        _foundProducts = [];
        _isLoading = false;
      });
    }
  }

  void _addToHistory(String value) {
    if (value.isNotEmpty && !_searchHistory.contains(value)) {
      setState(() {
        _searchHistory.insert(0, value);
        if (_searchHistory.length > 5) {
          _searchHistory.removeLast();
        }
      });
    }
  }

  void _deleteHistoryItem(String item) {
    setState(() {
      _searchHistory.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cari Barang",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.coffeeBean,
                ),
              ),
              const SizedBox(height: 16),

              // SEARCH BAR
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _addToHistory(value);
                  _runSearch(value);
                },
                decoration: InputDecoration(
                  hintText: 'Cari barang, buku, kos...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: Colors.grey,
                  ),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _foundProducts = [];
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.honeyBronze),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // KONTEN UTAMA
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.honeyBronze,
                        ),
                      )
                    : isSearching
                    ? _buildSearchResults()
                    : _buildSearchHistory(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAMPILAN RIWAYAT PENCARIAN
  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Text(
          "Belum ada riwayat pencarian",
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Terakhir Dicari",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (_searchHistory.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _searchHistory.clear()),
                child: const Text(
                  "Hapus Semua",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              final keyword = _searchHistory[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(LucideIcons.history, color: Colors.grey),
                title: Text(keyword),
                trailing: IconButton(
                  icon: const Icon(LucideIcons.x, size: 16, color: Colors.grey),
                  onPressed: () => _deleteHistoryItem(keyword),
                ),
                onTap: () {
                  _searchController.text = keyword;
                  _runSearch(keyword);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // TAMPILAN HASIL PENCARIAN
  Widget _buildSearchResults() {
    if (_foundProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              "Barang tidak ditemukan",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7, // Disesuaikan agar ProductCard pas
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _foundProducts.length,
      itemBuilder: (context, index) {
        final product = _foundProducts[index];

        // PENTING: Gunakan Widget ProductCard yang sama dengan Home
        return ProductCard(
          id: product['id'],
          title: product['title'] ?? 'Tanpa Nama',
          price: "Rp ${_formatPrice(product['price'] ?? 0)}",
          campus: product['campus'] ?? 'Unknown',
          category: product['category'] ?? 'Lainnya',
          imageUrl: product['image_url'] ?? '',
        );
      },
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
