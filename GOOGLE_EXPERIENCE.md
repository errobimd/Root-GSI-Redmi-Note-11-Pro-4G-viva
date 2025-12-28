# MANUAL: Antigravity Google Experience (v4.7)
**Certificación Total y Google Wallet en tu Redmi Note 11 Pro 4G**

---

## 🎯 Objetivo: Google Certified
Para que tu dispositivo sea reconocido como un dispositivo "oficial" por Google y puedas usar **Google Wallet (Pagos NFC)**, sigue esta guía avanzada.

---

## 🔑 1. Registro del Dispositivo (GMS)
Si después de instalar la ROM no puedes entrar en la Play Store o dice que no está certificado:
1. Instala una app de "Device ID" o usa la terminal (`adb shell settings get secure android_id`).
2. Copia el **Google Service Framework ID (GSF)**.
3. Ve a: [https://www.google.com/android/uncertified/](https://www.google.com/android/uncertified/)
4. Pega tu ID y regístralo. Reinicia y espera 10-20 minutos.

---

## 💳 2. Google Wallet (GPay) con NFC
Para que los pagos funcionen, debes pasar el examen de "Integridad del Dispositivo":
1. **Zygisk:** Debe estar activo en Magisk.
2. **PlayIntegrityFork:** Instala el módulo ZIP que está en tu carpeta `Descargas/`.
3. **DenyList:** Oculta `Google Play Services` y `Google Wallet`.
4. **⚠️ NOTA:** Si el banco sigue detectando algo, usa el módulo **Shamiko** para forzar la ocultación avanzada.

---

## 📸 3. Google Photos e Inteligencia Artificial
Si usas una ROM tipo "Pixel Experience", tendrás:
*   Almacenamiento ilimitado en Google Photos (calidad ahorro).
*   Widgets exclusivos de Google.
*   Traducción en tiempo real del sistema.

---
**Desarrollado para la comunidad de Antigravity Google Edition**
