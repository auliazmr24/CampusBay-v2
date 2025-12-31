import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getProductById(widget.productId);

    if (result['success'] == true) {
      if (mounted) {
        setState(() {
          _product = result['data'];
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal memuat produk')),
        );
        Navigator.pop(context);
      }
    }
  }

  // =========================
  // 🔹 ADD TO CART
  // =========================
  Future<void> _addToCart() async {
    setState(() => _isLoading = true);

    bool success = await ApiService.addToCart(widget.productId);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil masuk keranjang!"),
          backgroundColor: AppColors.tropicalTeal,
        ),
      );
    }
  }

  // =========================
  // 🔹 CONTACT SELLER
  // =========================
  Future<void> _contactSeller() async {
    if (_product == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hubungi Penjual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Penjual: ${_product!['seller_name']}'),
            const SizedBox(height: 8),
            Text('Kampus: ${_product!['seller_campus']}'),
            const SizedBox(height: 8),
            Text('Jurusan: ${_product!['seller_major'] ?? '-'}'),
            const SizedBox(height: 8),
            Text('Email: ${_product!['seller_email'] ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.coffeeBean),
        ),
      );
    }

    if (_product == null) {
      return const Scaffold(
        body: Center(child: Text('Produk tidak ditemukan')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // =========================
              // APP BAR IMAGE
              // =========================
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: _circleButton(
                  icon: LucideIcons.arrowLeft,
                  onTap: () => Navigator.pop(context),
                ),
                actions: [
                  _circleButton(
                    icon: LucideIcons.heart,
                    onTap: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background:
                      _product!['image_url'] != null &&
                              _product!['image_url'].isNotEmpty
                          ? Image.network(
                              ApiService.getImageUrl(
                                _product!['image_url'],
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                ),
              ),

              // =========================
              // CONTENT
              // =========================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildBadge(_product!['category'] ?? 'Lainnya'),
                          if (_product!['condition'] != null) ...[
                            const SizedBox(width: 8),
                            _buildBadge(_product!['condition']),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        _product!['title'],
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(height: 1.3),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Rp ${_formatPrice(_product!['price'])}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.oxidizedIron,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Seller Card
                      _sellerCard(),

                      const SizedBox(height: 24),

                      Text(
                        "Deskripsi Barang",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _product!['description'] ?? 'Tidak ada deskripsi',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // =========================
          // 🔹 BOTTOM ACTION BAR (MERGED)
          // =========================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: AppColors.vanillaCustard, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.honeyBronze,
                        foregroundColor: AppColors.coffeeBean,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(LucideIcons.shoppingBag),
                      label: const Text(
                        "+ KERANJANG",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _contactSeller,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coffeeBean,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(LucideIcons.messageCircle),
                      label: const Text(
                        "HUBUNGI PENJUAL",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.coffeeBean, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          LucideIcons.image,
          size: 60,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _sellerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.vanillaCustard.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.vanillaCustard,
            radius: 24,
            child: Icon(LucideIcons.user, color: AppColors.coffeeBean),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product!['seller_name'],
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${_product!['seller_major'] ?? 'Mahasiswa'} ${_product!['seller_year'] != null ? "'${_product!['seller_year']}" : ''}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.badgeCheck,
                      size: 14,
                      color: AppColors.tropicalTeal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.vanillaCustard),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: AppColors.coffeeBean,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
