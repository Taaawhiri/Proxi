# Proxi — Brand & App Icon

## 1. Prompt per la generazione del logo (Midjourney / DALL·E 3)

Prompt principale (Midjourney, `--v 6.1 --style raw`):

```
Minimalist app icon logo for "Proxi", a proximity-based social network app.
The design fuses the letter "P" with concentric radar sonar waves emanating
from a single glowing dot, suggesting geolocation and nearby connections.
Flat vector design, geometric, single bold silhouette, negative space
technique where the radar rings form the counter of the letter P.
Color palette: deep navy background (#0B1220) with a vivid signal
green-cyan gradient (#00E5A0 to #00B8D9) for the mark. Soft glow on the
radar dot, subtle depth via gradient, no text, no realistic textures,
centered composition, perfect for both dark and light backgrounds,
scalable to small sizes (favicon-safe), rounded modern geometry similar to
premium social/tech app icons (Bumble, Zenly, Discord aesthetic).
Square 1:1 canvas, 1024x1024, transparent background, app icon style,
high contrast silhouette, clean edges --ar 1:1 --style raw --v 6.1
```

Prompt alternativo (DALL·E 3, più descrittivo perché non usa parametri `--`):

```
A minimalist, modern app icon for a geolocation social network called
"Proxi". The icon merges the capital letter "P" with radar/sonar
concentric rings expanding from a small glowing dot, symbolizing proximity
and nearby people detection. Flat design, bold single-color silhouette
using negative space so the radar waves double as the counter of the P.
Deep navy (#0B1220) background, mark in a bright signal green-cyan
gradient (#00E5A0 → #00B8D9) with a subtle soft glow around the center
dot. No text, no photorealism, no drop shadows other than a soft glow,
clean vector geometry, perfectly centered, must remain legible at 48x48px.
Square 1024x1024 canvas, transparent or solid background, in the style of
premium tech/social app icons.
```

Varianti utili da generare a parte:
- **Versione monocromatica bianca** (per splash screen su sfondo navy).
- **Versione solo simbolo su sfondo trasparente** (per l'adaptive icon foreground Android).
- **Versione wordmark** (`Proxi` in un font geometric sans, es. Space Grotesk / Poppins Bold) da usare in splash screen e onboarding, non nell'icona.

## 2. Placeholder generato in questo repo

In attesa dell'asset definitivo generato con Midjourney/DALL·E 3, in questo
repo è stato creato un **placeholder programmatico** coerente con il brief
(radar rings + lettera "P" su navy `#0B1220` con accento `#00E5A0`), per
validare da subito la pipeline di generazione icone:

- `assets/icon/app_icon.png` — icona piena 1024x1024 (bg + mark), usata per
  l'icona classica Android/iOS.
- `assets/icon/app_icon_foreground.png` — solo il mark su sfondo
  trasparente, contenuto nella safe zone centrale (~66%), usato come
  **foreground layer** dell'adaptive icon Android.

Quando avrai il logo definitivo, sostituisci semplicemente questi due file
mantenendo le stesse dimensioni e la stessa safe zone per l'adaptive icon,
poi rilancia il comando al punto 4.

## 3. Come funziona `flutter_launcher_icons`

Il pacchetto è già configurato in `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  remove_alpha_ios: true
  adaptive_icon_background: "#0B1220"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

- `image_path`: sorgente 1024x1024 usata per generare l'icona legacy
  (Android pre-8.0 e iOS, tutte le risoluzioni `mipmap-*` / `AppIcon.appiconset`).
- `adaptive_icon_background` / `adaptive_icon_foreground`: generano
  l'**adaptive icon** Android 8.0+ (`ic_launcher_background.xml` /
  `mipmap-anydpi-v26/ic_launcher.xml`), dove il sistema può animare/ritagliare
  la forma (cerchio, squircle, ecc.) mantenendo il foreground intatto.
- `remove_alpha_ios`: rimuove il canale alpha richiesto da Apple per le
  icone caricate su App Store Connect.

## 4. Comando di generazione

```bash
flutter pub get
dart run flutter_launcher_icons
```

Questo aggiorna automaticamente:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` (adaptive icon)
- `android/app/src/main/res/values/colors.xml` (colore di sfondo adaptive)
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`

Nessuna modifica manuale ai progetti nativi è necessaria: rigenera le icone
ogni volta che cambi `assets/icon/app_icon*.png` e ricommitta l'output.
