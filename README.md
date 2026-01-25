# Noti - Gestionnaire d'Épreuves & Notifications Intelligentes

Application Flutter production-grade pour la planification et le suivi des épreuves d'examen, avec un système de notifications dynamiques basées sur la durée des épreuves.

## 🚀 Fonctionnalités

### 📚 Gestion des Filières
- Création, modification et suppression de filières.
- Organisation hiérarchique des épreuves par filière.

### 📝 Planification des Épreuves
- Ajout d'épreuves avec date, heure de début et heure de fin.
- Calcul automatique de la durée.
- **Aperçu en temps réel** des rappels qui seront programmés.

### 🔔 Notifications Intelligentes (Règle Métier)
Le système calcule dynamiquement les rappels selon la durée de l'épreuve :

| Durée de l'épreuve | Rappels programmés |
|--------------------|-------------------|
| **2 heures**       | ⏳ 1h restante<br>⏳ 30 min restantes<br>🏁 Fin de l'épreuve |
| **3 heures**       | ⏳ 1h30 restantes<br>⏳ 30 min restantes<br>🏁 Fin de l'épreuve |
| **≥ 4 heures**     | ⏳ 2h restantes<br>⏳ 1h restante<br>⏳ 30 min restantes<br>🏁 Fin de l'épreuve |

## 🛠 Architecture & Tech Stack

Ce projet suit strictement la **Clean Architecture** avec une approche **Feature-first**.

### Technologies
- **Framework** : Flutter
- **State Management** : [Riverpod](https://riverpod.dev/) (Notifiers & Providers)
- **Immutabilité & Data Class** : [Freezed](https://pub.dev/packages/freezed)
- **Stockage Local** : [Hive](https://docs.hivedb.dev/) (NoSQL, rapide et léger)
- **Notifications** : [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)

### Structure du Code
```
lib/
├── application/   # State Management (Notifiers, Providers)
├── domain/        # Entités, Règles métier (Pure Dart)
├── infrastructure/# Implémentation des Repositories, Sources de données
└── presentation/  # Widgets, Pages, UI Logic
```

## 📱 Installation

1. **Prérequis**
   - Flutter SDK installé (v3.10+)
   - Java 11/17 (pour Android build)

2. **Cloner le projet**
   ```bash
   git clone https://github.com/votre-username/noti.git
   cd noti
   ```

3. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

4. **Génération de code (Freezed/Riverpod/Hive)**
   Ce projet utilise `build_runner` pour générer le code répétitif.
   ```bash
   dart run build_runner build -d
   ```

5. **Lancer l'application**
   ```bash
   flutter run
   ```

## 🧪 Tests

Les règles métier critiques (notamment le calcul des notifications) sont couvertes par des tests unitaires.

```bash
flutter test
```

## 📦 CI/CD

Un workflow GitHub Actions est configuré dans `.github/workflows/build_apk.yml` pour :
- Construire l'APK Release automatiquement.
- Signer l'application.
- Créer une Release GitHub avec l'APK attaché (`noti-vX.apk`).

## 📄 Licence

Ce projet est sous licence MIT.
