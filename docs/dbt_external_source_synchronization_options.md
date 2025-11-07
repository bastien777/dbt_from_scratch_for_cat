# Synchronisation entre dbt et une source de données externe

## 🎯 Objectif

Garantir que certaines transformations dbt ne s’exécutent **qu’après** qu’une source externe (table ou vue) ait été rafraîchie par un service interne.

---

## 🧱 1. Le problème à résoudre

Un service externe exporte chaque matin une table (ex : `external.daily_snapshot`) vers Databricks.  
Certaines transformations dbt en dépendent directement.  
Il faut donc **attendre la disponibilité complète de cette source** avant d’exécuter les modèles concernés dans dbt.

---

## 🧩 2. Options possibles

### Option 1 — Orchestration externe (la plus propre)

Utiliser un **orchestrateur** (par ex. : Airflow, Dagster, Prefect, Databricks Workflows) pour contrôler le séquencement.

**Principe :**
1. Le service externe termine l’export et émet un signal (event, webhook, API call).
2. L’orchestrateur reçoit ce signal et déclenche `dbt run --select tag:external_ready`.

**Avantages :**
- Contrôle fin du timing.
- Logique d’attente centralisée.
- Intégration simple avec les jobs Databricks.

**Exemple Airflow :**
```python
ExternalSensor(
    task_id="wait_for_external_export",
    external_dag_id="external_export_dag",
    mode="poke",
    poke_interval=300
)
```

Puis :
```python
BashOperator(
    task_id="run_dbt",
    bash_command="dbt run --select tag:external_ready"
)
```

---

### Option 2 — Utiliser un “capteur” ou “polling” dans dbt

dbt n’a **pas nativement** de mécanisme de polling, mais on peut simuler un **check préalable** via un script externe ou un macro.

#### Exemple : macro qui vérifie la fraîcheur

```sql
{% macro wait_for_external_data(table, max_age_minutes) %}
  {% set query %}
    SELECT MAX(updated_at) AS last_update
    FROM {{ table }}
  {% endset %}

  {% set result = run_query(query) %}
  {% if execute %}
    {% set last_update = result.columns[0].values()[0] %}
    {% if last_update < (modules.datetime.datetime.now() - modules.datetime.timedelta(minutes=max_age_minutes)) %}
      {{ exceptions.raise_compiler_error("External data not ready") }}
    {% endif %}
  {% endif %}
{% endmacro %}
```

Puis l’utiliser comme pré-hook dans les modèles dépendants :

```yaml
models:
  my_project:
    external_dependent_model:
      +pre-hook: "{{ wait_for_external_data('external.daily_snapshot', 60) }}"
```

⚠️ Inconvénient : ce n’est pas asynchrone — dbt va échouer et tu devras relancer plus tard.

---

### Option 3 — Dépendance logique dans dbt (avec tags et sélection)

Taguer les modèles dépendants d’une source externe :

```yaml
models:
  my_project:
    external_dependent_model:
      +tags: ["external_ready"]
```

Puis exécuter ton pipeline en deux temps :

```bash
# 1. Exécuter tout sauf les dépendants externes
dbt run --exclude tag:external_ready

# 2. Une fois la source externe prête
dbt run --select tag:external_ready
```

Cette approche est simple, compatible avec un orchestrateur ou un trigger manuel.

---

### Option 4 — Vérification via dbt sources (avec freshness)

dbt permet de définir une **source avec test de fraîcheur** :

```yaml
version: 2

sources:
  - name: external
    tables:
      - name: daily_snapshot
        freshness:
          warn_after: {count: 6, period: hour}
          error_after: {count: 12, period: hour}
        loaded_at_field: updated_at
```

Puis tu peux exécuter :

```bash
dbt source freshness
```

ou combiner dans un pipeline :

```bash
dbt source freshness && dbt run --select tag:external_ready
```

Cela permet de bloquer le run si la source est trop vieille.

---

## 🧰 3. Options avancées

- **Webhook trigger** : ton service externe envoie une requête HTTP à une API (ex. Databricks Job API) qui déclenche le run dbt.  
- **Event-driven orchestration** : via un bus d’événements (Azure Event Grid, AWS SNS, Kafka).  
- **dbt Cloud webhooks** : si tu utilises dbt Cloud, tu peux déclencher un job dbt directement à partir d’un signal externe.

---

## ✅ Recommandation

| Contrainte | Option recommandée |
|-------------|-------------------|
| Environnement Databricks Jobs | **Workflow avec tâche dbt conditionnelle** |
| Environnement Airflow / Prefect | **Orchestration externe + capteur de disponibilité** |
| Pas d’orchestrateur | **dbt source freshness + run séquencé** |
| Besoin de robustesse / audit | **Webhook ou event trigger** |

---

## 🚀 Conclusion

- dbt n’est pas conçu pour attendre activement des sources externes.  
- La meilleure pratique est d’utiliser un **orchestrateur** ou une **vérification de fraîcheur** avant le run.  
- Tu peux tout de même intégrer des checks légers via des **macros pre-hook** pour bloquer un modèle si la source n’est pas prête.  
- En Databricks, les **Workflows** ou **Jobs** avec dépendances conditionnelles sont idéaux pour ce scénario.
