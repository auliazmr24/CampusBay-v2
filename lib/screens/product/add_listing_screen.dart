import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class AddListingScreen extends StatelessWidget {
  const AddListingScreen({super.key});

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
            // Upload Foto
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
                  Text("Tambah Foto (Max 5)", style: TextStyle(color: AppColors.coffeeBean.withValues(alpha: 0.5))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Text("Detail Barang", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            const TextField(
              decoration: InputDecoration(labelText: "Judul Barang"),
            ),
            const SizedBox(height: 16),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Harga",
                prefixText: "Rp ",
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: "Kategori"),
              items: ["Buku", "Elektronik", "Fashion"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {},
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Deskripsi",
                alignLabelWithHint: true,
              ),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("POSTING BARANG"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}