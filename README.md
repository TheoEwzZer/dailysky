# DailySky 🌤️

Application météo Flutter (Android + iOS) basée sur l'API gratuite
[OpenWeatherMap](https://openweathermap.org/). Affiche les prévisions sur 5 jours
avec un écran de détail par jour. UI soignée (Material 3, en-tête à dégradé
dynamique), architecture propre (MVVM), gestion d'erreurs robuste et cache.

## Fonctionnalités

- **Écran principal** : en-tête « héros » (ville, température actuelle, dégradé
  qui change selon la météo) + liste des jours (nom, icône, min/max).
- **Écran de détail** : min/max, ressenti, humidité, vent (km/h + direction),
  précipitations, description complète, icône, date, et **bande horaire** de la
  journée.
- **Localisation** : GPS de l'appareil, avec **repli automatique** sur une ville
  par défaut si la position est indisponible/refusée, + **recherche de ville**.
- **États** : chargement / erreur (avec message FR + « Réessayer ») / succès —
  **aucun crash** même si l'API échoue (timeout, hors-ligne, clé invalide…).
- **Cache** (`shared_preferences`) : évite les requêtes inutiles et permet un
  repli hors-ligne (données du cache).
- **Animations** : transition de page douce + `Hero` sur l'icône météo.

## Architecture (MVVM en couches)

```
lib/
  config/        Configuration (clé API, ville par défaut, unités…)
  core/          Thème, palette météo, mappers d'icônes, formatage, routing
  data/          models · services (API, cache, localisation) · repository
  presentation/  state · home (+ widgets) · detail (+ widgets)
  shared/        widgets réutilisables (loading, error)
```

La logique métier vit dans les services/repository/ViewModel ; les widgets ne
font que de l'affichage. L'état est géré avec **Provider + ChangeNotifier**.

## Prérequis

- Flutter **3.44+** (canal stable) — vérifier avec `flutter doctor`.
- Une **clé API OpenWeatherMap gratuite** : créez un compte sur
  [openweathermap.org](https://home.openweathermap.org/users/sign_up) puis
  copiez votre clé (onglet « API keys »).
  ⚠️ L'activation d'une nouvelle clé peut prendre **jusqu'à 2 heures**.

## Configuration de la clé API

La clé n'est **jamais codée en dur**. Elle est fournie au build via un fichier
de configuration `env.json` (déjà ignoré par Git).

1. Copiez l'exemple : `env.example.json` -> `env.json`
2. Renseignez votre clé :

```json
{
  "OWM_API_KEY": "votre_cle_openweathermap"
}
```

Toutes les commandes ci-dessous passent ce fichier via
`--dart-define-from-file=env.json`.

## Lancer sur Android (possible depuis Windows)

1. Sur le téléphone : activez les **Options développeur** puis le **Débogage
   USB**. Branchez en USB et acceptez l'autorisation.
2. Vérifiez la détection : `flutter devices`
3. Installez les dépendances : `flutter pub get`
4. Lancez en debug :

   ```bash
   flutter run --dart-define-from-file=env.json
   ```

5. Build release (APK) :

   ```bash
   flutter build apk --release --dart-define-from-file=env.json
   ```

   L'APK est généré dans `build/app/outputs/flutter-apk/app-release.apk`
   (installez-le avec `flutter install` ou copiez-le sur l'appareil).

> 💡 Sans câble : activez le **débogage Wi-Fi** (`adb pair` puis `adb connect`).

## Lancer sur iOS (Mac + Xcode requis)

> ⚠️ La compilation iOS est **impossible depuis Windows** : elle nécessite
> **macOS + Xcode**.

Sur un Mac :

```bash
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace   # définir une « Team » de signature dans Xcode
flutter run --dart-define-from-file=env.json
```

(Alternative sans Mac physique : un service de CI macOS comme Codemagic.)

## Aperçu rapide (web / desktop)

Pratique pour itérer sur l'UI sans appareil mobile (OpenWeatherMap autorise le
CORS, donc le web fonctionne) :

```bash
flutter run -d chrome --dart-define-from-file=env.json
```

## Tests & qualité

```bash
flutter analyze            # 0 problème
flutter test               # tests unitaires + widget
```

Couverture : regroupement des prévisions par jour, mapping des erreurs
réseau/API, transitions d'état du ViewModel, et smoke test de l'écran principal.

## Dépannage

### Build Android qui échoue sous Windows (verrou de fichier)

Erreurs du type :

- `Could not close incremental caches in ...\build\..._android\kotlin\...`
- `The process cannot access the file because it is being used by another process`

Ce ne sont **pas** des erreurs de code : un processus verrouille des fichiers du
dossier `build/` pendant la compilation (généralement **Windows Defender /
antivirus** qui scanne les fichiers générés, ou un **démon Gradle résiduel**).
Solutions, par ordre de préférence :

1. Ajouter une **exclusion antivirus** (Windows Defender -> « Exclusions ») pour le
   dossier du projet (ou au moins son sous-dossier `build/`).
2. Arrêter les processus Gradle/Flutter résiduels, puis nettoyer :
   ```bash
   cd android && ./gradlew --stop && cd ..
   flutter clean && flutter pub get
   flutter build apk --debug --dart-define-from-file=env.json
   ```
3. Placer le projet dans un chemin non surveillé par l'antivirus.

> Le code compile correctement (vérifié via `flutter analyze`, `flutter test` et
> `flutter build web`) ; cette erreur est propre à l'environnement Windows.

### « Invalid API key » (HTTP 401)

Une clé fraîchement créée peut mettre **jusqu'à 2 h** à s'activer. L'application
affiche un message clair dans ce cas. Vérifiez aussi qu'il n'y a pas de faute de
frappe dans `env.json`.

## Remarques

- Endpoints utilisés (offre gratuite) : `/data/2.5/forecast` (prévision
  5 jours / 3 h, regroupée par jour) et `/data/2.5/weather` (météo actuelle).
- Comme toute clé embarquée dans une app mobile, la clé OWM reste extractible du
  binaire ; pour un usage production à grande échelle, passez par un backend
  proxy. C'est hors périmètre de ce projet.
