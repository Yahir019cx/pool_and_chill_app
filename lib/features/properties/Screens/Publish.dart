import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'step1_screen.dart';
import 'step2_screen.dart';
import 'step3_screen.dart';
import 'FirstAnfitrionesScreen.dart';

class PublishScreen extends ConsumerStatefulWidget {
  const PublishScreen({super.key});

  @override
  ConsumerState<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends ConsumerState<PublishScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // 0 = intro, 1-4 = steps

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() => _goToPage(_currentPage + 1);
  void _previousPage() => _goToPage(_currentPage - 1);

  /// Al salir de step1, pre-cargar amenidades del catálogo
  void _onStep1Next() {
    final state = ref.read(propertyRegistrationProvider);
    final categories = state.categoriasQuery;

    // Dispara el fetch de amenidades para que esté listo en step3
    if (categories.isNotEmpty) {
      ref.read(amenitiesProvider(categories));
    }

    _nextPage();
  }

  void _onExit() {
    // Preguntar si quiere salir y perder el progreso
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir del registro?'),
        content: const Text(
          'Tu progreso se mantendrá guardado mientras no cierres la app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentPage > 0) {
          _onExit();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _currentPage == 0
            ? null
            : AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: _onExit,
                ),
                title: const Text(
                  'Registrar espacio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
              ),
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              // Page 0: Intro
              FirstAnfitrionesScreen(onStartPressed: _nextPage),

              // Page 1: Step 1 - Tipo de espacio
              Step1Screen(onNext: _onStep1Next),

              // Page 2: Step 2 - Ubicación
              Step2Screen(
                onNext: _nextPage,
                onPrevious: _previousPage,
              ),

              // Page 3: Step 3 - Detalles
              Step3Screen(
                onNext: _nextPage,
                onPrevious: _previousPage,
              ),

              // Page 4: Step 4 - (Próximamente)
              _Step4Placeholder(onPrevious: _previousPage),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder para Step 4
class _Step4Placeholder extends StatelessWidget {
  final VoidCallback onPrevious;

  const _Step4Placeholder({required this.onPrevious});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Paso 4 de 4',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisión y publicación',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Próximamente...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onPrevious,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3CA2A2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Anterior',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3CA2A2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: null, // Deshabilitado por ahora
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3CA2A2),
                      disabledBackgroundColor:
                          const Color(0xFF3CA2A2).withValues(alpha: 0.4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Publicar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
