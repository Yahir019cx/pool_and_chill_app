package com.poolandchill.app

import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import me.didit.sdk.Configuration
import me.didit.sdk.DiditSdk
import me.didit.sdk.DiditSdkState
import me.didit.sdk.VerificationResult
import me.didit.sdk.core.localization.SupportedLanguage

class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "com.poolandchill.app/didit"
    }

    // Guarda el result pendiente de Flutter para responder cuando el SDK esté listo
    @Volatile
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Observer PERSISTENTE de estado del SDK — siguiendo el patrón oficial de la doc.
        // Debe estar activo ANTES de que se llame startVerification.
        lifecycleScope.launch {
            DiditSdk.state.collect { state ->
                Log.d(TAG, "[Didit] SDK state: ${state::class.simpleName}")
                when (state) {
                    is DiditSdkState.Ready -> {
                        Log.d(TAG, "[Didit] Ready — lanzando UI de verificación")
                        DiditSdk.launchVerificationUI(this@MainActivity)
                        // No resolvemos pendingResult aquí — esperamos al callback de resultado
                    }
                    is DiditSdkState.Error -> {
                        Log.e(TAG, "[Didit] Error del SDK: ${state.message}")
                        pendingResult?.error("SDK_ERROR", state.message, null)
                        pendingResult = null
                    }
                    else -> {
                        // Idle, Loading, CreatingSession — no hacer nada
                    }
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startDiditVerification" -> {
                    Log.d(TAG, "[Didit] Método startDiditVerification recibido")
                    val sessionToken = call.argument<String>("sessionToken")
                    if (sessionToken.isNullOrBlank()) {
                        Log.e(TAG, "[Didit] sessionToken vacío o null")
                        result.error("INVALID_ARGS", "sessionToken es requerido", null)
                        return@setMethodCallHandler
                    }
                    Log.d(TAG, "[Didit] sessionToken recibido (length=${sessionToken.length})")

                    // Guardar el result ANTES de llamar startVerification
                    pendingResult = result

                    val config = Configuration(
                        languageLocale = SupportedLanguage.SPANISH,
                        loggingEnabled = true
                    )

                    // Llamar startVerification — el observer de estado arriba maneja el lanzamiento de UI
                    DiditSdk.startVerification(
                        token = sessionToken,
                        configuration = config
                    ) { verificationResult ->
                        // El callback puede venir de un hilo de fondo.
                        // MethodChannel.Result DEBE resolverse en el UI thread.
                        Handler(Looper.getMainLooper()).post {
                            when (verificationResult) {
                                is VerificationResult.Completed -> {
                                    val status = verificationResult.session.status.name
                                    Log.d(TAG, "[Didit] Completado — status: $status (enviando a Flutter)")
                                    pendingResult?.success(status)
                                    pendingResult = null
                                }
                                is VerificationResult.Cancelled -> {
                                    Log.d(TAG, "[Didit] Cancelado por el usuario (enviando a Flutter)")
                                    pendingResult?.success("CANCELLED")
                                    pendingResult = null
                                }
                                is VerificationResult.Failed -> {
                                    val msg = verificationResult.error.message
                                    Log.e(TAG, "[Didit] Falló: $msg (enviando a Flutter)")
                                    pendingResult?.error("VERIFICATION_FAILED", msg, null)
                                    pendingResult = null
                                }
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
