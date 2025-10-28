# Projet dbt - Configuration et Démarrage

## 📋 Description

Ce projet utilise dbt (data build tool) pour transformer et modéliser les données dans notre entrepôt de données. dbt permet de gérer les transformations SQL de manière modulaire, testable et documentée.

## 🎯 Objectifs

- Centraliser les transformations de données
- Assurer la qualité des données par des tests automatisés
- Documenter les modèles et les sources de données
- Faciliter la collaboration entre les analystes et ingénieurs de données

## 🛠️ Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- Python 3.8 ou supérieur
- pip (gestionnaire de paquets Python)
- Git
- Accès à votre entrepôt de données (Snowflake, BigQuery, Redshift, PostgreSQL, etc.)

## 📦 Installation

### 1. Cloner le repository

```bash
git clone <url-du-repository>
cd <nom-du-projet>
```

### 2. Créer un environnement virtuel

```bash
python -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
```

### 3. Installer dbt et les dépendances

```bash
pip install -r requirements.txt
```

Ou pour une installation spécifique à votre plateforme :

```bash
# Pour Snowflake
pip install dbt-snowflake

# Pour BigQuery
pip install dbt-bigquery

# Pour PostgreSQL
pip install dbt-postgres

# Pour Redshift
pip install dbt-redshift
```

## ⚙️ Configuration

### 1. Configuration du profil dbt

Créez ou modifiez le fichier `~/.dbt/profiles.yml` :

```yaml
mon_projet:
  target: dev
  outputs:
    dev:
      type: postgres  # ou snowflake, bigquery, redshift
      host: localhost
      user: votre_utilisateur
      password: votre_mot_de_passe
      port: 5432
      dbname: votre_base_de_donnees
      schema: dbt_dev
      threads: 4
    
    prod:
      type: postgres
      host: production-host
      user: prod_user
      password: "{{ env_var('DBT_PASSWORD') }}"
      port: 5432
      dbname: prod_database
      schema: analytics
      threads: 8
```

### 2. Variables d'environnement (optionnel)

Créez un fichier `.env` à la racine du projet :

```bash
DBT_PASSWORD=votre_mot_de_passe_prod
DBT_USER=votre_utilisateur
```

**Note:** Ajoutez `.env` à votre `.gitignore` pour ne pas versionner les secrets.

## 🏗️ Structure du projet

```
.
├── analyses/          # Requêtes SQL ad-hoc
├── macros/            # Fonctions SQL réutilisables
├── models/            # Modèles de transformation
│   ├── staging/       # Modèles de staging (sources brutes)
│   ├── intermediate/  # Modèles intermédiaires
│   └── marts/         # Modèles finaux (data marts)
├── seeds/             # Fichiers CSV de référence
├── snapshots/         # Tables de type SCD (Slowly Changing Dimensions)
├── tests/             # Tests personnalisés
├── dbt_project.yml    # Configuration du projet
└── packages.yml       # Packages dbt externes
```

## 🚀 Commandes principales

### Vérifier la configuration

```bash
dbt debug
```

### Installer les packages dbt

```bash
dbt deps
```

### Exécuter les modèles

```bash
# Exécuter tous les modèles
dbt run

# Exécuter un modèle spécifique
dbt run --select nom_du_modele

# Exécuter les modèles d'un dossier
dbt run --select staging.*

# Exécuter en mode full-refresh (reconstruction complète)
dbt run --full-refresh
```

### Tester les modèles

```bash
# Exécuter tous les tests
dbt test

# Tester un modèle spécifique
dbt test --select nom_du_modele
```

### Générer la documentation

```bash
# Générer la documentation
dbt docs generate

# Servir la documentation localement
dbt docs serve
```

### Charger les seeds

```bash
dbt seed
```

### Compiler les modèles (sans exécution)

```bash
dbt compile
```

## 🔄 Workflow de développement

1. Créer une branche pour vos modifications
2. Développer vos modèles dans le dossier approprié
3. Tester localement avec `dbt run` et `dbt test`
4. Documenter vos modèles dans les fichiers `.yml`
5. Créer une pull request
6. Après validation, merger dans la branche principale

## 📝 Bonnes pratiques

- Toujours tester vos modèles avant de les déployer
- Documenter chaque modèle et colonne importante
- Utiliser des noms explicites et cohérents
- Éviter les SELECT * dans les modèles de production
- Privilégier les modèles incrémentaux pour les grandes tables
- Utiliser des macros pour éviter la duplication de code

## 🧪 Tests

Les tests dbt incluent :

- **Tests génériques** : `unique`, `not_null`, `accepted_values`, `relationships`
- **Tests personnalisés** : définis dans le dossier `tests/`
- **Tests de sources** : validation des données sources

Exemple de test dans un fichier `schema.yml` :

```yaml
models:
  - name: dim_customers
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
      - name: email
        tests:
          - unique
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez suivre ces étapes :

1. Fork le projet
2. Créez une branche pour votre feature
3. Committez vos changements
4. Poussez vers la branche
5. Ouvrez une Pull Request

## 📚 Ressources

- [Documentation officielle dbt](https://docs.getdbt.com/)
- [Best practices dbt](https://docs.getdbt.com/guides/best-practices)
- [dbt Learn (cours gratuits)](https://courses.getdbt.com/)

## 📧 Contact

Pour toute question, contactez [votre-email@example.com]

## 📄 Licence

Ce projet est sous licence [MIT/Apache/etc.]