package com.poolandchill.app

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import me.didit.sdk.DiditSdk
import me.didit.sdk.DiditSdkState
import me.didit.sdk.Configuration
import me.didit.sdk.core.localization.SupportedLanguage

class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "com.poolandchill.app/didit"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startDiditVerification" -> {
                    Log.d(TAG, "[Didit] Android: método startDiditVerification recibido")
                    val sessionToken = call.argument<String>("sessionToken")
                    if (sessionToken.isNullOrBlank()) {
                        Log.e(TAG, "[Didit] Android: sessionToken vacío o null")
                        result.error("INVALID_ARGS", "sessionToken is required", null)
                        return@setMethodCallHandler
                    }
                    Log.d(TAG, "[Didit] Android: sessionToken length=${sessionToken.length}, entrando en runOnUiThread")
                    runOnUiThread {
                        val activity = this@MainActivity
                        val config = Configuration(languageLocale = SupportedLanguage.SPANISH)
                        CoroutineScope(Dispatchers.Main + Job()).launch {
                            try {
                                Log.d(TAG, "[Didit] Android: llamando DiditSdk.startVerification()")
                                DiditSdk.startVerification(
                                    token = sessionToken,
                                    configuration = config
                                ) { _ -> /* resultado vía webhook; Flutter consulta GET /kyc/status */ }
                                Log.d(TAG, "[Didit] Android: startVerification() retornó; esperando state Ready/Error...")
                                val state = DiditSdk.state.first { it is DiditSdkState.Ready || it is DiditSdkState.Error }
                                Log.d(TAG, "[Didit] Android: state recibido: ${state::class.simpleName}")
                                withContext(Dispatchers.Main) {
                                    when (state) {
                                        is DiditSdkState.Ready -> {
                                            Log.d(TAG, "[Didit] Android: llamando DiditSdk.launchVerificationUI()")
                                            DiditSdk.launchVerificationUI(activity)
                                            Log.d(TAG, "[Didit] Android: launchVerificationUI() retornó; result.success(null)")
                                            result.success(null)
                                        }
                                        is DiditSdkState.Error -> {
                                            Log.e(TAG, "[Didit] Android: DiditSdkState.Error - ${state.message}")
                                            result.error("SDK_ERROR", state.message, null)
                                        }
                                        else -> {
                                            Log.e(TAG, "[Didit] Android: state inesperado - $state")
                                            result.error("SDK_ERROR", "Unknown state", null)
                                        }
                                    }
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "[Didit] Android: excepción - ${e.message}", e)
                                result.error("SDK_ERROR", e.message ?: "Unknown error", null)
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
