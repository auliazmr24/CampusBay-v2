import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _foundProducts = [];
  bool _hasSearched = false; // Menandakan user sudah menekan enter/search

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk memanggil API Search
  Future<void> _runSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final products = await ApiService.getProducts(search: keyword);
      if (mounted) {
        setState(() {
          _foundProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencari: $e')),
        );
      }
    }
  }

  // Helper formatting harga
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Pencarian", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // --- 1. SEARCH BAR MODERN ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coffeeBean.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _runSearch,
                autofocus: false, // Set true jika ingin langsung keyboard muncul
                decoration: InputDecoration(
                  hintText: "Cari laptop, buku, kos...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(LucideIcons.search, color: AppColors.honeyBronze),
                  suffixIcon: _searchController.text.isNotEmpty || _hasSearched
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 18, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _hasSearched = false;
                              _foundProducts = [];
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) {
                  // Rebuild untuk memunculkan tombol X
                  setState(() {}); 
                },
              ),
            ),
          ),

          // --- 2. KONTEN UTAMA ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.honeyBronze))
                : _hasSearched
                    ? _buildSearchResults()
                    : _buildSuggestions(),
          ),
        ],
      ),
    );
  }

  // Tampilan Default: Saran Pencarian (Chips)
  Widget _buildSuggestions() {
    final List<String> popularTags = [
      "Macbook", "Kalkulus", "Meja Lipat", 
      "Kemeja Flanel", "Iphone 11", "Helm Bogo",
      "Kipas Angin", "Sepatu Vans"
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const Text(
          "Pencarian Populer", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.coffeeBean)
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: popularTags.map((tag) => ActionChip(
            label: Text(tag),
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            side: const BorderSide(color: AppColors.vanillaCustard),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            labelStyle: const TextStyle(color: AppColors.coffeeBean, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            onPressed: () {
              _searchController.text = tag;
              _runSearch(tag);
            },
          )).toList(),
        ),
      ],
    );
  }

  // Tampilan Hasil Pencarian (Grid atau Empty State)
  Widget _buildSearchResults() {
    if (_foundProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.vanillaCustard.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.searchX, size: 48, color: AppColors.coffeeBean),
            ),
            const SizedBox(height: 24),
            const Text(
              "Barang tidak ditemukan", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
            ),
            const SizedBox(height: 8),
            Text(
              "Coba gunakan kata kunci lain ya.", 
              style: TextStyle(color: Colors.grey[600])
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7, // Disesuaikan agar ProductCard pas
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _foundProducts.length,
      itemBuilder: (context, index) {
        final product = _foundProducts[index];
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
}