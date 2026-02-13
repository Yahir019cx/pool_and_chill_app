# Integración Didit SDK Android (Flutter) – Instrucciones para Frontend

Este documento define lo que el **agente Frontend (Flutter/Android)** debe configurar para usar el SDK nativo de Didit con el backend actual.

---

## Checklist Backend (cumplimiento)

| Requisito | Estado |
|-----------|--------|
| POST /kyc/start existe (alias de /verification/start) | ✅ |
| Usuario autenticado (JWT) | ✅ |
| Sesión creada en Didit con API_KEY, WORKFLOW_ID, vendor_data = userId | ✅ |
| Guardado en BD: didit_session_id (+ URL) | ✅ |
| Respuesta incluye **sessionToken** (nunca API key, webhook secret, workflow_id) | ✅ |
| Webhook valida DIDIT_WEBHOOK_SECRET (firma) | ✅ |
| Webhook actualiza APPROVED y DECLINED en BD; estados intermedios solo log (igual que web) | ✅ |
| session_id del webhook mapeado al usuario en BD | ✅ |
| GET /kyc/status (o /verification/status) para consultar estado | ✅ |

---

## Contrato Backend (ya implementado)

- **POST /kyc/start** (o POST /verification/start) con usuario autenticado (JWT).
- El backend crea la sesión en Didit, guarda `didit_session_id` y estado inicial (PENDING), y **solo** devuelve al cliente:
  - `data.sessionToken` → usar en `DiditSdk.startVerification(token = sessionToken)`.
  - `data.verificationUrl` → para web (abrir en navegador).
  - `data.sessionId` → referencia opcional.
- **No** se envían al frontend: `DIDIT_API_KEY`, `DIDIT_WEBHOOK_SECRET`, `DIDIT_WORKFLOW_ID`.
- Estado de verificación: **GET /verification/status** o **GET /kyc/status** (mismo JWT). Devuelve `isVerified`, `verificationStatus`, `hasPendingSession`.

---

## Archivos Android a modificar

### 1. `settings.gradle` o `settings.gradle.kts`

Añadir repositorio Maven del SDK Didit:

```gradle
// Groovy
maven { url "https://raw.githubusercontent.com/didit-protocol/sdk-android/main/repository" }
```

```kotlin
// Kotlin DSL
maven { url = uri("https://raw.githubusercontent.com/didit-protocol/sdk-android/main/repository") }
```

### 2. `app/build.gradle` o `app/build.gradle.kts`

- Dependencia:

```gradle
implementation("me.didit:didit-sdk:1.0.0")
```

- Exclusión de packaging (evitar conflicto OSGI):

```gradle
android {
    packaging {
        resources {
            excludes += "META-INF/versions/9/OSGI-INF/MANIFEST.MF"
        }
    }
}
```

### 3. `gradle.properties` (si aplica)

Si usan R8 full mode y hay problemas de ofuscación:

```properties
android.enableR8.fullMode=false
```

### 4. `AndroidManifest.xml`

No es necesario declarar permisos manualmente para el SDK. El SDK ya declara:

- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `CAMERA`
- `NFC` (opcional)

### 5. `MainApplication.kt` (o clase `Application`)

Inicializar el SDK en el ciclo de vida de la aplicación:

```kotlin
DiditSdk.initialize(this)
```

### 6. `MainActivity.kt` – MethodChannel con Flutter

- Flutter debe llamar al código nativo pasando **solo** el `sessionToken` obtenido del backend.
- En el lado Android, recibir ese token y ejecutar:

```kotlin
DiditSdk.startVerification(token = sessionToken)
```

Implementar un **MethodChannel** (o Platform Channel) donde:

- Flutter invoque algo como `startDiditVerification(sessionToken)`.
- Android reciba el `sessionToken` y llame a `DiditSdk.startVerification(token = sessionToken)`.

No almacenar el `sessionToken`; usarlo solo para esa llamada.

---

## Requisitos del SDK

- **Android API 23+** (mínimo del SDK Didit).

---

## Seguridad (recordatorios para Frontend)

- **Nunca** almacenar el `sessionToken`.
- **Nunca** hardcodear `workflowId` ni ninguna credencial de Didit en la app.
- **Nunca** incluir API keys ni el webhook secret en la app.
- El backend es el único que tiene `DIDIT_API_KEY`, `DIDIT_WORKFLOW_ID` y `DIDIT_WEBHOOK_SECRET`; el móvil solo recibe y usa el `sessionToken` en memoria para iniciar la verificación.

---

## Flujo completo (resumen)

1. Flutter: usuario autenticado con JWT.
2. Flutter: **POST /kyc/start** (header `Authorization: Bearer <JWT>`).
3. Backend: crea sesión en Didit, guarda en BD, responde `{ "data": { "sessionToken": "xxxxx" } }`.
4. Flutter: pasa `sessionToken` al MethodChannel de Android.
5. Android: `DiditSdk.startVerification(token = sessionToken)`.
6. Usuario completa el flujo en el SDK.
7. Didit envía webhook al backend; backend actualiza el estado del usuario.
8. Flutter: consulta **GET /verification/status** o **GET /kyc/status** para mostrar estado (verificado/pendiente/rechazado).

El flujo móvil usa el **mismo modelo** que web (sesión creada en backend, mismo webhook, mismo usuario asociado); solo cambia la interfaz (SDK nativo en lugar de WebView).
