import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Pasar Mahasiswa\nTerpercaya",
      "desc": "Jual beli aman khusus mahasiswa verified. Gak perlu takut tipu-tipu lagi.",
      "icon": LucideIcons.shieldCheck, // Ikon keamanan
      "iconColor": Colors.green,
    },
    {
      "title": "Cari Barang\nDekat Kampus",
      "desc": "Filter barang berdasarkan kampusmu. COD jadi lebih gampang dan hemat ongkir.",
      "icon": LucideIcons.mapPin, // Ikon lokasi
      "iconColor": Colors.blue,
    },
    {
      "title": "Ubah Barang Bekas\nJadi Cuan",
      "desc": "Punya buku atau perabot tak terpakai? Jual aja ke adik tingkat!",
      "icon": LucideIcons.coins, // Ikon uang
      "iconColor": Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  title: _onboardingData[index]["title"]!,
                  desc: _onboardingData[index]["desc"]!,
                  icon: _onboardingData[index]["icon"]!,
                  iconColor: _onboardingData[index]["iconColor"]!,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Indikator Titik-titik
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => buildDot(index),
                      ),
                    ),
                    const Spacer(),
                    // Tombol Next / Get Started
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == _onboardingData.length - 1 ? "MULAI SEKARANG" : "LANJUT",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Indikator (Titik)
  Container buildDot(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.honeyBronze : AppColors.vanillaCustard,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// Widget Isi Konten Slide
class OnboardingContent extends StatelessWidget {
  final String title, desc;
  final IconData icon;
  final Color iconColor;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.desc,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ikon Lucide dengan ukuran dan warna yang menarik
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}