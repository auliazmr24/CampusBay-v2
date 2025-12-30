import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../widgets/product_card.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      final products = await ApiService.getProducts(
        category: _selectedCategory == 'Semua' ? null : _selectedCategory,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

      // Debug: Print products dengan image URL
      for (var product in products) {
        print('📦 Product: ${product['title']}');
        print('🖼️  Image URL: ${product['image_url']}');
      }

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading products: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat produk: $e')));
      }
    }
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    _loadProducts();
  }

  void _onSearch() {
    _loadProducts();
  }

  // IMPORTANT: Fungsi untuk handle return dari add listing
  Future<void> _navigateToAddListing() async {
    final result = await Navigator.pushNamed(context, '/add-listing');

    // Jika berhasil menambah produk, refresh
    if (result == true) {
      print('🔄 Refreshing products after adding new item...');
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lokasi Kamu",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Row(
              children: [
                Text(
                  "Universitas Indonesia",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(width: 4),
                const Icon(
                  LucideIcons.chevronDown,
                  color: AppColors.coffeeBean,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.shoppingCart,
              color: AppColors.coffeeBean,
            ),
            onPressed: () {
              print("Keranjang diklik");
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coffeeBean.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: "Cari barang, buku, kos...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        LucideIcons.search,
                        color: AppColors.honeyBronze,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCategoryChip("Semua", _selectedCategory == "Semua"),
                    _buildCategoryChip("Buku", _selectedCategory == "Buku"),
                    _buildCategoryChip(
                      "Elektronik",
                      _selectedCategory == "Elektronik",
                    ),
                    _buildCategoryChip(
                      "Fashion",
                      _selectedCategory == "Fashion",
                    ),
                    _buildCategoryChip(
                      "Perabot",
                      _selectedCategory == "Perabot",
                    ),
                  ],
                ),
              ),
            ),

            // Loading indicator
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),

            // Empty state
            if (!_isLoading && _products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.packageOpen,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada produk",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Coba kategori atau pencarian lain",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

            // Grid Barang
            if (!_isLoading && _products.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = _products[index];
                    return ProductCard(
                      id: product['id'],
                      title: product['title'] ?? 'No title',
                      price: 'Rp ${_formatPrice(product['price'] ?? 0)}',
                      campus: product['campus'] ?? 'Unknown',
                      category: product['category'] ?? 'Lainnya',
                      imageUrl: product['image_url'] ?? '',
                    );
                  }, childCount: _products.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => _onCategoryChanged(label),
        child: Chip(
          label: Text(label),
          backgroundColor: isSelected ? AppColors.coffeeBean : AppColors.white,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.white : AppColors.coffeeBean,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
          side: isSelected
              ? BorderSide.none
              : const BorderSide(color: AppColors.vanillaCustard),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
