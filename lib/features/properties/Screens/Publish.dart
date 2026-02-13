import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'step1_screen.dart';
import 'step2_screen.dart';
import 'step3_screen.dart';
import 'step4_screen.dart';
import 'step5_screen.dart';
import 'step6_screen.dart';
import 'step7_screen.dart';
import 'step8_screen.dart';
import 'FirstAnfitrionesScreen.dart';

class PublishScreen extends ConsumerStatefulWidget {
  const PublishScreen({super.key});

  @override
  ConsumerState<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends ConsumerState<PublishScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // 0 = intro, 1-8 = steps

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
      // Forzar la ejecución del provider accediendo al future
      ref.read(amenitiesProvider(categories).future);
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
            child: const Text(
              'Continuar',
              style: TextStyle(color: Color(0xFF3CA2A2)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: Color(0xFF3CA2A2)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final skipStep7 = auth.profile?.isIdentityVerified ?? false;

    final children = <Widget>[
      FirstAnfitrionesScreen(onStartPressed: _nextPage),
      Step1Screen(onNext: _onStep1Next),
      Step2Screen(onNext: _nextPage, onPrevious: _previousPage),
      Step3Screen(onNext: _nextPage, onPrevious: _previousPage),
      Step4Screen(onNext: _nextPage, onPrevious: _previousPage),
      Step5Screen(onNext: _nextPage, onPrevious: _previousPage),
      Step6Screen(onNext: _nextPage, onPrevious: _previousPage),
      if (!skipStep7)
        Step7Screen(onNext: _nextPage, onPrevious: _previousPage),
      Step8Screen(onPrevious: _previousPage),
    ];

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
            children: children,
          ),
        ),
      ),
    );
  }
}
