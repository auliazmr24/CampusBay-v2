import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import '../screens/product/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String campus;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.campus,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200), // Border lebih halus
          boxShadow: [
            BoxShadow(
              color: AppColors.coffeeBean.withValues(alpha: 0.04), // Shadow sangat halus
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder Lebih Bagus
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0), // Abu-abu sangat muda
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  // Ikon Lucide lebih clean daripada Icons.image
                  child: Icon(LucideIcons.image, color: Colors.grey.shade300, size: 32)
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.vanillaCustard.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: const Text("Elektronik", style: TextStyle(fontSize: 10, color: AppColors.coffeeBean, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Text(title, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 4),
                  Text(price, 
                    style: const TextStyle(
                      color: AppColors.oxidizedIron, 
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14
                    )
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(campus, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11), maxLines: 1)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}