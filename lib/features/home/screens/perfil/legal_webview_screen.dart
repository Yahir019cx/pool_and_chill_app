import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// URLs oficiales de documentos legales (web). Centralizadas para App Store / revisores.
class LegalUrls {
  LegalUrls._();
  static const String terminos = 'https://poolandchill.com.mx/terminos';
  static const String privacidad = 'https://poolandchill.com.mx/privacidad';
}

/// WebView que muestra términos de uso o aviso de privacidad desde la web.
/// Mejora la aceptación en App Store al enlazar a la versión web siempre actualizada.
class LegalWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const LegalWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends State<LegalWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const Color _primary = Color(0xFF2D9D91);

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final bool isIos = WebViewPlatform.instance is WebKitWebViewPlatform;
    PlatformWebViewControllerCreationParams params = isIos
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          )
        : const PlatformWebViewControllerCreationParams();

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: _primary),
            ),
        ],
      ),
    );
  }
}
