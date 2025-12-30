import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _campusController = TextEditingController();

  String _selectedCategory = 'Elektronik';
  String _selectedCondition = 'Bekas - Mulus';
  bool _isLoading = false;

  final List<String> _categories = ['Buku', 'Elektronik', 'Fashion', 'Perabot', 'Lainnya'];
  final List<String> _conditions = ['Baru', 'Bekas - Mulus', 'Bekas'];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _campusController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validasi
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _campusController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul, harga, dan kampus wajib diisi')),
      );
      return;
    }

    // Parse harga
    final price = int.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga tidak valid')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.addProduct(
      title: _titleController.text.trim(),
      price: price,
      category: _selectedCategory,
      campus: _campusController.text.trim(),
      description: _descriptionController.text.trim(),
      condition: _selectedCondition,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Produk berhasil ditambahkan!')),
      );

      // Clear form
      _titleController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _campusController.clear();

      // Kembali ke home (refresh)
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal menambahkan produk')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jual Barang"),
        backgroundColor: AppColors.background,
        leading: const SizedBox(), // Hilangkan back button karena di tab
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Foto (Placeholder - bisa dikembangkan pakai image_picker)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.vanillaCustard, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.camera, size: 40, color: AppColors.honeyBronze),
                  const SizedBox(height: 8),
                  Text(
                    "Tambah Foto (Segera Hadir)",
                    style: TextStyle(color: AppColors.coffeeBean.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text("Detail Barang", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Judul Barang
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Judul Barang *"),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Harga
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Harga *",
                prefixText: "Rp ",
                hintText: "10000000",
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Kategori
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: "Kategori"),
              items: _categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (val) {
                      setState(() => _selectedCategory = val!);
                    },
            ),
            const SizedBox(height: 16),

            // Kondisi
            DropdownButtonFormField<String>(
              initialValue: _selectedCondition,
              decoration: const InputDecoration(labelText: "Kondisi"),
              items: _conditions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (val) {
                      setState(() => _selectedCondition = val!);
                    },
            ),
            const SizedBox(height: 16),

            // Kampus/Lokasi
            TextField(
              controller: _campusController,
              decoration: const InputDecoration(
                labelText: "Lokasi/Kampus *",
                hintText: "Universitas Indonesia",
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Deskripsi
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                alignLabelWithHint: true,
                hintText: "Ceritakan kondisi barang, alasan jual, dll.",
              ),
              enabled: !_isLoading,
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.coffeeBean),
                        ),
                      )
                    : const Text("POSTING BARANG"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}