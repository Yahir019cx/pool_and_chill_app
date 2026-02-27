import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// WebView para que el host actualice sus datos bancarios / fiscales en Stripe.
///
/// Devuelve [true]  cuando Stripe redirige a poolandchill://stripe/return  (flujo completado).
/// Devuelve [false] cuando Stripe redirige a poolandchill://stripe/refresh (link expirado).
/// Devuelve [null]  si el usuario cierra el WebView manualmente.
class StripeUpdateWebviewScreen extends StatefulWidget {
  final String url;

  const StripeUpdateWebviewScreen({super.key, required this.url});

  @override
  State<StripeUpdateWebviewScreen> createState() =>
      _StripeUpdateWebviewScreenState();
}

class _StripeUpdateWebviewScreenState
    extends State<StripeUpdateWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const Color _primary = Color(0xFF2D9D91);
  static const String _returnUrl = 'poolandchill://stripe/return';
  static const String _refreshUrl = 'poolandchill://stripe/refresh';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final bool isIos = WebViewPlatform.instance is WebKitWebViewPlatform;

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
            // Stripe redirigió a return: flujo completado con éxito.
            if (request.url.startsWith(_returnUrl)) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            // Stripe redirigió a refresh: el link expiró o ya fue usado.
            if (request.url.startsWith(_refreshUrl)) {
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
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
        title: const Text(
          'Datos bancarios',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(null),
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
