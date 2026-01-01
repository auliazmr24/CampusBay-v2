import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _campusController;
  late TextEditingController _majorController;
  late TextEditingController _yearController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi form dengan data yang diterima dari halaman sebelumnya
    _nameController = TextEditingController(text: widget.userData['name']);
    _campusController = TextEditingController(text: widget.userData['campus']);
    _majorController = TextEditingController(
      text: widget.userData['major'] ?? '',
    );
    _yearController = TextEditingController(
      text: widget.userData['year'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _campusController.dispose();
    _majorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.updateProfile(
      name: _nameController.text.trim(),
      campus: _campusController.text.trim(),
      major: _majorController.text.trim(),
      year: _yearController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui!"),
            backgroundColor: AppColors.tropicalTeal,
          ),
        );
        // Kembali ke halaman profil dengan membawa sinyal 'true' (refresh)
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.oxidizedIron,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.coffeeBean),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email (Read Only)
              const Text("Email Kampus", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.userData['email'] ?? '-',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              _buildInput(
                "Nama Lengkap",
                _nameController,
                LucideIcons.user,
                true,
              ),
              const SizedBox(height: 16),
              _buildInput(
                "Kampus",
                _campusController,
                LucideIcons.graduationCap,
                true,
              ),
              const SizedBox(height: 16),
              _buildInput(
                "Jurusan",
                _majorController,
                LucideIcons.bookOpen,
                false,
              ),
              const SizedBox(height: 16),
              _buildInput(
                "Angkatan",
                _yearController,
                LucideIcons.calendar,
                false,
                isNumber: true,
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.honeyBronze,
                    foregroundColor: AppColors.coffeeBean,
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
                      : const Text("SIMPAN PERUBAHAN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isRequired, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.coffeeBean,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: isRequired
              ? (value) => value == null || value.isEmpty
                    ? "$label tidak boleh kosong"
                    : null
              : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: Colors.grey),
            hintText: "Masukkan $label",
          ),
        ),
      ],
    );
  }
}
