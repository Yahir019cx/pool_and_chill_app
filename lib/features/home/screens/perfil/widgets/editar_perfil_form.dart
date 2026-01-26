// perfil/widgets/editar_perfil_form.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/services/storage_service.dart';

import 'avatar_perfil.dart';

class EditarPerfilForm extends StatefulWidget {
  const EditarPerfilForm({super.key});

  @override
  State<EditarPerfilForm> createState() => _EditarPerfilFormState();
}

class _EditarPerfilFormState extends State<EditarPerfilForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  DateTime? _fechaNacimiento;

  // Para manejo de imagen
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;

  static const Color primary = Color(0xFF3CA2A2);
  static const Color inputBg = Color(0xFFF4F6F8);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profile = context.read<AuthProvider>().profile;
    if (profile != null) {
      _nombreCtrl.text = profile.firstName;
      _apellidoCtrl.text = profile.lastName;
      _emailCtrl.text = profile.email;
      _telefonoCtrl.text = profile.phoneNumber ?? '';
      _bioCtrl.text = profile.bio ?? '';
      _fechaNacimiento = profile.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _ubicacionCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          /// ---------- AVATAR ----------
          AvatarPerfil(
            imageUrl: profile?.profileImageUrl,
            initials: profile?.initials ?? '',
            isLoading: _isUploadingImage,
            onTap: _showImageOptions,
          ),

          const SizedBox(height: 32),

          /// ---------- INPUTS ----------
          _input('Nombre', _nombreCtrl),
          _input('Apellido', _apellidoCtrl),
          _input(
            'Correo electrónico',
            _emailCtrl,
            keyboard: TextInputType.emailAddress,
          ),
          _input(
            'Teléfono',
            _telefonoCtrl,
            keyboard: TextInputType.phone,
          ),

          _datePicker(),
          _input('Ubicación', _ubicacionCtrl),
          _input('Biografía', _bioCtrl, maxLines: 3),

          const SizedBox(height: 32),

          /// ---------- BOTÓN ----------
          ElevatedButton(
            onPressed: _guardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Guardar cambios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- IMAGE OPTIONS ----------

  void _showImageOptions() {
    final profile = context.read<AuthProvider>().profile;
    final hasImage = profile?.profileImageUrl != null &&
        profile!.profileImageUrl!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de arrastre
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Text(
                'Cambiar foto de perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // Tomar foto
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: primary,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),

              // Elegir de galería
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary.withValues(alpha: 0.8),
                  child: const Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Elegir de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),

              // Eliminar foto (solo si tiene foto)
              if (hasImage)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  title: const Text(
                    'Eliminar foto',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteImage();
                  },
                ),

              const SizedBox(height: 10),

              // Cancelar
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Verificar permisos
      final hasPermission = await _checkPermission(source);
      if (!hasPermission) return;

      // Seleccionar imagen
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Subir imagen
      await _uploadImage(File(pickedFile.path));
    } catch (e) {
      _showError('Error al seleccionar imagen: $e');
    }
  }

  Future<bool> _checkPermission(ImageSource source) async {
    Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      // Para galería en Android 13+
      if (Platform.isAndroid) {
        permission = Permission.photos;
      } else {
        permission = Permission.photos;
      }
    }

    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(source);
      return false;
    }

    return false;
  }

  void _showPermissionDialog(ImageSource source) {
    final isCamera = source == ImageSource.camera;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso necesario'),
        content: Text(
          isCamera
              ? 'Necesitamos acceso a tu cámara para tomar fotos de perfil.'
              : 'Necesitamos acceso a tu galería para elegir fotos de perfil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Abrir configuración'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage(File imageFile) async {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;

    if (profile == null) {
      _showError('No hay sesión activa');
      return;
    }

    setState(() => _isUploadingImage = true);

    try {
      // 1. Subir a Firebase Storage
      final imageUrl = await _storageService.uploadProfileImage(
        imageFile,
        profile.userId,
      );

      // 2. Actualizar en backend
      await authProvider.userService.updateProfileImage(imageUrl);

      // 3. Actualizar estado local
      authProvider.updateUserImage(imageUrl);

      _showSuccess('Foto de perfil actualizada');
    } catch (e) {
      _showError('Error al subir imagen: $e');
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  void _confirmDeleteImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu foto de perfil?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImage();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage() async {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.profile;

    if (profile == null) {
      _showError('No hay sesión activa');
      return;
    }

    setState(() => _isUploadingImage = true);

    try {
      // 1. Eliminar en backend
      await authProvider.userService.deleteProfileImage();

      // 2. Eliminar en Firebase Storage
      await _storageService.deleteOldProfileImage(profile.userId);

      // 3. Actualizar estado local
      authProvider.updateUserImage(null);

      _showSuccess('Foto de perfil eliminada');
    } catch (e) {
      _showError('Error al eliminar imagen: $e');
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  // ---------- COMPONENTES UI ----------

  Widget _input(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: _pickFecha,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Fecha de nacimiento',
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          child: Text(
            _fechaNacimiento == null
                ? 'Selecciona una fecha'
                : DateFormat('dd/MM/yyyy').format(_fechaNacimiento!),
            style: TextStyle(
              color: _fechaNacimiento == null ? Colors.grey : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ---------- ACTIONS ----------

  void _pickFecha() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: primary),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  void _guardar() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios guardados (mock)'),
      ),
    );
  }

  // ---------- HELPERS ----------

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
