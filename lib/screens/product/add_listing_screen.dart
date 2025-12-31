import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pastikan package ini ada di pubspec.yaml
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';
import '../main/main_nav.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  // Controller untuk input text
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _campusController = TextEditingController();

  // Variabel State
  String _selectedCategory = 'Elektronik';
  String _selectedCondition = 'Bekas - Mulus';
  File? _selectedImage;
  bool _isLoading = false;

  // Data Pilihan Dropdown
  final List<String> _categories = [
    'Buku',
    'Elektronik',
    'Fashion',
    'Perabot',
    'Lainnya'
  ];
  final List<String> _conditions = ['Baru', 'Bekas - Mulus', 'Bekas'];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _campusController.dispose();
    super.dispose();
  }

  // Fungsi: Ambil Gambar dari Galeri
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi: Upload Data ke Server
// Fungsi: Upload Data ke Server
Future<void> _submitProduct() async {
  // 1. Validasi Input
  if (_titleController.text.isEmpty ||
      _priceController.text.isEmpty ||
      _selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ Mohon lengkapi judul, harga, dan foto barang!'),
        backgroundColor: AppColors.oxidizedIron,
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // 2. Panggil API Service dengan method YANG BENAR: addProduct
    final response = await ApiService.addProduct(
      title: _titleController.text,
      price: int.parse(_priceController.text),
      category: _selectedCategory,
      description: _descriptionController.text,
      condition: _selectedCondition,
      campus: _campusController.text.isEmpty
          ? 'Universitas Indonesia' // Default jika kosong
          : _campusController.text,
      imageFile: _selectedImage!,
    );

    setState(() => _isLoading = false);

    // 3. Cek Hasil (response sekarang adalah Map<String, dynamic>)
    if (response['success'] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Barang berhasil diposting!'),
          backgroundColor: AppColors.tropicalTeal,
        ),
      );
      // Kembali ke Home / MainNav
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainNav()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${response['message'] ?? 'Gagal upload barang, coba lagi.'}'),
          backgroundColor: AppColors.oxidizedIron,
        ),
      );
    }
  } catch (e) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Jual Barang", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. AREA UPLOAD FOTO (UI BARU) ---
            GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedImage == null
                        ? AppColors.vanillaCustard
                        : AppColors.coffeeBean,
                    width: 2,
                    style: _selectedImage == null
                        ? BorderStyle.none
                        : BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coffeeBean.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.camera,
                                size: 32, color: AppColors.honeyBronze),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Upload Foto Utama",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text("Ketuk untuk memilih foto",
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.edit2, size: 20),
                            ),
                          )
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),
            Text("Detail Produk",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),

            // --- 2. FORM INPUT (MODERN LOOK) ---
            
            _buildLabel("Nama Barang"),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Contoh: Macbook Air M1",
                prefixIcon: Icon(LucideIcons.tag),
              ),
            ),

            const SizedBox(height: 16),
            _buildLabel("Harga"),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "0",
                prefixText: "Rp ",
                prefixStyle: TextStyle(
                    color: AppColors.coffeeBean, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Kategori"),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        items: _categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Kondisi"),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCondition,
                        items: _conditions
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCondition = val!),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildLabel("Lokasi Kampus"),
            TextField(
              controller: _campusController,
              decoration: const InputDecoration(
                hintText: "Contoh: Universitas Indonesia",
                prefixIcon: Icon(LucideIcons.mapPin),
              ),
            ),

            const SizedBox(height: 16),
            _buildLabel("Deskripsi"),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: "Jelaskan kondisi barang, minus, kelengkapan, dll...",
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 40),

            // --- 3. TOMBOL SUBMIT ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.honeyBronze,
                  foregroundColor: AppColors.coffeeBean,
                  elevation: 5,
                  shadowColor: AppColors.honeyBronze.withValues(alpha: 0.4),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.coffeeBean,
                          strokeWidth: 3,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.uploadCloud),
                          SizedBox(width: 8),
                          Text("TAYANGKAN SEKARANG"),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40), // Jarak bawah agar tidak mepet
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Label Form
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.coffeeBean,
        ),
      ),
    );
  }
}