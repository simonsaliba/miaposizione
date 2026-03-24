# Mia Posizione - Flutter App

App Flutter per tracciare, salvare e condividere la tua posizione GPS.

## Funzionalità

- **Tracciamento GPS**: Ottieni la tua posizione attuale in tempo reale
- **Salvataggio posizioni**: Salva le posizioni con data e ora
- **Storico**: Visualizza tutte le posizioni salvate
- **Mappa**: Mostra le posizioni su Google Maps
- **Condivisione**: Condividi le posizioni con link Google Maps
- **Material Design 3**: UI moderna e pulita

## Struttura del Progetto

```
lib/
├── main.dart                 # Entry point
├── models/
│   └── position_model.dart   # Modello dati posizione
├── services/
│   ├── location_service.dart # Servizio geolocalizzazione
│   └── storage_service.dart  # Servizio salvataggio Hive
├── providers/
│   └── providers.dart       # State management con Riverpod
└── screens/
    ├── home_screen.dart      # Schermata principale con mappa
    └── history_screen.dart   # Storico posizioni
```

## Setup

### 1. Dipendenze

```bash
flutter pub get
```

### 2. API Key Google Maps

1. Ottieni una API Key da [Google Cloud Console](https://console.cloud.google.com/)
2. Abilita "Maps SDK for Android" e "Maps SDK for iOS"
3. **Android**: Modifica `android/app/src/main/AndroidManifest.xml`
   ```xml
   <meta-data 
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_ACTUAL_API_KEY"/>
   ```
4. **iOS**: Modifica `ios/Runner/Info.plist`
   ```xml
   <key>GoogleMapsAPIKey</key>
   <string>YOUR_ACTUAL_API_KEY</string>
   ```

### 3. Permessi

#### Android (già configurato in AndroidManifest.xml)
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- ACCESS_BACKGROUND_LOCATION

#### iOS (già configurato in Info.plist)
- NSLocationWhenInUseUsageDescription
- NSLocationAlwaysUsageDescription

### 4. Build

```bash
# Debug
flutter build apk --debug    # Android
flutter build ios --debug    # iOS

# Release
flutter build apk --release  # Android
flutter build ios --release  # iOS
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

L'app usa **Riverpod** per la gestione dello stato con il pattern:
- **Services**: Logica di business isolata
- **Providers**: Stato globale reattivo
- **Screens**: UI componenetizzata
