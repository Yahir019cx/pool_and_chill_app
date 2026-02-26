// perfil/widgets/editar_perfil_form.dart
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:pool_and_chill_app/data/models/catalog_model.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/services/catalog_service.dart';
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
  final _telefonoCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  // Ubicación: dropdown de estados del catálogo
  List<StateCatalogItem> _states = [];
  int? _selectedStateId;
  bool _loadingStates = false;

  // Para manejo de imagen
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;
  bool _isSaving = false;

  static const Color primary = Color(0xFF3CA2A2);
  static const Color inputBg = Color(0xFFF4F6F8);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadStates();
  }

  void _loadProfileData() {
    final profile = context.read<AuthProvider>().profile;
    if (profile != null) {
      _nombreCtrl.text = profile.firstName;
      _apellidoCtrl.text = profile.lastName;
      _telefonoCtrl.text = profile.phoneNumber ?? '';
      _bioCtrl.text = profile.bio ?? '';
    }
  }

  Future<void> _loadStates() async {
    setState(() => _loadingStates = true);
    try {
      final api = context.read<AuthProvider>().apiClient;
      final states = await CatalogService(api).getStates();
      if (!mounted) return;

      // Pre-seleccionar si el perfil ya tiene una ubicación guardada
      final currentLocation =
          context.read<AuthProvider>().profile?.location ?? '';

      int? matchedId;
      if (currentLocation.isNotEmpty) {
        for (final s in states) {
          if (s.name.toLowerCase() == currentLocation.toLowerCase()) {
            matchedId = s.id;
            break;
          }
        }
      }

      setState(() {
        _states = states;
        _selectedStateId = matchedId;
      });
    } catch (_) {
      // Si falla el catálogo el resto del formulario sigue funcionando
    } finally {
      if (mounted) setState(() => _loadingStates = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
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
          _input(
            'Nombre',
            _nombreCtrl,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre';
              if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s'-]+$").hasMatch(v.trim())) {
                return 'El nombre solo puede contener letras';
              }
              return null;
            },
          ),
          _input(
            'Apellido',
            _apellidoCtrl,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu apellido';
              if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s'-]+$").hasMatch(v.trim())) {
                return 'El apellido solo puede contener letras';
              }
              return null;
            },
          ),
          _input(
            'Teléfono',
            _telefonoCtrl,
            keyboard: TextInputType.phone,
          ),
          _locationDropdown(),
          _input('Biografía', _bioCtrl, maxLines: 3),

          const SizedBox(height: 32),

          /// ---------- BOTÓN ----------
          ElevatedButton(
            onPressed: _isSaving ? null : _guardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: primary.withValues(alpha: 0.6),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
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

    if (Platform.isIOS) {
      _showCupertinoImageOptions(hasImage);
    } else {
      _showMaterialImageOptions(hasImage);
    }
  }

  void _showCupertinoImageOptions(bool hasImage) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Cambiar foto de perfil'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Tomar foto'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Elegir de galería'),
          ),
          if (hasImage)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                _confirmDeleteImage();
              },
              child: const Text('Eliminar foto'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  void _showMaterialImageOptions(bool hasImage) {
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
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
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
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
    // image_picker v1.x maneja permisos de galería internamente en Android
    // (usa el system photo picker en Android 13+, sin permiso requerido).
    // Solo verificamos permiso de cámara manualmente.
    if (source == ImageSource.gallery) return true;

    final status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.camera.request();
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
    final message = isCamera
        ? 'Necesitamos acceso a tu cámara para tomar fotos de perfil.'
        : 'Necesitamos acceso a tu galería para elegir fotos de perfil.';

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Permiso necesario'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permiso necesario'),
          content: Text(message),
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

      // 3. Refrescar perfil completo para obtener todos los datos
      await authProvider.refreshProfile();

      _showSuccess('Foto de perfil actualizada');
    } catch (e) {
      _showError('Error al subir imagen: $e');
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  void _confirmDeleteImage() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Eliminar foto'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar tu foto de perfil?',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                _deleteImage();
              },
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
    } else {
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

      // 3. Refrescar perfil completo
      await authProvider.refreshProfile();

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
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: validator,
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

  // ---------- DROPDOWN UBICACIÓN ----------

  Widget _locationDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<int>(
        value: _selectedStateId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Estado',
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
          suffixIcon: _loadingStates
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primary,
                    ),
                  ),
                )
              : null,
        ),
        hint: const Text('Selecciona un estado'),
        items: _states
            .map(
              (s) => DropdownMenuItem<int>(
                value: s.id,
                child: Text(s.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: _loadingStates
            ? null
            : (id) => setState(() => _selectedStateId = id),
      ),
    );
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? true)) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final profile = authProvider.profile;

      if (profile == null) {
        _showError('No hay sesión activa');
        return;
      }

      // Construir displayName desde nombre y apellido
      final displayName = '${_nombreCtrl.text.trim()} ${_apellidoCtrl.text.trim()}'.trim();

      // Obtener el nombre del estado seleccionado para enviarlo como location
      String? locationName;
      if (_selectedStateId != null) {
        try {
          locationName = _states
              .firstWhere((s) => s.id == _selectedStateId)
              .name;
        } catch (_) {}
      }

      await authProvider.updateProfile(
        displayName: displayName.isNotEmpty ? displayName : null,
        bio: _bioCtrl.text.trim().isNotEmpty ? _bioCtrl.text.trim() : null,
        phoneNumber: _telefonoCtrl.text.trim().isNotEmpty ? _telefonoCtrl.text.trim() : null,
        location: locationName,
      );

      _showSuccess('Cambios guardados');
    } catch (e) {
      _showError(_mensajeDeError(e));
    } finally {
      setState(() => _isSaving = false);
    }
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

  /// Extrae un mensaje limpio de una excepción, sin el prefijo "Exception: "
  String _mensajeDeError(Object e) {
    return e.toString().replaceFirst('Exception: ', '');
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              message,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(bottom: 24, left: 60, right: 60),
        duration: const Duration(milliseconds: 1500),
        elevation: 2,
      ),
    );
  }
}
