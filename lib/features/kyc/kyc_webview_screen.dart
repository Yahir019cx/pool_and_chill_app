import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// WebView que carga la URL de verificación Didit.
/// Devuelve [true] cuando Didit redirige a poolandchill://kyc/result (flujo completado).
/// Devuelve [false] si el usuario cierra manualmente.
class KycWebViewScreen extends StatefulWidget {
  final String url;

  const KycWebViewScreen({super.key, required this.url});

  @override
  State<KycWebViewScreen> createState() => _KycWebViewScreenState();
}

class _KycWebViewScreenState extends State<KycWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const Color _primary = Color(0xFF3CA2A2);
  static const String _kycDeeplinkPrefix = 'poolandchill://kyc/result';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    // iOS: habilitar inline media playback para la cámara del WebView
    PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            // Interceptar el deeplink que Didit lanza al terminar
            if (request.url.startsWith(_kycDeeplinkPrefix)) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // Android: conceder permisos de cámara/micrófono al WebView automáticamente
    if (_controller.platform is AndroidWebViewController) {
      (_controller.platform as AndroidWebViewController)
          .setOnPlatformPermissionRequest((request) => request.grant());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Verificación de identidad',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(false),
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
