import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Gunakan Lucide
import '../../core/theme.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350, // Gambar lebih tinggi biar estetik
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(LucideIcons.image, size: 60, color: Colors.grey[400])
                    ), 
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: AppColors.coffeeBean, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.heart, color: AppColors.oxidizedIron, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Kategori & Kondisi
                      Row(
                        children: [
                          _buildBadge("Elektronik"),
                          const SizedBox(width: 8),
                          _buildBadge("Bekas - Mulus"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Text("Macbook Air M1 2020 Fullset Mulus", 
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1.3)
                      ),
                      const SizedBox(height: 8),
                      Text("Rp 10.500.000", 
                        style: TextStyle(
                          fontSize: 26, 
                          color: AppColors.oxidizedIron, 
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Plus Jakarta Sans'
                        )
                      ),
                      const SizedBox(height: 24),
                      
                      // Seller Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.vanillaCustard.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(backgroundColor: AppColors.vanillaCustard, radius: 24, child: Icon(LucideIcons.user, color: AppColors.coffeeBean)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Budi Santoso", style: Theme.of(context).textTheme.labelLarge),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text("Teknik Informatika '21", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                                      const SizedBox(width: 4),
                                      const Icon(LucideIcons.badgeCheck, size: 14, color: AppColors.tropicalTeal)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Text("Deskripsi Barang", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(
                        "Dijual santai karena mau upgrade ke Pro. Pemakaian wajar mahasiswa untuk koding dan nugas. \n\n- Battery health 90%\n- Lengkap box dan charger ori\n- Tidak ada dent/penyok\n\nBisa COD di kantin teknik UI atau sekitaran Margonda.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: Colors.black87),
                      ),
                      const SizedBox(height: 120), // Space agar tidak tertutup tombol bawah
                    ],
                  ),
                ),
              )
            ],
          ),
          
          // Bottom Action Bar (CUMA 1 TOMBOL SEKARANG)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 34), // Padding bawah lebih besar untuk iPhone
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
                ],
                border: const Border(top: BorderSide(color: AppColors.vanillaCustard, width: 0.5)),
              ),
              child: ElevatedButton.icon(
                onPressed: (){},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coffeeBean, // Tombol hitam biar bold
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(LucideIcons.messageCircle), // Ikon chat/wa
                label: const Text("HUBUNGI PENJUAL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          )
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
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.coffeeBean)),
    );
  }
}