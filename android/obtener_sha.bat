@echo off
echo === SHA del keystore de DEBUG (para flutter run) ===
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android 2>nul | findstr "SHA1: SHA256:"
echo.
echo === SHA del keystore de RELEASE (upload-keystore.jks) ===
echo Ejecuta esto y pon la contraseña cuando te la pida:
keytool -list -v -keystore "%~dp0upload-keystore.jks" -alias upload
pause
