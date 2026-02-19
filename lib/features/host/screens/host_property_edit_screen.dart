import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart' as provider_pkg;

import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/storage_service.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_constants.dart';

import 'widgets/host_edit_amenities_tab.dart';
import 'widgets/host_edit_basic_tab.dart';
import 'widgets/host_edit_images_tab.dart';
import 'widgets/host_edit_rules_tab.dart';
import 'widgets/host_edit_types.dart';

class HostPropertyEditScreen extends ConsumerStatefulWidget {
  final String propertyId;
  const HostPropertyEditScreen({super.key, required this.propertyId});

  @override
  ConsumerState<HostPropertyEditScreen> createState() =>
      _HostPropertyEditScreenState();
}

class _HostPropertyEditScreenState
    extends ConsumerState<HostPropertyEditScreen> {
  bool _initialized = false;
  bool _initScheduled = false;

  final _ctrl = HostEditControllers();
  final _times = HostEditTimes();

  List<HostAmenityEntry> _poolAmenities = [];
  List<HostAmenityEntry> _cabinAmenities = [];
  List<HostAmenityEntry> _campingAmenities = [];
  List<HostEditableRule> _rules = [];
  List<PropertyImageDetail> _images = [];

  bool _savingBasicInfo = false;
  bool _savingPoolAm = false;
  bool _savingCabinAm = false;
  bool _savingCampingAm = false;
  bool _savingRules = false;
  bool _addingImage = false;
  bool _pickingImage = false;
  String? _deletingImageId;

  @override
  void dispose() {
    _ctrl.dispose();
    for (final r in _rules) {
      r.dispose();
    }
    super.dispose();
  }

  // ─── Initialization ───────────────────────────────────────────

  void _scheduleInit(
      PropertyDetailResponse data, List<AmenityModel> catalog) {
    if (_initialized || _initScheduled) return;
    _initScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _populateFromData(data, catalog));
    });
  }

  void _populateFromData(
      PropertyDetailResponse data, List<AmenityModel> catalog) {
    _initialized = true;
    final prop = data.property;

    _ctrl.desc.text = prop.description ?? '';

    if (prop.hasPool && data.pools.isNotEmpty) {
      final pool = data.pools.first;
      _times.poolCheckIn = _parseTime(pool.checkInTime);
      _times.poolCheckOut = _parseTime(pool.checkOutTime); 
      _ctrl.poolPriceWd.text = pool.priceWeekday?.toString() ?? '';
      _ctrl.poolPriceWe.text = pool.priceWeekend?.toString() ?? '';
      _ctrl.poolMaxP.text = pool.maxPersons?.toString() ?? '';
      _ctrl.poolTempMin.text = pool.temperatureMin?.toString() ?? '';
      _ctrl.poolTempMax.text = pool.temperatureMax?.toString() ?? '';
      _poolAmenities = _matchAmenities(pool.amenities, catalog, 'pool');
    }

    if (prop.hasCabin && data.cabins.isNotEmpty) {
      final cabin = data.cabins.first;
      _times.cabinCheckIn = _parseTime(cabin.checkInTime);
      _times.cabinCheckOut = _parseTime(cabin.checkOutTime);
      _ctrl.cabinMinN.text = cabin.minNights?.toString() ?? '';
      _ctrl.cabinMaxN.text = cabin.maxNights?.toString() ?? '';
      _ctrl.cabinPriceWd.text = cabin.priceWeekday?.toString() ?? '';
      _ctrl.cabinPriceWe.text = cabin.priceWeekend?.toString() ?? '';
      _ctrl.cabinMaxG.text = cabin.maxGuests?.toString() ?? '';
      _ctrl.cabinBed.text = cabin.bedrooms?.toString() ?? '';
      _ctrl.cabinSingleB.text = cabin.singleBeds?.toString() ?? '';
      _ctrl.cabinDoubleB.text = cabin.doubleBeds?.toString() ?? '';
      _ctrl.cabinFullBath.text = cabin.fullBathrooms?.toString() ?? '';
      _ctrl.cabinHalfBath.text = cabin.halfBathrooms?.toString() ?? '';
      _cabinAmenities = _matchAmenities(cabin.amenities, catalog, 'cabin');
    }

    if (prop.hasCamping && data.campingAreas.isNotEmpty) {
      final camp = data.campingAreas.first;
      _times.campCheckIn = _parseTime(camp.checkInTime);
      _times.campCheckOut = _parseTime(camp.checkOutTime);
      _ctrl.campMinN.text = camp.minNights?.toString() ?? '';
      _ctrl.campMaxN.text = camp.maxNights?.toString() ?? '';
      _ctrl.campPriceWd.text = camp.priceWeekday?.toString() ?? '';
      _ctrl.campPriceWe.text = camp.priceWeekend?.toString() ?? '';
      _ctrl.campMaxP.text = camp.maxPersons?.toString() ?? '';
      _ctrl.campArea.text = camp.areaSquareMeters?.toString() ?? '';
      _ctrl.campTents.text = camp.approxTents?.toString() ?? '';
      _campingAmenities =
          _matchAmenities(camp.amenities, catalog, 'camping');
    }

    _rules = data.rules
        .asMap()
        .entries
        .map((e) => HostEditableRule(e.value.ruleText))
        .toList();
    if (_rules.isEmpty) {
      _rules.add(HostEditableRule(''));
    }

    _images = List.from(data.sortedImages);
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(propertyDetailProvider(widget.propertyId));
    final asyncCatalog = ref.watch(amenitiesProvider('pool,cabin,camping'));

    final isReady = asyncDetail.hasValue && asyncCatalog.hasValue;
    if (isReady && !_initialized) {
      _scheduleInit(asyncDetail.value!, asyncCatalog.value!);
    }

    if (!isReady || !_initialized) {
      if (asyncDetail.hasError) return _buildError(asyncDetail.error!);
      if (asyncCatalog.hasError) return _buildError(asyncCatalog.error!);
      return _loadingScaffold();
    }

    final prop = asyncDetail.value!.property;
    final catalog = asyncCatalog.value!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: kDetailDark,
          title: const Text(
            'Editar propiedad',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          bottom: TabBar(
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            tabs: const [
              Tab(text: 'Básica'),
              Tab(text: 'Amenidades'),
              Tab(text: 'Reglas'),
              Tab(text: 'Fotos'),
            ],
            labelColor: kDetailPrimary,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: kDetailPrimary,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        body: TabBarView(
          children: [
            HostEditBasicTab(
              ctrl: _ctrl,
              prop: prop,
              times: _times,
              onTimesChanged: (mutate) => setState(() => mutate(_times)),
              saving: _savingBasicInfo,
              onSave: () => _saveBasicInfo(prop),
            ),
            HostEditAmenitiesTab(
              ctrl: _ctrl,
              prop: prop,
              catalog: catalog,
              poolAmenities: _poolAmenities,
              onPoolAmenityAdded: (a) =>
                  setState(() => _poolAmenities.add(a)),
              onPoolAmenityRemoved: (i) =>
                  setState(() => _poolAmenities.removeAt(i)),
              savingPool: _savingPoolAm,
              onSavePool: _savePoolAmenities,
              cabinAmenities: _cabinAmenities,
              onCabinAmenityAdded: (a) =>
                  setState(() => _cabinAmenities.add(a)),
              onCabinAmenityRemoved: (i) =>
                  setState(() => _cabinAmenities.removeAt(i)),
              savingCabin: _savingCabinAm,
              onSaveCabin: _saveCabinAmenities,
              campingAmenities: _campingAmenities,
              onCampingAmenityAdded: (a) =>
                  setState(() => _campingAmenities.add(a)),
              onCampingAmenityRemoved: (i) =>
                  setState(() => _campingAmenities.removeAt(i)),
              savingCamping: _savingCampingAm,
              onSaveCamping: _saveCampingAmenities,
            ),
            HostEditRulesTab(
              rules: _rules,
              onAddRule: () =>
                  setState(() => _rules.add(HostEditableRule(''))),
              onRemoveRule: (i) => setState(() {
                _rules[i].dispose();
                _rules.removeAt(i);
              }),
              onReorder: (oldIdx, newIdx) => setState(() {
                if (newIdx > oldIdx) newIdx--;
                final item = _rules.removeAt(oldIdx);
                _rules.insert(newIdx, item);
              }),
              saving: _savingRules,
              onSave: _saveRules,
            ),
            HostEditImagesTab(
              images: _images,
              deletingImageId: _deletingImageId,
              adding: _addingImage,
              onAddImage: _pickAndAddImage,
              onDeleteImage: _deleteImage,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Save: información básica ─────────────────────────────────

  Future<void> _saveBasicInfo(PropertyDetailProperty prop) async {
    final dataMap = <String, dynamic>{};

    final desc = _ctrl.desc.text.trim();
    if (desc.isNotEmpty) {
      dataMap['description'] = desc;
    }

    if (prop.hasPool &&
        _times.poolCheckIn != null &&
        _times.poolCheckOut != null) {
      final priceWd = double.tryParse(_ctrl.poolPriceWd.text.trim());
      final priceWe = double.tryParse(_ctrl.poolPriceWe.text.trim());
      if (priceWd != null && priceWe != null) {
        dataMap['pool'] = {
          'checkInTime': _fmtStr(_times.poolCheckIn!),
          'checkOutTime': _fmtStr(_times.poolCheckOut!),
          'priceWeekday': priceWd,
          'priceWeekend': priceWe,
        };
      }
    }

    if (prop.hasCabin &&
        _times.cabinCheckIn != null &&
        _times.cabinCheckOut != null) {
      final priceWd = double.tryParse(_ctrl.cabinPriceWd.text.trim());
      final priceWe = double.tryParse(_ctrl.cabinPriceWe.text.trim());
      if (priceWd != null && priceWe != null) {
        dataMap['cabin'] = {
          'checkInTime': _fmtStr(_times.cabinCheckIn!),
          'checkOutTime': _fmtStr(_times.cabinCheckOut!),
          if (_ctrl.cabinMinN.text.trim().isNotEmpty)
            'minNights': int.tryParse(_ctrl.cabinMinN.text.trim()),
          if (_ctrl.cabinMaxN.text.trim().isNotEmpty)
            'maxNights': int.tryParse(_ctrl.cabinMaxN.text.trim()),
          'priceWeekday': priceWd,
          'priceWeekend': priceWe,
        };
      }
    }

    if (prop.hasCamping &&
        _times.campCheckIn != null &&
        _times.campCheckOut != null) {
      final priceWd = double.tryParse(_ctrl.campPriceWd.text.trim());
      final priceWe = double.tryParse(_ctrl.campPriceWe.text.trim());
      if (priceWd != null && priceWe != null) {
        dataMap['camping'] = {
          'checkInTime': _fmtStr(_times.campCheckIn!),
          'checkOutTime': _fmtStr(_times.campCheckOut!),
          if (_ctrl.campMinN.text.trim().isNotEmpty)
            'minNights': int.tryParse(_ctrl.campMinN.text.trim()),
          if (_ctrl.campMaxN.text.trim().isNotEmpty)
            'maxNights': int.tryParse(_ctrl.campMaxN.text.trim()),
          'priceWeekday': priceWd,
          'priceWeekend': priceWe,
        };
      }
    }

    if (dataMap.isEmpty) {
      _showSnack('Completa al menos un campo antes de guardar');
      return;
    }

    setState(() => _savingBasicInfo = true);
    try {
      final service = ref.read(propertyServiceProvider);
      await service.updateBasicInfo(widget.propertyId, dataMap);
      _showSnack('Información básica actualizada', success: true);
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _savingBasicInfo = false);
    }
  }

  // ─── Save: amenidades alberca ─────────────────────────────────

  Future<void> _savePoolAmenities() async {
    final maxP = int.tryParse(_ctrl.poolMaxP.text.trim());
    if (maxP == null || maxP < 1) {
      _showSnack('Ingresa una capacidad válida (mínimo 1)');
      return;
    }
    final tempMin = double.tryParse(_ctrl.poolTempMin.text.trim());
    final tempMax = double.tryParse(_ctrl.poolTempMax.text.trim());
    final items = _buildAmenityItems(_poolAmenities);

    setState(() => _savingPoolAm = true);
    try {
      final service = ref.read(propertyServiceProvider);
      await service.updatePoolAmenities(
        propertyId: widget.propertyId,
        maxPersons: maxP,
        temperatureMin: tempMin,
        temperatureMax: tempMax,
        items: items.isNotEmpty ? items : null,
      );
      _showSnack('Amenidades de alberca actualizadas', success: true);
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _savingPoolAm = false);
    }
  }

  // ─── Save: amenidades cabaña ──────────────────────────────────

  Future<void> _saveCabinAmenities() async {
    final maxG = int.tryParse(_ctrl.cabinMaxG.text.trim());
    final beds = int.tryParse(_ctrl.cabinBed.text.trim());
    final singleB = int.tryParse(_ctrl.cabinSingleB.text.trim());
    final doubleB = int.tryParse(_ctrl.cabinDoubleB.text.trim());
    final fullBath = int.tryParse(_ctrl.cabinFullBath.text.trim());

    if ([maxG, beds, singleB, doubleB, fullBath]
        .any((v) => v == null || v < 0)) {
      _showSnack('Completa todos los campos requeridos con valores válidos');
      return;
    }
    final halfBath = int.tryParse(_ctrl.cabinHalfBath.text.trim());
    final items = _buildAmenityItems(_cabinAmenities);

    setState(() => _savingCabinAm = true);
    try {
      final service = ref.read(propertyServiceProvider);
      await service.updateCabinAmenities(
        propertyId: widget.propertyId,
        maxGuests: maxG!,
        bedrooms: beds!,
        singleBeds: singleB!,
        doubleBeds: doubleB!,
        fullBathrooms: fullBath!,
        halfBathrooms: halfBath,
        items: items.isNotEmpty ? items : null,
      );
      _showSnack('Amenidades de cabaña actualizadas', success: true);
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _savingCabinAm = false);
    }
  }

  // ─── Save: amenidades camping ─────────────────────────────────

  Future<void> _saveCampingAmenities() async {
    final maxP = int.tryParse(_ctrl.campMaxP.text.trim());
    final area = double.tryParse(_ctrl.campArea.text.trim());
    final tents = int.tryParse(_ctrl.campTents.text.trim());

    if (maxP == null || maxP < 1 || area == null || area < 1 ||
        tents == null || tents < 1) {
      _showSnack('Completa todos los campos con valores válidos');
      return;
    }
    final items = _buildAmenityItems(_campingAmenities);

    setState(() => _savingCampingAm = true);
    try {
      final service = ref.read(propertyServiceProvider);
      await service.updateCampingAmenities(
        propertyId: widget.propertyId,
        maxPersons: maxP,
        areaSquareMeters: area,
        approxTents: tents,
        items: items.isNotEmpty ? items : null,
      );
      _showSnack('Amenidades de camping actualizadas', success: true);
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _savingCampingAm = false);
    }
  }

  // ─── Save: reglas ─────────────────────────────────────────────

  Future<void> _saveRules() async {
    final valid =
        _rules.where((r) => r.ctrl.text.trim().isNotEmpty).toList();
    if (valid.isEmpty) {
      _showSnack('Debe haber al menos una regla con texto');
      return;
    }
    final requests = valid.asMap().entries.map((e) => PropertyRuleRequest(
          text: e.value.ctrl.text.trim(),
          order: e.key + 1,
        )).toList();

    setState(() => _savingRules = true);
    try {
      final service = ref.read(propertyServiceProvider);
      await service.updateRules(
          propertyId: widget.propertyId, rules: requests);
      _showSnack('Reglas actualizadas', success: true);
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _savingRules = false);
    }
  }

  // ─── Imágenes ─────────────────────────────────────────────────

  Future<void> _deleteImage(PropertyImageDetail image) async {
    setState(() => _deletingImageId = image.idPropertyImage);
    try {
      // 1. Confirmar con el backend primero
      final service = ref.read(propertyServiceProvider);
      await service.deletePropertyImage(
        propertyId: widget.propertyId,
        propertyImageId: image.idPropertyImage,
      );

      // 2. Backend exitoso → limpiar de Firebase Storage
      try {
        await FirebaseStorage.instance.refFromURL(image.imageURL).delete();
      } catch (_) {
        // Fallo en Storage no bloquea al usuario; el backend ya confirmó.
      }

      // 3. Actualizar la UI
      if (mounted) {
        setState(() => _images
            .removeWhere((i) => i.idPropertyImage == image.idPropertyImage));
      }
      _showSnack('Imagen eliminada', success: true);
    } catch (e) {
      // Backend falló (ej. última imagen → 400): no tocamos Firebase
      _showSnack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _deletingImageId = null);
    }
  }

  Future<void> _pickAndAddImage() async {
    if (_pickingImage) return;
    _pickingImage = true;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (picked == null || !mounted) return;

      final auth =
          provider_pkg.Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.profile?.userId;
      if (userId == null) {
        _showSnack('Sesión no válida, vuelve a iniciar sesión');
        return;
      }

      setState(() => _addingImage = true);
      try {
        final file = File(picked.path);
        final storageService = StorageService();
        final urls = await storageService.uploadPropertyImages([file], userId);
        if (urls.isEmpty) throw Exception('No se pudo subir la imagen');

        final service = ref.read(propertyServiceProvider);
        final result = await service.addPropertyImage(
          propertyId: widget.propertyId,
          imageUrl: urls.first,
          isPrimary: _images.isEmpty,
        );

        setState(() {
          _images.add(PropertyImageDetail(
            idPropertyImage: result.idPropertyImage,
            imageURL: urls.first,
            isPrimary: _images.isEmpty,
            displayOrder: _images.length,
          ));
        });
        _showSnack('Imagen agregada', success: true);
      } catch (e) {
        _showSnack(e.toString().replaceAll('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _addingImage = false);
      }
    } finally {
      _pickingImage = false;
    }
  }

  // ─── Scaffolds auxiliares ─────────────────────────────────────

  Widget _loadingScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: kDetailDark,
        title: const Text('Editar propiedad',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: const Center(
          child: CircularProgressIndicator(color: kDetailPrimary)),
    );
  }

  Widget _buildError(Object err) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: kDetailDark,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No se pudo cargar la propiedad',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kDetailDark),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 13, color: kDetailGrey),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  ref.invalidate(
                      propertyDetailProvider(widget.propertyId));
                  setState(() {
                    _initialized = false;
                    _initScheduled = false;
                  });
                },
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Reintentar'),
                style:
                    TextButton.styleFrom(foregroundColor: kDetailPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Utilidades ───────────────────────────────────────────────

  /// Convierte un tiempo almacenado ('HH:MM', 'HH:MM:SS' o ISO) al
  /// formato de display que usa TimeSelector ('10:00 AM', '2:00 PM', etc.)
  String? _parseTime(String? stored) {
    if (stored == null || stored.isEmpty) return null;
    try {
      int hour, minute;
      if (stored.contains('T')) {
        final dt = DateTime.parse(stored);
        hour = dt.hour;
        minute = dt.minute;
      } else {
        final parts = stored.split(':');
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1].substring(0, 2));
      }
      final suffix = hour < 12 ? 'AM' : 'PM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final displayMin = minute.toString().padLeft(2, '0');
      return '$displayHour:$displayMin $suffix';
    } catch (_) {
      return null;
    }
  }

  /// Convierte el string de display ('10:00 AM', '2:00 PM') a 'HH:MM' para la API.
  String _fmtStr(String display) {
    final parts = display.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = timeParts[1];
    if (parts[1] == 'PM' && hour != 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  List<HostAmenityEntry> _matchAmenities(
      List<AmenityItem> current,
      List<AmenityModel> catalog,
      String category) {
    final catItems =
        catalog.where((c) => c.category.toLowerCase() == category).toList();
    final result = <HostAmenityEntry>[];
    for (final item in current) {
      final name = item.amenityName ?? '';
      try {
        final match = catItems.firstWhere(
          (c) => c.name.toLowerCase() == name.toLowerCase(),
        );
        result.add(HostAmenityEntry(
          catalogId: match.id,
          name: match.name,
          quantityText: item.quantity?.toString() ?? '',
        ));
      } catch (_) {
        // No encontrado en catálogo, se omite
      }
    }
    return result;
  }

  List<AmenityItemRequest> _buildAmenityItems(
      List<HostAmenityEntry> list) {
    return list.map((a) {
      final id = int.tryParse(a.catalogId) ?? 0;
      final qty = int.tryParse(a.quantityText);
      return AmenityItemRequest(amenityId: id, quantity: qty);
    }).where((r) => r.amenityId > 0).toList();
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? kDetailPrimary : Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}
