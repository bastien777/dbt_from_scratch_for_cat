# Gestion des droits d'accès avec dbt et Databricks Unity Catalog

## 🎯 Objectif

Explorer les options disponibles pour gérer les droits d’accès aux **tables**, **colonnes** et **lignes** dans un environnement Databricks utilisant **Unity Catalog**, tout en intégrant cela avec **dbt**.

---

## 🧱 1. Gouvernance via Unity Catalog

### a. Niveaux de sécurité possibles

Unity Catalog centralise la sécurité et la gouvernance au niveau du **catalogue** et du **schéma**, avec des contrôles d’accès fins :

- **Contrôle par objet** : tables, vues, fonctions, volumes, etc.
- **Contrôle par colonne** : via *Column-level privileges*.
- **Contrôle par ligne** : via *Row Filters* ou *Dynamic View Policies*.

### b. Principaux types de privilèges

| Type d’objet | Exemples de privilèges |
|---------------|------------------------|
| Catalog / Schema | `USE CATALOG`, `CREATE SCHEMA`, `USE SCHEMA` |
| Table / View | `SELECT`, `MODIFY`, `REFERENCES`, `OWN` |
| Function / Volume | `EXECUTE`, `READ VOLUME`, `WRITE VOLUME` |

Exemple SQL :

```sql
GRANT SELECT ON TABLE main.analytics.users TO `data_scientist_group`;
GRANT MODIFY ON TABLE main.analytics.orders TO `etl_service_account`;
```

---

## 🧩 2. Gestion des colonnes sensibles

Pour masquer ou restreindre l’accès à certaines colonnes, Unity Catalog propose :

### a. **Column-level access control**

```sql
GRANT SELECT(column_name) ON TABLE main.analytics.users TO `finance_team`;
```

### b. **Dynamic masking policies**

Permet de masquer dynamiquement des valeurs sensibles :

```sql
CREATE MASKING POLICY mask_email
  AS (val STRING) -> CASE
    WHEN is_account_group_member('finance_team') THEN val
    ELSE '***MASKED***'
  END;

ALTER TABLE main.analytics.users
  ALTER COLUMN email
  SET MASKING POLICY mask_email;
```

---

## 🧮 3. Filtrage de lignes (Row-level security)

Unity Catalog introduit aussi les *Row Filters* :

```sql
CREATE ROW FILTER filter_sales_region
  AS (region STRING) -> region = current_user_region();

ALTER TABLE main.analytics.sales
  SET ROW FILTER filter_sales_region ON (region);
```

Cela permet de ne montrer à chaque utilisateur que les lignes correspondant à son périmètre (ex. : sa région, son entité, etc.).

---

## 🧰 4. Intégration avec dbt

### a. dbt n’assigne pas directement de privilèges

dbt ne gère pas la sécurité au niveau utilisateur, mais il **peut exécuter du SQL post-déploiement** via :

- les **`post-hook`** (ou `on-run-end`) ;
- les **macros personnalisées** qui exécutent les commandes GRANT/MASK/ROW FILTER.

Exemple :

```yaml
models:
  +post-hook:
    - "GRANT SELECT ON TABLE {{ this }} TO `analyst_team`"
```

### b. Approche recommandée

Centraliser la définition des politiques de sécurité **dans Unity Catalog**, et déclencher depuis dbt les appels nécessaires (via SQL hooks ou jobs externes) pour :

- créer les tables ou vues avec les bons privilèges ;
- appliquer automatiquement les policies sur certaines tables sensibles ;
- auditer la configuration de sécurité.

---

## 🧭 5. Architecture recommandée

| Niveau | Gestion principale | Exemple |
|--------|---------------------|----------|
| **Catalog / Schema** | Admins / Security Team | Définition des accès globaux |
| **Table** | dbt via hooks ou scripts | GRANT SELECT, MODIFY |
| **Colonne** | Unity Catalog Masking Policy | Masquage dynamique |
| **Ligne** | Unity Catalog Row Filter | Filtrage contextuel |
| **Documentation** | dbt Docs + Markdown | Suivi des politiques de sécurité |

---

## ✅ Conclusion

- **Unity Catalog** est la couche de gouvernance principale.  
- **dbt** se concentre sur la transformation et peut **propager les politiques** via des hooks.  
- Les contrôles fins (colonne, ligne) doivent être gérés côté **Databricks SQL / UC Policies**.  
- L’approche optimale : **séparer la logique de sécurité (UC)** de la **logique métier (dbt)**, tout en les orchestrant dans un flux cohérent.
