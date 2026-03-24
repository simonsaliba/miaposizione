# Mia Posizione

App Flutter per tracciare, salvare e condividere la tua posizione GPS.

## Funzionalità

- **Tracciamento GPS** - Ottieni la tua posizione attuale in tempo reale
- **Salvataggio posizioni** - Salva le posizioni con data e ora
- **Storico** - Visualizza tutte le posizioni salvate
- **Mappa** - Mostra le posizioni su Google Maps
- **Condivisione** - Condividi le posizioni con link Google Maps
- **Material Design 3** - UI moderna e pulita
- **Dark mode** - Supporto automatico tema scuro

## Struttura del Progetto

```
miaposizione_app/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── models/
│   │   └── position_model.dart   # Modello dati posizione
│   ├── services/
│   │   ├── location_service.dart # Servizio geolocalizzazione
│   │   └── storage_service.dart  # Servizio salvataggio Hive
│   ├── providers/
│   │   └── providers.dart       # State management Riverpod
│   └── screens/
│       ├── home_screen.dart      # Schermata principale con mappa
│       └── history_screen.dart   # Storico posizioni
├── android/                      # Configurazione Android
└── ios/                          # Configurazione iOS
```

## Setup

### 1. Installa Flutter

Segui la guida ufficiale: https://docs.flutter.dev/get-started/install

### 2. Clona il progetto

```bash
git clone git@github.com:simonsaliba/miaposizione.git
cd miaposizione/miaposizione_app
```

### 3. Dipendenze

```bash
flutter pub get
```

### 4. API Key Google Maps

1. Ottieni una API Key da [Google Cloud Console](https://console.cloud.google.com/)
2. Abilita "Maps SDK for Android" e "Maps SDK for iOS"
3. **Android**: Modifica `android/app/src/main/AndroidManifest.xml`
4. **iOS**: Modifica `ios/Runner/Info.plist`

### 5. Build

```bash
# Debug
flutter build apk --debug    # Android
flutter run                  # Esegue in emulatore/dispositivo

# Release
flutter build apk --release  # Android
flutter build ios --release  # iOS (solo su Mac)
```

## Dipendenze

- `flutter_riverpod` - State management
- `geolocator` - Geolocalizzazione GPS
- `permission_handler` - Gestione permessi
- `google_maps_flutter` - Google Maps
- `hive` / `hive_flutter` - Salvataggio dati locale
- `share_plus` - Condivisione posizione
- `intl` - Formattazione date

## Architettura

L'app usa **Riverpod** per la gestione dello stato con pattern clean architecture:
- **Services** - Logica di business isolata
- **Providers** - Stato globale reattivo
- **Screens** - UI componentizzata

## Autore

Simon Saliba
