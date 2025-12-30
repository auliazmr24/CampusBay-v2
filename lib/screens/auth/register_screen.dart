import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';
import '../main/main_nav.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _campusController = TextEditingController();
  final _majorController = TextEditingController();
  final _yearController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _campusController.dispose();
    _majorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Reset error
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validasi input
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _campusController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email, password, nama, dan kampus wajib diisi';
        _isLoading = false;
      });
      return;
    }

    // Validasi password match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Password tidak sama';
        _isLoading = false;
      });
      return;
    }

    // Validasi email kampus
    if (!_emailController.text.trim().endsWith('.ac.id')) {
      setState(() {
        _errorMessage = 'Harus menggunakan email kampus (.ac.id)';
        _isLoading = false;
      });
      return;
    }

    // Call API
    final result = await ApiService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      campus: _campusController.text.trim(),
      major: _majorController.text.trim().isEmpty ? null : _majorController.text.trim(),
      year: _yearController.text.trim().isEmpty ? null : _yearController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      // Register berhasil, auto login, navigasi ke main
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNav()),
      );
    } else {
      // Register gagal, tampilkan error
      setState(() {
        _errorMessage = result['message'] ?? 'Registrasi gagal';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.coffeeBean),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Daftar Akun\nBaru",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "Daftar pakai email kampus untuk verifikasi.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 32),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.oxidizedIron.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.oxidizedIron),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.oxidizedIron, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.oxidizedIron),
                        ),
                      ),
                    ],
                  ),
                ),

              // Nama lengkap
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap *",
                  prefixIcon: Icon(Icons.person_outline),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email Kampus (.ac.id) *",
                  prefixIcon: Icon(Icons.school_outlined),
                  hintText: "contoh@ui.ac.id",
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password *",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Konfirmasi Password *",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Kampus
              TextField(
                controller: _campusController,
                decoration: const InputDecoration(
                  labelText: "Nama Kampus *",
                  prefixIcon: Icon(Icons.location_city_outlined),
                  hintText: "Universitas Indonesia",
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Jurusan (optional)
              TextField(
                controller: _majorController,
                decoration: const InputDecoration(
                  labelText: "Jurusan (Opsional)",
                  prefixIcon: Icon(Icons.book_outlined),
                  hintText: "Teknik Informatika",
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Angkatan (optional)
              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Angkatan (Opsional)",
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  hintText: "2021",
                ),
                enabled: !_isLoading,
              ),

              const SizedBox(height: 32),

              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.coffeeBean),
                          ),
                        )
                      : const Text("DAFTAR"),
                ),
              ),

              const SizedBox(height: 20),

              // Link ke Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? "),
                  GestureDetector(
                    onTap: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: AppColors.oxidizedIron,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}