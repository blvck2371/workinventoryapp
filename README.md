# Work Inventory - Application de gestion d'heures de travail étudiant

Une application mobile Flutter moderne pour aider les étudiants à suivre leurs heures de travail en job à temps partiel.

## 🎯 Fonctionnalités

### ✅ Configuration initiale
- Saisie du salaire net par heure
- Définition de l'heure de pause habituelle (par défaut : 12h à 13h)
- Configuration de l'heure de début des heures supplémentaires (par défaut : 16h)

### ✅ Enregistrement journalier de mission
- Date du jour
- Heure de début et fin de travail
- Heure de pause (optionnelle, toujours 1h non rémunérée)
- Adresse ou lieu de la mission
- Description libre de la mission

### ✅ Calculs automatiques
- Heures normales travaillées
- Heures supplémentaires (avec majoration de 25%)
- Salaire journalier estimé
- Salaire mensuel cumulé

### ✅ Tableau de bord
- Affichage du nombre total d'heures travaillées sur le mois
- Affichage du salaire cumulé estimé
- Graphiques et statistiques visuelles
- Navigation par mois

### ✅ Historique
- Liste filtrable des jours travaillés
- Accès aux détails de chaque journée
- Export PDF (à implémenter)

## 🎨 Design UI

- Interface moderne et épurée
- Couleurs douces (bleu pastel, blanc, gris clair)
- Cards arrondies pour afficher les journées
- Navigation intuitive avec BottomNavigationBar
- Design responsive pour mobile Android/iOS

## 🛠️ Stack technique

- **Flutter** - Framework principal
- **Hive** - Base de données locale NoSQL
- **GetX** - Gestion d'état et navigation
- **flutter_datetime_picker_plus** - Sélecteurs de date/heure
- **intl** - Internationalisation et formatage
- **pdf & printing** - Génération de rapports PDF

## 📱 Installation et utilisation

### Prérequis
- Flutter SDK 3.8.1+
- Dart 3.0+
- Android Studio / VS Code

### Installation

1. Cloner le projet :
```bash
git clone <repository-url>
cd workinventoryapp
```

2. Installer les dépendances :
```bash
flutter pub get
```

3. Générer les fichiers Hive :
```bash
flutter packages pub run build_runner build
```

4. Lancer l'application :
```bash
flutter run
```

### Première utilisation

1. **Configuration initiale** : L'application vous guide pour configurer vos paramètres de travail
2. **Ajouter une mission** : Utilisez le bouton "+" pour enregistrer une nouvelle journée de travail
3. **Consulter le dashboard** : Visualisez vos statistiques mensuelles
4. **Paramètres** : Modifiez vos configurations via l'icône d'engrenage

## 📊 Structure du projet

```
lib/
├── controllers/
│   └── main_controller.dart      # Contrôleur principal GetX
├── models/
│   ├── user_settings.dart        # Modèle des paramètres utilisateur
│   └── work_session.dart         # Modèle des sessions de travail
├── screens/
│   ├── onboarding_screen.dart    # Écran de configuration initiale
│   ├── dashboard_screen.dart     # Écran principal (tableau de bord)
│   ├── add_session_screen.dart   # Écran d'ajout de mission
│   └── settings_screen.dart      # Écran des paramètres
├── services/
│   └── hive_service.dart         # Service de base de données
├── utils/
│   └── colors.dart               # Palette de couleurs
├── widgets/
│   ├── stats_card.dart           # Widget pour les statistiques
│   ├── session_card.dart         # Widget pour les sessions
│   └── month_selector.dart       # Widget de sélection de mois
└── main.dart                     # Point d'entrée de l'application
```

## 🔧 Configuration

### Paramètres utilisateur
- **Salaire horaire** : Montant net par heure de travail
- **Pause habituelle** : Heures de début et fin de pause par défaut
- **Heures supplémentaires** : Heure de début des heures supplémentaires

### Calculs automatiques
- **Heures normales** : Calculées jusqu'à l'heure de début des heures supplémentaires
- **Heures supplémentaires** : Calculées avec une majoration de 25%
- **Pause** : Toujours déduite du temps de travail (1h non rémunérée)

## 📈 Fonctionnalités à venir

- [ ] Export PDF des rapports mensuels
- [ ] Historique complet avec filtres avancés
- [ ] Graphiques et visualisations détaillées
- [ ] Sauvegarde cloud (Firebase)
- [ ] Notifications et rappels
- [ ] Mode sombre
- [ ] Support multi-langues

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Commiter vos changements
4. Pousser vers la branche
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement

---

**Développé avec ❤️ pour les étudiants qui travaillent à temps partiel**
