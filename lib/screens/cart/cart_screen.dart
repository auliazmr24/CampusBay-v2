import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // 1. STATE BARU: Menyimpan ID barang yang dipilih (checklist)
  final Set<int> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    // Simulasi ambil data cart (karena endpoint cart belum ada di server.js yang kamu upload,
    // saya asumsikan ini memanggil endpoint yang valid atau list lokal).
    // Jika belum ada endpoint cart, kode ini akan error.
    // Pastikan ApiService.getCart() sudah kamu buat.

    // Untuk saat ini, kita gunakan logika getCart dari ApiService kamu
    final items = await ApiService.getCart();

    if (mounted) {
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int id) async {
    await ApiService.removeFromCart(id);
    setState(() {
      _selectedItems.remove(id); // Hapus dari seleksi jika barang dihapus
    });
    _loadCart();
  }

  // FUNGSI BARU: Toggle Checkbox
  void _toggleSelection(int id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }
    });
  }

  // FUNGSI BARU: Pilih Semua
  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        // Masukkan semua ID ke set
        _selectedItems.addAll(_cartItems.map((e) => e['id'] as int));
      } else {
        // Kosongkan set
        _selectedItems.clear();
      }
    });
  }

  // Fitur Checkout: Redirect ke WA hanya barang yang dipilih
  void _checkout() async {
    // Filter barang: Hanya ambil yang ID-nya ada di _selectedItems
    final selectedProducts = _cartItems
        .where((item) => _selectedItems.contains(item['id']))
        .toList();

    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih minimal satu barang untuk checkout!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 1. Hitung Total yang dipilih
    int total = selectedProducts.fold(
      0,
      (sum, item) => sum + (item['price'] as int),
    );

    // 2. Buat Format Pesan WA
    String message = "Halo Seller CampusBay! Saya mau beli barang ini:\n";
    for (var item in selectedProducts) {
      message += "- ${item['title']} (Rp ${item['price']})\n";
    }
    message +=
        "\nTotal: Rp $total\nBisa COD di ${selectedProducts[0]['campus']}?";

    // 3. Buka WA
    final url = Uri.parse(
      "https://wa.me/6281234567890?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal membuka WhatsApp")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hitung total harga HANYA barang yang dicentang
    int totalPrice = _cartItems
        .where((item) => _selectedItems.contains(item['id']))
        .fold(0, (sum, item) => sum + (item['price'] as int));

    bool isAllSelected =
        _cartItems.isNotEmpty && _selectedItems.length == _cartItems.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Keranjang Saya",
          style: TextStyle(
            color: AppColors.coffeeBean,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.coffeeBean),
        actions: [
          // Tombol Pilih Semua di AppBar (Opsional)
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: () => _toggleSelectAll(!isAllSelected),
              child: Text(isAllSelected ? "Batal Pilih" : "Pilih Semua"),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.honeyBronze),
            )
          : _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.shoppingCart,
                    size: 64,
                    color: AppColors.vanillaCustard,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Keranjang masih kosong nih!",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      final isSelected = _selectedItems.contains(item['id']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.honeyBronze,
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            // 2. WIDGET CHECKBOX
                            Checkbox(
                              value: isSelected,
                              activeColor: AppColors.honeyBronze,
                              onChanged: (val) => _toggleSelection(item['id']),
                            ),

                            // Gambar Produk
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                                image:
                                    item['image_url'] != null &&
                                        item['image_url'] != ''
                                    ? DecorationImage(
                                        // Pastikan pakai helper agar gambar muncul
                                        image: NetworkImage(
                                          ApiService.getImageUrl(
                                            item['image_url'],
                                          ),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  item['image_url'] == null ||
                                      item['image_url'] == ''
                                  ? Icon(
                                      LucideIcons.image,
                                      color: Colors.grey[400],
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Info Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rp ${item['price']}",
                                    style: const TextStyle(
                                      color: AppColors.oxidizedIron,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item['campus'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Hapus
                            IconButton(
                              icon: const Icon(
                                LucideIcons.trash2,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => _deleteItem(item['id']),
                            ),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total (${_selectedItems.length} barang):",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "Rp $totalPrice",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.coffeeBean,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _checkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedItems.isEmpty
                                ? Colors.grey
                                : AppColors.honeyBronze,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            LucideIcons.messageCircle,
                            color: AppColors.coffeeBean,
                          ),
                          label: Text(
                            "CHECKOUT (COD VIA WA) (${_selectedItems.length})",
                            style: const TextStyle(
                              color: AppColors.coffeeBean,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
