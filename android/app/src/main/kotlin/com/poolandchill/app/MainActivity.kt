package com.poolandchill.app

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
                        pendingResult?.success(null)
                        pendingResult = null
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
                        when (verificationResult) {
                            is VerificationResult.Completed -> {
                                Log.d(TAG, "[Didit] Completado — status: ${verificationResult.session.status}")
                            }
                            is VerificationResult.Cancelled -> {
                                Log.d(TAG, "[Didit] Cancelado por el usuario")
                            }
                            is VerificationResult.Failed -> {
                                Log.e(TAG, "[Didit] Falló: ${verificationResult.error.message}")
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
