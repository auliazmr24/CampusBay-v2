import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product; // Data barang yang mau diedit

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  String _selectedCategory = 'Elektronik';
  String _selectedCondition = 'Bekas';
  File? _newImage; // Untuk menyimpan gambar baru jika user ganti foto
  bool _isLoading = false;

  final List<String> _categories = [
    'Buku',
    'Elektronik',
    'Fashion',
    'Perabot',
    'Lainnya',
  ];
  final List<String> _conditions = ['Baru', 'Bekas - Mulus', 'Bekas'];

  @override
  void initState() {
    super.initState();
    // Isi data awal form
    _titleController = TextEditingController(text: widget.product['title']);
    _priceController = TextEditingController(
      text: widget.product['price'].toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product['description'],
    );

    // Validasi Dropdown (Jaga-jaga kalau data server beda tulisannya)
    if (_categories.contains(widget.product['category'])) {
      _selectedCategory = widget.product['category'];
    }
    if (_conditions.contains(widget.product['condition'])) {
      _selectedCondition = widget.product['condition'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProduct() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.updateProduct(
        id: widget.product['id'],
        title: _titleController.text,
        price: int.parse(_priceController.text),
        category: _selectedCategory,
        condition: _selectedCondition,
        description: _descriptionController.text,
        imageFile: _newImage, // Bisa null jika tidak ganti foto
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Barang berhasil diupdate!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Kembali dengan sinyal refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Edit Barang"),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- AREA FOTO ---
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  image: _newImage != null
                      ? DecorationImage(
                          image: FileImage(_newImage!),
                          fit: BoxFit.cover,
                        )
                      : (widget.product['image_url'] != null)
                      ? DecorationImage(
                          image: NetworkImage(
                            ApiService.getImageUrl(widget.product['image_url']),
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    // ignore: deprecated_member_use
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.camera,
                      color: AppColors.coffeeBean,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- FORM FIELDS ---
            _buildTextField("Judul Barang", _titleController),
            const SizedBox(height: 16),
            _buildTextField("Harga", _priceController, isNumber: true),
            const SizedBox(height: 16),

            // Dropdowns
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCondition,
              decoration: const InputDecoration(
                labelText: "Kondisi",
                border: OutlineInputBorder(),
              ),
              items: _conditions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCondition = val!),
            ),
            const SizedBox(height: 16),

            _buildTextField("Deskripsi", _descriptionController, maxLines: 4),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.honeyBronze,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SIMPAN PERUBAHAN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
