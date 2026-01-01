import 'package:campusbay/screens/profile/edit_profile_screen.dart';
import 'package:campusbay/screens/profile/my_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Pastikan import ini ada jika pakai Lucide, atau ganti ke Icons biasa
import '../../core/theme.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 1. Fungsi Mengambil Data User dari Server
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    // Memanggil API /auth/me via ApiService
    final result = await ApiService.getCurrentUser();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _userData = result['data'];
        } else {
          // Jika sesi habis atau gagal, bisa arahkan ke login atau biarkan kosong
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? "Gagal memuat profil")),
          );
        }
      });
    }
  }

  // 2. Fungsi Logout
  Future<void> _handleLogout() async {
    // Tampilkan konfirmasi dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin keluar dari akun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Proses Logout ke API
    await ApiService.logout();

    if (mounted) {
      // Navigasi ke Login Screen dan hapus semua rute sebelumnya
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan Loading
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.honeyBronze),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: AppColors.coffeeBean,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile, // Fitur tarik ke bawah untuk refresh data
        color: AppColors.honeyBronze,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // --- HEADER PROFIL ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        // Avatar (Placeholder Inisial Nama)
                        Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.vanillaCustard,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            _getInitials(_userData?['name']),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.coffeeBean,
                            ),
                          ),
                        ),
                        // Ikon Edit Kecil
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[200]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.edit2,
                              size: 16,
                              color: AppColors.coffeeBean,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // NAMA USER DARI SERVER
                    Text(
                      _userData?['name'] ?? 'Pengguna',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.coffeeBean,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // EMAIL DARI SERVER
                    Text(
                      _userData?['email'] ?? '-',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 8),
                    // KAMPUS & JURUSAN (Badge)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.vanillaCustard),
                      ),
                      child: Text(
                        "${_userData?['campus'] ?? 'Kampus tidak diketahui'}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- MENU OPTIONS ---
              _buildMenuItem(
                icon: LucideIcons.user,
                title: 'Edit Profil',
                onTap: () async {
                  if (_userData == null) return;

                  final bool? shouldRefresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfileScreen(userData: _userData!),
                    ),
                  );

                  if (shouldRefresh == true) {
                    _loadProfile();
                  }
                },
              ),
              const SizedBox(height: 16),

              _buildMenuItem(
                icon: LucideIcons.shoppingBag,
                title: 'Barang Saya',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyProductsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: LucideIcons.settings,
                title: 'Pengaturan',
                onTap: () {},
              ),

              const SizedBox(height: 40),

              // --- TOMBOL KELUAR ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.oxidizedIron, // Warna merah
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(LucideIcons.logOut),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper Menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.honeyBronze.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.honeyBronze, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.coffeeBean,
                ),
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // Helper untuk mengambil inisial nama (Misal: "Budi Santoso" -> "BS")
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "U";
    List<String> nameParts = name.trim().split(" ");
    if (nameParts.length > 1) {
      return "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
    } else {
      return nameParts[0][0].toUpperCase();
    }
  }
}
