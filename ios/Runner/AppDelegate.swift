import Flutter
import UIKit
import GoogleMaps
import DiditSDK
import Combine

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var cancellables = Set<AnyCancellable>()

    // Guarda el result pendiente de Flutter para responder cuando el SDK esté listo
    private var pendingResult: FlutterResult?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyAtg_8BWOdxKbvWi4_B9lrETu_FXN3SxOs")
        GeneratedPluginRegistrant.register(with: self)

        // Observer PERSISTENTE de estado del SDK — siguiendo el patrón oficial de la doc.
        // Debe estar activo ANTES de que se llame startVerification.
        DiditSdk.shared.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .ready:
                    NSLog("[Didit iOS] Estado: Ready — SDK lanzando UI automáticamente")
                    self.pendingResult?(nil)
                    self.pendingResult = nil
                case .error(let message):
                    NSLog("[Didit iOS] Estado: Error — \(message)")
                    self.pendingResult?(FlutterError(code: "SDK_ERROR", message: message, details: nil))
                    self.pendingResult = nil
                default:
                    break
                }
            }
            .store(in: &cancellables)

        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        setupDiditMethodChannel()
        return result
    }

    private func setupDiditMethodChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            NSLog("[Didit iOS] ERROR: rootViewController no es FlutterViewController")
            return
        }

        let channel = FlutterMethodChannel(
            name: "com.poolandchill.app/didit",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }

            switch call.method {
            case "startDiditVerification":
                guard let args = call.arguments as? [String: Any],
                      let token = args["sessionToken"] as? String,
                      !token.isEmpty else {
                    result(FlutterError(
                        code: "INVALID_ARGS",
                        message: "sessionToken es requerido",
                        details: nil
                    ))
                    return
                }

                NSLog("[Didit iOS] Iniciando verificación con token (length=\(token.count))")

                // Guardar el result ANTES de llamar startVerification
                self.pendingResult = result

                let config = DiditSdk.Configuration(
                    languageLocale: .spanish,
                    loggingEnabled: true
                )

                // El SDK lanza la UI automáticamente cuando el estado pasa a .ready
                DiditSdk.shared.startVerification(token: token, configuration: config)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
