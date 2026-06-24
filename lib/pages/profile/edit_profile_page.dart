import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../../widgets/shared/custom_app_bar.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers (Hanya Username)
  late TextEditingController _usernameController;

  File? _avatarFile;
  Uint8List? _avatarBytes; // Untuk web compatibility
  String? _initialAvatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Ambil data user yang sedang login untuk nilai awal form
    final customer = ref.read(authCustomerProvider);
    _initialAvatarUrl = customer?.avatarUrl;

    _usernameController = TextEditingController(text: customer?.username ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kompres lebih kecil untuk foto profil
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // Untuk web: simpan sebagai bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
        });
      } else {
        // Untuk mobile: simpan sebagai File
        setState(() {
          _avatarFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profileService = ProfileService();
      String? newAvatarUrl;

      // 1. Jika user pilih foto baru, upload dulu
      if (_avatarFile != null || _avatarBytes != null) {
        if (kIsWeb && _avatarBytes != null) {
          // Web: upload dari bytes
          newAvatarUrl = await profileService.uploadAvatarBytes(_avatarBytes!);
        } else if (!kIsWeb && _avatarFile != null) {
          // Mobile: upload dari file
          newAvatarUrl = await profileService.uploadAvatar(_avatarFile!);
        }
      }

      // 2. Update Username (dan Foto) ke tabel users & customers
      await profileService.updateCustomerProfile(
        username: _usernameController.text,
        avatarUrl: newAvatarUrl,
      );

      // 3. Refresh provider dengan data terbaru
      ref.read(authCustomerProvider.notifier).updateProfile(
        username: _usernameController.text,
        avatarUrl: newAvatarUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
      Navigator.pop(context); // Kembali ke halaman profil
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Edit Profil',
        showBackButton: true,
        showNotifications: false,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- Avatar Picker ---
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _avatarBytes != null
                                ? MemoryImage(_avatarBytes!)
                                : _avatarFile != null
                                ? FileImage(_avatarFile!) as ImageProvider
                                : (_initialAvatarUrl != null &&
                                      _initialAvatarUrl!.isNotEmpty)
                                ? NetworkImage(_initialAvatarUrl!)
                                : null,
                            child:
                                (_avatarFile == null &&
                                    _avatarBytes == null &&
                                    (_initialAvatarUrl == null ||
                                        _initialAvatarUrl!.isEmpty))
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A56DB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Input Username ---
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Username tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(
                    height: 40,
                  ), // Jarak disesuaikan karena email/password dihapus
                  // --- Tombol Simpan ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A56DB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
