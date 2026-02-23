import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
    // Solicitar permisos al SO en el primer frame y luego cargar la URL.
    // Sin esto, Android e iOS no permiten al WebView acceder a la cámara
    // aunque los handlers internos del WebView los otorguen a su nivel.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _requestPermissionsAndLoad(),
    );
  }

  void _initController() {
    final bool isIos = WebViewPlatform.instance is WebKitWebViewPlatform;

    // ── iOS (WKWebView) ────────────────────────────────────────────────────
    // allowsInlineMediaPlayback: permite que el video/cámara se muestre
    //   dentro del WebView en lugar de pantalla completa nativa.
    // mediaTypesRequiringUserAction vacío: evita que iOS bloquee la
    //   reproducción automática de media (necesario para el flujo de Didit).
    PlatformWebViewControllerCreationParams params;
    if (isIos) {
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
            if (request.url.startsWith(_kycDeeplinkPrefix)) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // ── iOS: conceder permisos de cámara/micrófono al WKWebView ───────────
    // En iOS 15+, cuando el sitio web pide acceso a la cámara, el sistema
    // llama al WKUIDelegate.requestMediaCapturePermissionFor. Sin este
    // handler, el default es mostrar un diálogo del sistema (PermissionDecision.prompt).
    // Con el handler lo otorgamos directamente (ya pedimos permiso al SO antes).
    // webview_flutter_wkwebview 3.12+ expone setOnPlatformPermissionRequest.
    if (_controller.platform is WebKitWebViewController) {
      (_controller.platform as WebKitWebViewController)
          .setOnPlatformPermissionRequest((request) => request.grant());
    }

    // ── Android: conceder permisos de cámara/micrófono al WebView ─────────
    // Análogo al WKUIDelegate de iOS. Sin esto Android bloquea el acceso
    // a la cámara aunque el app tenga el permiso del SO.
    if (_controller.platform is AndroidWebViewController) {
      (_controller.platform as AndroidWebViewController)
          .setOnPlatformPermissionRequest((request) => request.grant());
    }
    // NOTA: loadRequest se llama en _requestPermissionsAndLoad, no aquí.
  }

  /// Solicita permisos de cámara y micrófono al SO (Android e iOS)
  /// antes de cargar la URL del WebView.
  ///
  /// Los handlers de WebView (setOnPermissionRequest / setOnPlatformPermissionRequest)
  /// solo funcionan si el app YA tiene el permiso del SO. Si no lo tiene,
  /// Android e iOS bloquean el acceso a la cámara antes de llegar al handler.
  Future<void> _requestPermissionsAndLoad() async {
    await [Permission.camera, Permission.microphone].request();
    if (!mounted) return;
    await _controller.loadRequest(Uri.parse(widget.url));
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
