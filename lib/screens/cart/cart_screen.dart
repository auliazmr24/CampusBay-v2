import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart'; // Jangan lupa: flutter pub add url_launcher
import '../../core/theme.dart';
import '../../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await ApiService.getCart();
    if (mounted) setState(() { _cartItems = items; _isLoading = false; });
  }

  Future<void> _deleteItem(int id) async {
    await ApiService.removeFromCart(id);
    _loadCart();
  }

  // Fitur Checkout Sederhana: Redirect ke WA
  void _checkout() async {
    if (_cartItems.isEmpty) return;

    // 1. Hitung Total
    int total = _cartItems.fold(0, (sum, item) => sum + (item['price'] as int));
    
    // 2. Buat Format Pesan WA
    String message = "Halo Seller CampusBay! Saya mau beli:\n";
    for (var item in _cartItems) {
      message += "- ${item['title']} (Rp ${item['price']})\n";
    }
    message += "\nTotal: Rp $total\nBisa COD di ${_cartItems[0]['campus']}?";

    // 3. Buka WA (Nomor Dummy)
    final url = Uri.parse("https://wa.me/6281234567890?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka WhatsApp")));
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = _cartItems.fold(0, (sum, item) => sum + (item['price'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Saya", style: TextStyle(color: AppColors.coffeeBean, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.coffeeBean),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.honeyBronze))
        : _cartItems.isEmpty 
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.shoppingCart, size: 64, color: AppColors.vanillaCustard),
                const SizedBox(height: 16),
                const Text("Keranjang masih kosong nih!", style: TextStyle(color: Colors.grey)),
              ],
            ))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            // Gambar Produk
                            Container(
                              width: 70, height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                                image: item['image_url'] != null && item['image_url'] != ''
                                    ? DecorationImage(
                                        image: NetworkImage("http://localhost:3000${item['image_url']}"),
                                        fit: BoxFit.cover)
                                    : null,
                              ),
                              child: item['image_url'] == null || item['image_url'] == '' 
                                ? Icon(LucideIcons.image, color: Colors.grey[400]) : null,
                            ),
                            const SizedBox(width: 12),
                            // Info Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("Rp ${item['price']}", style: const TextStyle(color: AppColors.oxidizedIron, fontWeight: FontWeight.bold)),
                                  Text(item['campus'], style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            // Tombol Hapus
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, color: Colors.red),
                              onPressed: () => _deleteItem(item['id']),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // CHECKOUT SECTION
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Harga:", style: TextStyle(fontSize: 16)),
                          Text("Rp $totalPrice", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.coffeeBean)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _checkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.honeyBronze,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(LucideIcons.messageCircle, color: AppColors.coffeeBean),
                          label: const Text("CHECKOUT (COD VIA WA)", style: TextStyle(color: AppColors.coffeeBean, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}