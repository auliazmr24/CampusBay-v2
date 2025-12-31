import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../widgets/product_card.dart';
import '../../services/api_service.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  int _cartCount = 0; // Variabel untuk menghitung isi keranjang

  String _selectedCategory = 'Semua';
  
  // Variabel Lokasi
  String _selectedCampus = 'Semua Kampus'; // Defaultnya semua
  final List<String> _allCampuses = [
    'Semua Kampus', // Opsi untuk lihat semua
    'Universitas Indonesia',
    'Universitas Gadjah Mada',
    'ITB',
    'IPB University',
    'Binus University',
    'Universitas Brawijaya',
    'Universitas Padjadjaran',
    'ITS',
    'Universitas Airlangga',
    'Telkom University',
    // Tambahkan kampus lain di sini...
  ];

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCartCount(); // Cek keranjang saat buka
  }

  // Cek jumlah item di keranjang buat Badge
  Future<void> _loadCartCount() async {
    final cartItems = await ApiService.getCart();
    if (mounted) {
      setState(() {
        _cartCount = cartItems.length;
      });
    }
  }

  // Refresh saat kembali dari halaman Cart (siapa tau ada yg dihapus/checkout)
  void _onReturnFromCart() {
    _loadCartCount();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      var products = await ApiService.getProducts(
        category: _selectedCategory == 'Semua' ? null : _selectedCategory,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

      // Filter Lokasi di Client-Side
      if (_selectedCampus != 'Semua Kampus') {
        products = products.where((p) => p['campus'] == _selectedCampus).toList();
      }

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCategoryChanged(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
    });
    _loadProducts();
  }

  // --- LOGIKA PENCARIAN LOKASI (MODAL) ---
  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CampusSearchModal(
          allCampuses: _allCampuses,
          onSelected: (campus) {
            setState(() {
              _selectedCampus = campus;
            });
            _loadProducts(); // Reload produk sesuai kampus baru
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 70, // AppBar agak tinggi biar lega
        title: GestureDetector(
          onTap: _showLocationPicker, // Klik judul untuk ganti lokasi
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Lokasi Kamu", style: TextStyle(fontSize: 12, color: Colors.grey)),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _selectedCampus, 
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(LucideIcons.chevronDown, color: AppColors.honeyBronze, size: 18)
                ],
              ),
            ],
          ),
        ),
        actions: [
          // --- ICON CART DENGAN BADGE (ANGKA) ---
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.shoppingCart, color: AppColors.coffeeBean, size: 26),
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const CartScreen())
                    ).then((_) => _onReturnFromCart());
                  },
                ),
                // Badge Merah (Hanya muncul jika ada isi)
                if (_cartCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.oxidizedIron, // Merah
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
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
                      color: AppColors.coffeeBean.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _loadProducts(),
                  decoration: const InputDecoration(
                    hintText: "Cari laptop, buku, atau kos...",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(LucideIcons.search, color: AppColors.honeyBronze),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  _buildCategoryChip("Semua", _selectedCategory == 'Semua'),
                  _buildCategoryChip("Buku", _selectedCategory == 'Buku'),
                  _buildCategoryChip("Elektronik", _selectedCategory == 'Elektronik'),
                  _buildCategoryChip("Fashion", _selectedCategory == 'Fashion'),
                  _buildCategoryChip("Perabot", _selectedCategory == 'Perabot'),
                ],
              ),
            ),
          ),

          // Grid Barang
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.honeyBronze)),
            )
          else if (_products.isEmpty)
             const SliverFillRemaining(
              child: Center(child: Text("Tidak ada barang di kampus ini", style: TextStyle(color: Colors.grey))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _products[index];
                    return ProductCard(
                      id: product['id'],
                      title: product['title'] ?? 'Tanpa Nama',
                      price: 'Rp ${_formatPrice(product['price'] ?? 0)}',
                      campus: product['campus'] ?? 'Unknown',
                      category: product['category'] ?? 'Lainnya',
                      imageUrl: product['image_url'] ?? '',
                    );
                  },
                  childCount: _products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => _onCategoryChanged(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.coffeeBean : AppColors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? AppColors.coffeeBean : AppColors.vanillaCustard
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.coffeeBean,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

// --- WIDGET MODAL PENCARIAN KAMPUS ---
class CampusSearchModal extends StatefulWidget {
  final List<String> allCampuses;
  final Function(String) onSelected;

  const CampusSearchModal({
    super.key, 
    required this.allCampuses, 
    required this.onSelected
  });

  @override
  State<CampusSearchModal> createState() => _CampusSearchModalState();
}

class _CampusSearchModalState extends State<CampusSearchModal> {
  List<String> _filteredCampuses = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCampuses = widget.allCampuses;
  }

  void _filterCampuses(String query) {
    setState(() {
      _filteredCampuses = widget.allCampuses
          .where((campus) => campus.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8, // Tinggi modal 80% layar
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar (Garis kecil di atas)
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          
          Text("Pilih Lokasi Kampus", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          
          // Search Input Kampus
          TextField(
            controller: _searchController,
            onChanged: _filterCampuses,
            decoration: InputDecoration(
              hintText: "Cari nama kampus...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // List Hasil Pencarian
          Expanded(
            child: ListView.separated(
              itemCount: _filteredCampuses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final campus = _filteredCampuses[index];
                return ListTile(
                  title: Text(campus, style: const TextStyle(fontWeight: FontWeight.w500)),
                  leading: const Icon(LucideIcons.mapPin, color: AppColors.honeyBronze, size: 20),
                  onTap: () {
                    widget.onSelected(campus);
                    Navigator.pop(context); // Tutup modal
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}