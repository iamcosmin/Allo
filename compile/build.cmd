@echo off
cls
echo =============================================================
echo = Take a moment to change the version code in pubspec.yaml. =
echo = Then, press any key to continue.                          =
echo =============================================================
pause > nul
cls
echo =======================================
echo = Building for Android (flavor: prod) =
echo =======================================
pwsh.exe -Command flutter doctor
ping 127.0.0.1 -n 6 > nul
cls
echo =====================================
echo = Building for Web (renderer: html) =
echo =====================================
flutter build web && ping 127.0.0.1 -n 6 > nul
cls
echo =======================
echo = Deploying to server =
echo =======================
npx firebase deploy
