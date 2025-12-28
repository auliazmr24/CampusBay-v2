import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Pakai Lucide biar ikon bagus
import '../../core/theme.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Lokasi Kamu", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Row(
              children: [
                Text("Universitas Indonesia", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
                const SizedBox(width: 4),
                const Icon(LucideIcons.chevronDown, color: AppColors.coffeeBean, size: 18) // Ikon lebih rapi
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppColors.coffeeBean), // Ikon lonceng modern
            onPressed: () {},
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar yang Lebih Bagus
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coffeeBean.withValues(alpha: 0.08), // Shadow halus
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Cari barang, buku, kos...",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(LucideIcons.search, color: AppColors.honeyBronze), // Ikon warna tema
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
                  _buildCategoryChip("Semua", true),
                  _buildCategoryChip("📚 Buku", false),
                  _buildCategoryChip("💻 Elektronik", false),
                  _buildCategoryChip("👕 Fashion", false),
                  _buildCategoryChip("🪑 Perabot", false),
                ],
              ),
            ),
          ),

          // Grid Barang
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7, // Sedikit lebih tinggi biar muat info
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const ProductCard(
                    title: "Macbook Air M1 2020",
                    price: "Rp 10.500.000",
                    campus: "Fasilkom UI",
                    imageUrl: "", // Nanti diisi URL gambar
                  );
                },
                childCount: 6,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
    );
  }
}